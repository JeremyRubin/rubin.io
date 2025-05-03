---
comments: True
disqusId: 3a25fabba41aaf8f963d9c3e3c44c0eb20a5f6b9 
layout: post
title: "Delegated signatures in Bitcoin within existing rules, no fork required (Connector Outputs)"
date: 2021-03-10
---

_This originally appeared on the [mailing list](https://gnusha.org/pi/bitcoindev/CAD5xwhhC1Y13p7KazfUOXFZ5vi5MA9EQ-scyafv4aNkjskoXBg@mail.gmail.com/), and has been edited lightly for some updates in 2025._

I'm aware that some folks (I think nullc, sipa, myself... maybe more?) are
aware of how to do script delegation in Bitcoin today (without any
modifications to Bitcoin), but realized in a conversation with Andrew P
that the technique is not widely known. So I figured it made sense to do a
brief explainer of how this works for the archives / so the technique is
documented. If someone has other citations for this, please let me know. This 
technique is now popular in BitVM and in Ark.

If you like cartoons follow along [here](https://docs.google.com/presentation/d/1ikcthy3p-Ah59pJyss0TLEj-Q2FF6tv7BXhkORzErAE/edit#slide=id.p).

Technically what we are doing is delegating a UTXO to a specific UTXO, and
not to a script.


Suppose you have a coin on UTXO A. You would like to delegate it to script
S. You can either scan the chain for any UTXOs bound to S or use some
arbitrary coin B to create a transaction X with an output D that has script
S (doesn't have to have any value, but let's say it has a nominal amount to
avoid dust issues). Because tx X is not malleable, we don't need to
actually broadcast it and spend B till we want to use the delegation, and
it can be created (for the TXID) without B's owner being online. However
you get the UTXO, and if it exists or not yet, let's call it D.

*Note: if you're using a delegation script multiple times, you can optimize
the creation step a bit*

Now, using A, you sign a transaction with 2 inputs (one of them being D)
and SIGHASH_NONE. This signs all of the inputs (but not their sequences!)
but none of the outputs. Let's call this transaction stub G.

Now, using S, you sign D's input on G with SIGHASH_ALL and the outputs you
want to create (whatever they may be). Let's call the finished transaction
F.

Effectively, the holder of A has delegated the control of their coin to a
specific instance of the script S. Once delegated, S may authorize almost
any transaction they want (complicated if they want to sign a multiple
input transaction; but there are good substitutes).

Advanced Topics:

*Revocation*: There are multiple ways to revoke, either moving A, moving D,
refusing to sign and create D (when D is derived from B), etc. Because
these are UTXO-bound they are revocable. (the cartoon may help here)
*Cross input delegation*: A set of N coins may create a sighash_none
transaction with 1 additional input for the delegating script
*Partial Spending Authorizations*: Replacing sighash_none with
sighash_single allows an input to specify a single change address (plug --
OP_CTV covenants can be thought of as a way to get around sighash_single to
allow sighash_single to cover signing a set of outputs)
*Delegation after time*: Because the lock_time field is covered,
delegations can be set up to only be valid at some point in the future.
Only a single sequence lock per delegated coin may be used directly.
*Multiple Delegates: *By signing a txn with several delegate outputs, it is
possible to enforce multiple disparate conditions. Normally this is
superfluous -- why not just concatenate S1 and S2? The answer is that you
may have S1 require a relative height lock and S2 require a relative time
lock (this was one of the mechanisms investigated for powswap.com).
*Sequenced Contingent Delegation*: By constructing a specific TXID that may
delegate the coins, you can make a coin's delegation contingent on some
other contract reaching a specific state. For example, suppose I had a
contract that had 100 different possible end states, all with fixed
outpoints at the end. I could delegate coins in different arrangements to
be claimable only if the contract reaches that state. Note that such a
model requires some level of coordination between the main and observing
contract as each Coin delegate can only be claimed one time.
*CTV Specific P2SH Non Coin Delegation: *OP_CTV allows for a similar form
of delegation where by a Segwit P2SH address, as a part of the CTV
committed data, can be used without binding it to any specific UTXO. With
the addition of OP_CAT, it would be possible to both programmatically
change the outputs (rather than just approving the fixed txn) and to
dynamically select the script.
*Redelegating: *This is where A delegates to S, S delegates to S'. This
type of mechanism most likely requires the coin to be moved on-chain to the
script (A OR S or S'), but the on-chain movement may be delayed (via
presigned transactions) until S' actually wants to do something with the
coin.

There are obviously many other things you can do with delegation in
general, the above are specific to how coin delegation is done. I'm
probably missing some of the fun stuff -- please riff on this!
