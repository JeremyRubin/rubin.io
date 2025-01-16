---
comments: True
disqusId: b2e599366ec42732af04508978f7c91203a2308d
layout: post
title: "CSFS Re-Keying and Laddering, Deterministic Update Rekeying, & Applications to LN-Symmetry"
date: 2024-12-02
---

_This is a collab post with [Rearden](https://twitter.com/reardencode)._

At Bitcoin++ in Austin this year Rearden showed that there are many ways
to realize Lightning Symmetry using various bitcoin upgrade proposals. All of
these methods require either an extra signing round-trip for each channel
update, or the ability to force the hash of the settlement transaction to be
visible with its corresponding update transaction. This can be generalized as
the requirement that the signature authorizing a given channel be both
rebindable (i.e. not commit to a specific prior UTXO) and commit to some
additional data being visible for that signature to be valid.

We'll start by exploring why Lightning Symmetry requires this data visibility
commitment, then dive into previously known solutions, and present a new
generalized technique for using CSFS to two or more variables. Finally, we will
present an optimized solution based on the principles we've developed to enable
Lightning Symmetry using one extra signature, but no extra signing round-trip
and without the need for concatenation or other explicit multi-commitments.

## Less Common Definitions

* `APO`: `SIGHASH_ANYPREVOUT` as defined in [BIP118](https://github.com/bitcoin/bips/blob/master/bip-0118.mediawiki)
* `IKEY`: `OP_INTERNALKEY` as defined in [BIP349](https://github.com/bitcoin/bips/blob/master/bip-0349.md)
* `CSFS`: `OP_CHECKSIGFROMSTACK` as soon-to-be defined in [BIP348](https://github.com/bitcoin/bips/pull/1535)
* `S`: `500,000,000` the lock time threshold [defined in bitcoin](https://github.com/bitcoin/bitcoin/blob/master/src/script/script.h#L47)


## Naive CTV-CSFS Lightning Symmetry transactions

The scripts for a naive Taproot Lightning Symmetry channel are:
```
channel:
tr(musig(keyA, keyB), raw(CTV IKEY CSFS VERIFY <S+1> CLTV))
update(n):
tr(musig(keyA, keyB), raw(DEPTH NOTIF <settlement-n-hash> CTV ELSE CTV IKEY CSFS VERIFY <S+n+1> CLTV ENDIF))
update-stack:
<update-n-sig> <update-n-hash>
```

If a channel enters force close, an update outpoint will be placed on chain by
A, and B will have a CSV delay encoded in the `settlement-n-hash` before it
can be settled within which to respond with a later state. One of the stated
goals of Lightning Symmetry is to eliminate the need for each partner to store
`O(n)` state for each channel, but now we hit the problem. Because the update
script is not visible on chain, while B can find the update, they cannot
reconstruct the script without the `settlement-n-hash` and only A knows that
hash unless B stores it for every state.


## APO-annex solution

In @instagibbs' [Lightning Symmetry
work](https://delvingbitcoin.org/t/ln-symmetry-project-recap/359), he used APO
and the Taproot Annex where both parties to a channel will only sign an update
transaction if their signatures commit to an annex containing the
corresponding settlement hash needed to reconstruct the update spend script.

The scripts for this are (roughly):
```
channel:
tr(musig(keyA, keyB), raw(<1> CHECKSIGVERIFY <S+1> CLTV))
update(n):
tr(musig(keyA, keyB), raw(DEPTH NOTIF <sig> <01||G> CHECKSIG ELSE <1> CHECKSIGVERIFY <S+n+1> CLTV ENDIF))
update-stack:
<update-n-sig>
```

Here we see the use of APO as a covenant by precomputing a signature for the
secret key `1` and public key `G`. Because CHECKSIG operations commit to the
Taproot Annex, these scripts require no special handling for the channel
parties to require each other to place the settlement transaction hash in the
annex and therefore make it possible for either party to later reconstruct any
prior state's script for spending. Without the annex, an APO-based
implementation would either fall back to the additional signing round-trip, or
using an `OP_RETURN` to force this data to be visible.


## Naive CTV-CSFS solution

Can we just commit to an additional hash using an additional signature?
```
channel:
tr(musig(keyA, keyB), raw(CTV IKEY CSFS VERIFY IKEY CSFS VERIFY <S+1> CLTV))
update(n):
tr(musig(keyA, keyB), raw(DEPTH NOTIF <settlement-n-hash> CTV ELSE CTV IKEY CSFS VERIFY IKEY CSFS VERIFY <S+n+1> CLTV ENDIF))
update-stack:
<settlement-n-sig> <settlement-n-hash> <update-n-sig> <update-n-hash>
```

This method is broken because the two signatures are not linked in any way. A
malicious channel partner can place a mismatched settlement hash, and update
transaction on chain, preventing their partner who has a valid later update
from reconstructing the scripts and updating the channel state.

One obvious solution would be to combine the update hash and the settlement
hash, but since bitcoin lacks a concatenation operator, we cannot do that.
Recently [@4moonsettler](x.com/4moonsettler) proposed
[`OP_PAIRCOMMIT`](https://github.com/bitcoin/bips/pull/1699) as an alternative
for this purpose.


## CTV-CSFS delegation solution

Now we come to the new solution that we've developed, which ties the update
and settlement hashes together by the keys which have signed them. CSFS is
known to be useful for delegation, so we initially delegate to a rekey:
```
script(n):
    DUP TOALT DUP TOALT
    IKEY CSFS VERIFY
    OP_SIZE <32> EQUALVERIFY CTV
    2DUP EQUAL NOT VERIFY
    ROT SWAP FROMALT CSFS VERIFY
    FROMALT CSFS VERIFY <S+n+1> CLTV
channel:
    tr(musig(keyA, keyB), raw(<script(0)>))
update(n):
    tr(musig(keyA, keyB),
        raw(DEPTH NOTIF <settlement-n-hash> CTV ELSE <script(n)> ENDIF))
stack(n):
    <settlement-n-sig>
    <update-n-sig>
    <settlement-extradata>
    <update-n-ctv>
    <rekey-sig>
    <rekey>
```

Here the `rekey` is an ephemeral key either randomly generated or derived
for each state using something like BIP32 and based on the channel key. What
matters is that the `rekey` is never used to sign anything other than the two
messages corresponding to the update and settlement hashes for its state. In
this way they are only valid together and the correct settlement hash must be
available for a channel partner to reconstruct the scripts and update the
channel settlement. One quirk of this solution is that if the two signed items
are allowed to be equal, a malicious partner can simply place the same update
hash on the stack with its signature twice, so they must be checked for
inequality by the script.

This scheme is secure  because of the length check for the arg `update-n-ctv`,
it should be ensured that the other `<settlement-extradata>` is either not a
valid CTV hash or is not length 32.

## CSFS Key Laddering 
Key Laddering extends the rekeying approach shown above to allow recursively
rekeying to an arbitrary number of variables. This allows CSFS to be used without
OP\_CAT to sign over collections of variables to be plugged into a script.


For example, for 5 variables (not optimized, written for clarity):

```
DATASIGS: <sd1> <d1> <sd2> <d2> <sd3> <d3> <sd4> <d4> <sd5> <d5>
stack: DATASIGS + <k5> <s5> <k4> <s4> <k3> <s3> <k2> <s2> <k1> <s1>

program:

\\ First, check that k1 is signed by IKEY
    OVER IKEY CSFSV
    DUP TOALT

// Next, Check that k_i signs k_{i+1}
    // stack: DATASIGS + <k5> <s5> <k4> <s4> <k3> <s3> <k2> <s2> <k1>
    // altstack: <k1>

        3DUP ROT SWAP CSFSV 2DROP DUP TOALT

    // stack: DATASIGS + <k5> <s5> <k4> <s4> <k3> <s3> <k2>
    // altstack: <k1> <k2>

        3DUP ROT SWAP CSFSV 2DROP DUP TOALT

    // stack: DATASIGS + <k5> <s5> <k4> <s4> <k3>
    // altstack: <k1> <k2> <k3>

        3DUP ROT SWAP CSFSV 2DROP DUP TOALT

    // stack: DATASIGS + <k5> <s5> <k4>
    // altstack: <k1> <k2> <k3> <k4>

        3DUP ROT SWAP CSFSV 2DROP

    // stack: <sd1> <d1> <sd2> <d2> <sd3> <d3> <sd4> <d4> <sd5> <d5> <k5>
    // altstack: <k1> <k2> <k3> <k4>


        FROMALT FROMALT FROMALT FROMALT

    // stack: <sd1> <d1> <sd2> <d2> <sd3> <d3> <sd4> <d4> <sd5> <d5> <k5> <k4> <k3> <k2> <k1>
    // altstack:

// Now, check each signature of the data

    <6> PICK // sd5
    <6> PICK // d5
    <6> PICK // k5
    CSFSV

    <8> PICK // sd4
    <8> PICK // d4
    <5> PICK // k4
    CSFSV

    <10> PICK // sd3
    <10> PICK // d3
    <4> PICK // k3
    CSFSV

    <12> PICK // sd2
    <12> PICK // d2
    <3> PICK // k2
    CSFSV

    <14> PICK // sd1
    <14> PICK // d1
    <2> PICK // k1
    CSFSV

// Now, Check the inequalities that no key is used as data:
    // stack: <sd1> <d1> <sd2> <d2> <sd3> <d3> <sd4> <d4> <sd5> <d5> <k5> <k4> <k3> <k2> <k1>
    // altstack:

    // No need to check k1 != d0 since no d0

    // Check that k2 != d1
    <1> PICK
    <14> PICK
    NOT EQUAL VERIFY

    // Check that k3 != d2
    <2> PICK
    <12> PICK
    NOT EQUAL VERIFY


    // Check that k4 != d3
    <3> PICK
    <8> PICK
    NOT EQUAL VERIFY

    // check that k5 != d4
    <4> PICK
    <6> PICK
    NOT EQUAL VERIFY


// stack: <sd1> <d1> <sd2> <d2> <sd3> <d3> <sd4> <d4> <sd5> <d5> <k5> <k4> <k3> <k2> <k1>
// altstack:

2DROP 2DROP DROP
TOALT DROP
TOALT DROP
TOALT DROP
TOALT DROP
TOALT DROP

// stack:
// altstack: <d5> <d4> <d3> <d2> <d1>

// Whatever else


```
This lets you sign an arbitrary number of variables in a sequence.

One "gotcha" not shown in the above script is there is a need to ensure the signature over data and signatures over keys are not exchangable at each hop.
Care should be taken to ensure this.

One alternative scheme is to do "signature laddering". That is, instead of signing a key at each step, sign instead the next signature.

E.g., re-key by signing with IKEY the first signature. Then verify it against any key / message pair it will validate against. The key can be used with a different signature for the value, and the message signed is the next signature. E.g.:


```
stack:
<sig B>
<key A>
<sig^IKEY(sig A)>
<sig^A(sig B)>

DUP TOALT
IKEY CSFS VERIFY
FROMALT

stack:
<sig B>
<key A>
<sig^A(sig B)>

ROT ROT CSFS VERIFY

```

This laddering is convenient, because the first IKEY sig commits to the roles of
all the other data (key v.s. sig v.s. argument).

## CTV-CSFS with derived internal keys solution

For Lightning Symmetry, each update transaction is signed with a specific
monotonically increasing locktime, and nothing requires the internal key to be
exactly the same for each update, so we can replace the internal key with a
key deterministically derived from the channel key and the locktime, and then
almost use the naive CTV-CSFS scripts:
```
internalkey(n):
bip32_derive(musig(keyA, keyB), /<S+n+1>)
script(n):
CTV 2DUP EQUAL NOT VERIFY ROT SWAP IKEY CSFS VERIFY IKEY CSFS VERIFY <S+n+1> CLTV
channel:
tr(musig(keyA, keyB), raw(<script(0)>))
update:
tr(internalkey(n), raw(DEPTH NOTIF <settlement-n-hash> CTV ELSE <script(n)> ENDIF))
update-stack:
<settlement-n-sig> <update-n-sig> <settlement-n-hash> <update-n-hash>
```

Either channel partner can deterministicaly derive the correct internal key
needed to reconstruct the spend stack from any update from the locktime of the
update transaction itself. These derived internal keys are only used to sign
one pair of update and settlement hash, and the script checks that the two
signatures are for different data.


## Conclusion

These techniques remove the need for bitcoin upgrade proposals which enable
Lightning Symmetry to include a specific function for committing to multiple
items with a single signature. Of course if a more efficient method for
combining items into a single commitment is available Lightning developers
will be able to take advantage of it and reduce the witness space required for
Lightning Symmetry.