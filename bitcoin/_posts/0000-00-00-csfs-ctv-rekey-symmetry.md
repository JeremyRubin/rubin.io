---
comments: True
disqusId: b2e599366ec42732af04508978f7c91203a2308d
layout: post
title: "CSFS Re-Keying and Laddering, Deterministic Update Rekeying, & Applications to LN-Symmetry"
date: 2024-12-02
---

_This is a collab post with [Rearden](https://twitter.com/reardencode)._

As Rearden talked about at Bitcoin++ in Austin this year, there are many ways
to realize Lightning Symmetry using various bitcoin upgrade proposals. All of
these methods require either an extra signing round-trip for each channel
update, or the ability to force the hash of the settlement transaction to be
visible with its corresponding update transaction. This can be generalized as
the requirement that the signature authorizing a given channel be both
rebindable (i.e. not commit to a specific prior UTXO) and commit to some
additional data being visible for that signature to be valid.

We'll start by exploring why Lightning Symmetry requires this data visibility
commitment, then dive into previously known solutions, and finally present a
new solution we've developed to enable Lightning Symmetry using one extra
signature, but no extra signing round-trip and without the need for
concatenation or other explicit multi-commitments.


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
DUP TOALT DUP TOALT IKEY CSFS VERIFY CTV 2DUP EQUAL NOT VERIFY ROT SWAP FROMALT CSFS VERIFY FROMALT CSFS VERIFY <S+n+1> CLTV
channel:
tr(musig(keyA, keyB), raw(<script(0)>))
update(n):
tr(musig(keyA, keyB), raw(DEPTH NOTIF <settlement-n-hash> CTV ELSE <script(n)> ENDIF))
stack:
<settlement-n-sig> <update-n-sig> <settlement-n-ctv> <update-n-ctv> <rekey-sig> <rekey>
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
