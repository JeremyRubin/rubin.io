---
comments: True
disqusId: 3d15c3e24acd5794eec1f2637d1a842936617b23 
layout: post
title: Quantum Proofing Bitcoin with a CAT
subtitle: no cats harmed in the making of this post
date: 2021-07-06
permalink: /blog/2021/07/06/quantum-bitcoin/
hashtags: [Bitcoin, Quantum]
---

I recently published [a blog
post](https://rubin.io/blog/2021/07/02/signing-5-bytes/) about signing up to a
5 byte value using Bitcoin script arithmetic and Lamport signatures.

By itself, this is neat, but a little limited. What if we could sign longer
messages? If we can sign up to 20 bytes, we could sign a HASH160 digest which
is most likely quantum safe...

What would it mean if we signed the HASH160 digest of a signature? What the
what? Why would we do that?

Well, as it turns out, even if a quantum computer were able to crack ECDSA, it
would yield revealing the private key but not the ability to malleate the
content of what was actually signed.  I asked my good friend and cryptographer
[Madars Virza](https://madars.org/) if my intuition was correct, and he
confirmed that it should be sufficient, but it's definitely worth closer
analysis before relying on this. While the ECDSA signature can be malleated to a
different, negative form, if the signature is otherwise made immalleable there
should only be one value the commitment can be opened to.

If we required the ECDSA signature be signed with a quantum proof signature
algorithm, then we'd have a quantum proof Bitcoin! And the 5 byte signing scheme
we discussed previously is a Lamport signature, which is quantum secure.
Unfortunately, we need at least 20 contiguous bytes... so we need some sort of
OP\_CAT like operation.

OP\_CAT can't be directly soft forked to Segwit v0 because it modifies the
stack, so instead we'll (for simplicity) also show how to use a new opcode that
uses verify semantics, OP\_SUBSTRINGEQUALVERIFY that checks a splice of a string
for equality.

> Fun Fact: OP\_CAT existed in Bitcoin untill 2010, when Satoshi "secretly"
> forked out a bunch of opcodes. So in theory the original Bitcoin implementation
> supported Post Quantum cryptography out of the box!

```
... FOR j in 0..=5
    <0>
    ... FOR i in 0..=31
        SWAP hash160 DUP <H(K_j_i_1)> EQUAL IF DROP <2**i> ADD ELSE <H(K_j_i_0)> EQUALVERIFY ENDIF
    ... END FOR
    TOALTSTACK
... END FOR

DUP HASH160

... IF CAT AVAILABLE
    FROMALTSTACK
    ... FOR j in 0..=5
        FROMALTSTACK
        CAT
    ... END FOR
    EQUALVERIFY
... ELSE SUBSTRINGEQUALVERIFY AVAILABLE
    ... FOR j in 0..=5
        FROMALTSTACK <0+j*4> <4+j*4> SUBSTRINGEQUALVERIFY DROP DROP DROP
    ...  END FOR
    DROP
... END IF

<pk> CHECKSIG
```

That's a long script... but will it fit? We need to verify 20 bytes of message
each bit takes around 10 bytes script, an average of 3.375 bytes per number
(counting pushes), and two 21 bytes keys = 55.375 bytes of program space and 21
bytes of witness element per bit.

It fits! `20*8*55.375 = 8860`, which leaves 1140 bytes less than the limit for
the rest of the logic, which is plenty (around 15-40 bytes required for the rest
of the logic, leaving 1100 free for custom signature checking). The stack size
is 160 elements for the hash gadget, 3360 bytes.

This can probably be made a bit more efficient by expanding to a ternary
representation.

```
        SWAP hash160 DUP <H(K_j_i_0)> EQUAL  IF DROP  ELSE <3**i> SWAP DUP <H(K_j_i_T)> EQUAL IF DROP SUB ELSE <H(K_j_i_1)> EQUALVERIFY ADD  ENDIF ENDIF
```

This should bring it up to roughly 85 bytes per trit, and there should be 101
trits (`log(2**160)/log(3) == 100.94`), so about 8560 bytes... a bit cheaper!
But the witness stack is "only" `2121` bytes...

As a homework exercise, maybe someone can prove the optimal choice of radix for
this protocol... My guess is that base 4 is optimal!

## Taproot?

What about Taproot? As far as I'm aware the commitment scheme (`Q = pG + hash(pG
|| m)G`) can be securely opened to m even with a quantum computer (finding `q`
such that `qG = Q` might be trivial, but suppose key path was disabled, then
finding m and p such that the taproot equation holds should be difficult because
of the hash, but I'd need to certify that claim better).  Therefore this
script can nest inside of a Tapscript path -- Tapscript also does not impose a
length limit, 32 byte hashes could be used as well.

Further, to make keys reusable, there could be many Lamport keys comitted inside
a taproot tree so that an address could be used for thousands of times before
expiring. This could be used as a measure to protect accidental use rather than
to support it.

Lastly, Schnorr actually has a stronger non-malleability property than ECDSA,
the signatures will be binding to the approved transaction and once Lamport
signed, even a quantum computer could not steal the funds.





