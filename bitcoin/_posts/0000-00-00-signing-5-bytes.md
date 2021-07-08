---
comments: True
disqusId: 4d29ec4a631014c3e615fbbdc0205862836c1536
layout: post
title: CheckSigFromStack for 5 Byte Values
date: 2021-07-02
permalink: /blog/2021/07/02/signing-5-bytes/
---

I recently published [a blog post](https://rubin.io/blog/2021/07/02/covenants/)
about covenants on Bitcoin.

Readers were quick to point out I hadn't
fully explained myself on a claim I made that you can do a form of
CheckSigFromStack in Bitcoin today.

So I thought it would be worthwhile to fully describe the technique -- for the
archives.

There are two insights in this post:

1. to use a bitwise expansion of the number 
2. to use a lamport signature

Let's look at the code in python and then translate to bitcoin script:

```python
def add_bit(idx, preimage, image_0, image_1):
    s = sha256(preimage)
    if s == image_1:
        return (1 << idx)
    if s == image_0:
        return 0
    else:
        assert False

def get_signed_number(witnesses : List[Hash], keys : List[Tuple[Hash, Hash]]):
    acc = 0
    for (idx, preimage) in enumerate(witnesses):
        acc += add_bit(idx, preimage, keys[idx][0], keys[idx][1])
    return x
```

So what's going on here? The signer generates a key which is a list of pairs of
hash images to create the script. 

To sign, the signer provides a witness of a list of preimages that match one or the other.

During validation, the network adds up a weighted value per preimage and checks
that there are no left out values.

Let's imagine a concrete use case: I want a third party to post-hoc sign a sequence lock. This is 16 bits.
I can form the following script:


```
<pk> checksigverify
0
SWAP sha256 DUP <H(K_0_1)> EQUAL IF DROP <1> ADD ELSE <H(K_0_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_1_1)> EQUAL IF DROP <1<<1> ADD ELSE <H(K_1_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_2_1)> EQUAL IF DROP <1<<2> ADD ELSE <H(K_2_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_3_1)> EQUAL IF DROP <1<<3> ADD ELSE <H(K_3_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_4_1)> EQUAL IF DROP <1<<4> ADD ELSE <H(K_4_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_5_1)> EQUAL IF DROP <1<<5> ADD ELSE <H(K_5_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_6_1)> EQUAL IF DROP <1<<6> ADD ELSE <H(K_6_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_7_1)> EQUAL IF DROP <1<<7> ADD ELSE <H(K_7_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_8_1)> EQUAL IF DROP <1<<8> ADD ELSE <H(K_8_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_9_1)> EQUAL IF DROP <1<<9> ADD ELSE <H(K_9_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_10_1)> EQUAL IF DROP <1<<10> ADD ELSE <H(K_10_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_11_1)> EQUAL IF DROP <1<<11> ADD ELSE <H(K_11_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_12_1)> EQUAL IF DROP <1<<12> ADD ELSE <H(K_12_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_13_1)> EQUAL IF DROP <1<<13> ADD ELSE <H(K_13_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_14_1)> EQUAL IF DROP <1<<14> ADD ELSE <H(K_14_0)> EQUALVERIFY ENDIF
SWAP sha256 DUP <H(K_15_1)> EQUAL IF DROP <1<<15> ADD ELSE <H(K_15_0)> EQUALVERIFY ENDIF
CHECKSEQUENCEVERIFY
```

In order to sign a 16 bit value V, the owner of K simply puts on the stack the
binary representation of V indexed into the K. E.g., to sign `53593`, first
expand to binary `0b1101000101011001`, then put the appropriate K values on the
stack.

```
K_15_1
K_14_1
K_13_0
K_12_1
K_11_0
K_10_0
K_9_0
K_8_1
K_7_0
K_6_1
K_5_0
K_4_1
K_3_1
K_2_0
K_1_0
K_0_1
<sig>
```


This technique is kind of bulky! It's around 80x16 = 1280 length for the
gadget, and 528 bytes for the witnesses. So it is _doable_, if not a bit
expensive. There might be some more efficient scripts for this -- would a
trinary representation be more efficient? 

The values that can be signed can be range limited either post-hoc (using
OP\_WITHIN) or internally as was done with the 16 bit value circuit where it's
impossible to do more than 16 bits.

Keys *can* be reused across scripts, but signatures may only be constructed one
time because a third party could take two signed messages and construct an
unintended value (e.g., if you sign both 4 and 2 then a third party could
construct 6).

There are certain applications where this could be used for an effect -- for
example, an oracle might have a bonding contract whereby posessing any K\_i\_0
and K\_i\_1 allows the burning of funds.
