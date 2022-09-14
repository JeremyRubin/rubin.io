---
comments: True
disqusId: 65a34534ce63ddf62d5037f22efab2e8c3dbfc93
layout: post
title: "Spookchains: Implementing Drivechains with Trusted Setup & APO"
date: 2022-09-14
hashtags: [Bitcoin, AdventCalendar]
---

This post draws heavily from Zmnscpxj's fantastic post showing how to
make drivechains with recursive covenants. In this post, I will show
similar tricks that can accomplish something similar using ANYPREVOUT
with a one time trusted setup ceremony.

This post presents general techniques that could be applied to many
different types of covenant.

_note: I originally wrote this around May 5th, 2022, and shared it with a
limited audience_

# Peano Counters

The first component we need to build is a Peano counter graph. Instead
of using sha-256, like in Zmnscpxj's scheme, we will use a key and
build a simple 1 to 5 counter that has inc / dec.

Assume a key K1...K5, and a point NUMS which is e.g.
HashToCurve("Spookchains").

Generate scripts as follows:

```
<1 || K1> CHECKSIG
...
<1 || K5> CHECKSIG
```

Now generate 2 signatures under Ki with flags `SIGHASH_SINGLE |
SIGHASH_ANYONECANPAY | SIGHASH_ANYPREVOUT`.


## Rule Increment
For each Ki, when `i < 5`, create a signature that covers a
transaction described as:

```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K{i+1}> CHECKSIG})
```

## Rule Decrement
For each Ki, when `i > 1` The second signature should cover:
```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K{i-1}> CHECKSIG})
```



_Are these really Peano?_ Sort of. While a traditional Peano numeral
is defined as a structural type, e.g. `Succ(Succ(Zero))`, here we
define them via a Inc / Dec transaction operator, and we have to
explicitly bound these Peano numbers since we need a unique key per
element. They're at least spiritually similar.

## Instantiation
Publish a booklet of all the signatures for the Increment and
Decrement rules.

Honest parties should destroy the secret key sets `k`.


To create a counter, simply spend to output C:

```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K1> CHECKSIG})
```


The signature from K1 can be bound to C to 'transition' it to (+1):

```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K2> CHECKSIG})
```

Which can then transition to (+1):

```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K3> CHECKSIG})
```

Which can then transition (-1) to:

```
Amount: 1 satoshi
Key: Tr(NUMS, {<1 || K2> CHECKSIG})
```

This can repeat indefinitely.


We can generalize this technique from `1...5` to `1...N`.



# Handling Arbitrary Deposits / Withdrawals


One issue with the design presented previously is that it does not
handle arbitrary deposits well.

One simple way to handle this is to instantiate the protocol for every
amount you'd like to support.

This is not particularly efficient and requires a lot of storage
space.

Alternatively, divide (using base 2 or another base) the deposit
amount into a counter utxo per bit.

For each bit, instead of creating outputs with 1 satoshi, create
outputs with 2^i satoshis.

Instead of using keys `K1...KN`, create keys `K^i_j`, where i
represents the number of sats, and j represents the counter. Multiple
keys are required per amount otherwise the signatures would be valid
for burning funds.

## Splitting and Joining

For each `K^i_j`, it may also be desirable to allow splitting or
joining.

Splitting can be accomplished by pre-signing, for every `K^i_j`, where
`i!=0`, with `SIGHASH_ALL | SIGHASH_ANYPREVOUT`:

```
Input: 2^i sats with key K^i_j
Outputs: 
    - 2^i-1 sats to key K^{i-1}_j
    - 2^i-1 sats to key K^{i-1}_j
```

Joining can be accomplished by pre-signing, for every `K^i_j`, where
`i!=MAX`, with `SIGHASH_ALL | SIGHASH_ANYPREVOUT`:

```
Inputs:
    - 2^i sats with key K^i_j
    - 2^i sats with key K^i_j
Outputs: 
    - 2^i+1 sats to key K^{i+1}_j
```

N.B.: Joining allows for third parties to deposit money in externally,
that is not a part of the covenant.


The splitting and joining behavior means that spookchain operators
would be empowered to consolidate UTXOs to a smaller number, while
allowing arbitrary deposits.


# One Vote Per Block

To enforce that only one vote per block mined is allowed, ensure that
all signatures set the input sequence to 1 block. No CSV is required
because nSequence is in the signatures already.

# Terminal States / Thresholds

When a counter reaches the Nth state, it represents a certain amount
of accumulated work over a period where progress was agreed on for
some outcome.

There should be some viable state transition at this point.

One solution would be to have the money at this point sent to an
`OP_TRUE` output, which the miner incrementing that state is
responsible for following the rules of the spookchain. Or, it could be
specified to be some administrator key / federation for convenience,
with a N block timeout that degrades it to fewer signers (eventually
0) if the federation is dead to allow recovery.

This would look like, from any `K^i_j`, a signature for a transaction
putting it into an `OP_TRUE` and immediately spending it. Other
spookchain miners would be expected to orphan that miner otherwise.


# Open States / Proposals

From a state `K^i_1`, the transaction transitioning to `K^i_2` can be
treated as 'special' and the `OP_RETURN` output type can be used to
commit to, e.g., the outputs that must be created in when the Terminal
State is reached. This clarifies the issue of "what is being voted
on".

This method does not *lock in* at a consensus layer what Terminal
State is being voted on.

In certain circumstances, without violating the one-time-setup
constraint, if a fixed list of withdrawer's addresses is known in
advance, the Open States could cover withdrawals to specific
participants, which then must collect a certain number of votes from
miners.  However, it seems impossible, without new primitives, for an
arbitrary transaction proposal to be voted on.

# Setup Variants

## xpubs

Instead of using randomly generated keys for each state, define each
to be an xpub and derive a path where it is k/i/j for each
state/satoshi amount. This saves some data, and also requires less
entropy.

### Trustless Data Commit:

commit to the hash of the entire program spec as a tweak to the xpub,
so that someone can quickly verify if they have all the signatures you
are expected to generate if honest.

One way to do this is to convert a hash to a list of HD Child Numbers
(9 of them) deterministically, and tweak the xpub by that. This is a
convenient, yet inefficient, way to tweak an xpub because the child
has a normal derivation path for signing devices.

## Single Party

A single party pre-signs all the transactions for the spookchain, and
then deletes their xpriv.

You trust them to have deleted the key, and signed properly, but you
do not trust whoever served you the spookchain blob to have given you
all the state transitions because of the trustless data commitment.

## MuSig Multi-Party

Define a MuSig among all participants in the setup ceremony, N-of-N.

Now you simply trust that any one person in the one-time-setup was
honest! Very good.

## Unaggregated Multi-Party


Allow for unaggregated multi-sig keys in the spec. This grows with
O(signers), however, it means that a-la-carte you can aggregate setups
from random participants who never interacted / performed setup
ceremonies independently if they signed the same specs.

Can also combine multiple MuSig Multi-Parties in this way.

This is nice because MuSig inherently implies the parties colluded at
one point to do a MuSig setup, whereas unaggregated multi-sig could be
performed with no connectivity between parties.

## Soft Forking Away Trust

Suppose a spookchain becomes popular. You could configure your client
to reject invalid state transitions, or restrict the spookchain keys
to only sign with the known signatures. This soft fork would smoothly
upgrade the trust assumption.

## Symmetry of State Transition Rules & DAG Covenants

We could have our increment state transitions be done via a trustless
covenant, and our backwards state transitions be done via the setup.

This would look something like the following for state i:

```
Tr(NUMS, {
    `<sig for state K_{i+1}> <1 || PK_nonsecret> CHECKSIG`,
    `<1 || Ki> CHECKSIG`
})
```

The advantage of such an optimization is theoretically nice because it
means that *only* the non-destructuring recursive part of the
computation is subject to the one-time-setup trust assumption, which
might be of use in various other protocols, where recursivity might
only be unlocked e.g. after a timeout (but for spookchains it is used
at each step).

A compiler writer might perform this task by starting with an arbitrary
abstract graph, and then removing edges selectively (a number of heuristics may
make sense, e.g., to minimize reliance on one-time-setup or minimize costs)
until the graph is a Directed Acyclic Graph, consisting of one or more
components, compiling those with committed covenants, and then adding the
removed edges back using the one-time-setup key materials.


# Commentary on Trust and Covenantiness

Is this a covenant? I would say "yes". When I defined covenants in my
_Calculus of Covenants_ post, it was with a particular set of
assumptions per covenant.

Under that model, you could, e.g., call a 7-10 multi-sig with specific
committed instructions as 4-10 honest (requires 4 signatories to be
honest to do invalid state transition) and 4-10 killable (requires 4
signatories to die to have no way of recovering).

For emulations that are pre-signed, like the varieties used to emulate
CTV, it is a different model because if your program is correct and
you've pre-gotten the signatures for N-N it is 1-N honest (only 1
party must be honest to prevent an invalid state transition) and
unkillable (all parties can safely delete keys).

I model these types of assumptions around liveness and honesty as
different 'complexity classes' than one another.

What I would point out is that with the counter model presented above,
this is entirely a pre-signed 1-N honest and unkillable covenant that
requires no liveness from signers. Further, with APO, new instances of
the covenant do not require a new set of signers, the setup is truly
one-time. Therefore this type of covenant exists in an even lower
trust-complexity class than CTV emulation via presigneds, which
requires a new federation to sign off on each contract instance.


With that preface, let us analyze this covenant:


1) A set of sets of transaction intents (a family), potentially
recursive or co-recursive (e.g., the types of state transitions that
can be generated).  These intents can also be represented by a
language that generates the transactions, rather than the literal
transactions themselves. We do the family rather than just sets at
this level because to instantiate a covenant we must pick a member of
the family to use.


The set of sets of transaction intents is to increment / decrement to
a successor or predecessor, or to halve into two instances or double
value by adding funds. Each successor or predecessor is the same type
of covenant, with the excetion of the first and last, which have some
special rules.


2) A verifier generator function that generates a function that
accepts an intent that is any element of one member of the family of
intents and a proof for it and rejects others.

The verifier generator is the simple APO CHECKSIG script.

3) A prover generator function that generates a function that takes an
intent that is any element of one member of the family and some extra
data and returns either a new prover function, a finished proof, or a
rejection (if not a valid intent).

The prover generator is the selection of the correct signature from a
table for a given script.

Run the prover generator with the private keys present *once* to
initialize over all reachable states, and cache the signatures, then
the keys may be deleted for future runs.

4) A set of proofs that the Prover, Verifier, and a set of intents are
"impedance matched", that is, all statements the prover can prove and
all statements the verifier can verify are one-to-one and onto (or
something similar), and that this also is one-to-one and onto with one
element of the intents (a set of transactions) and no other.

At a given key state the only things that may happen are signed
transactions, no other data is interpreted off of the stack. Therefore
there is perfect impedance match.


5) A set of assumptions under which the covenant is verified (e.g., a
multi-sig covenant with at least 1-n honesty, a multisig covenant with
any 3-n honesty required, Sha256 collision resistance, Discrete Log
Hardness, a SGX module being correct).

Uniquely, that during the setup phase at least one of the keys
were faithfully deleted.

The usual suspects for any bitcoin transaction are also assumed for
security.


6) Composability:

The Terminal State can pay out into a pre-specified covenant if
desired from any other family of covenants.

