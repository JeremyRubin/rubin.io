---
comments: True
disqusId: a47edcaabae72f624490ce7f0fb78bab5c3998b3
layout: project
title: TXGL 
subtitle: Transaction Graphical Language
pic: /public/img/txgl/txgl_logo.png
date: 2017-01-28
---

TXGL is a graphical framework, loosely based on circuit diagrams, for describing
multi-transaction Bitcoin Contracts.

_You can download the TXGL SVG template [here]({{site.baseurl}}/public/img/txgl/txgl.svg)._

_This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-sa/4.0/)._


## Why TXGL

When discussing cryptocurrency protocols, it can often be very difficult to
describe to others what's going on.

[Chain](https://chain.com) is doing some awesome work on Ivy, which is a
higher-level language that can compile to bitcoin scripts, which not only helps
build scripts, but helps others understand them as well.

However, complexity in Bitcoin hides not only at the script level, but also at
the transaction level.

TXGL is an attempt to create a visual diagram language for sketching out
transactions pictorially. I originally began working on TXGL as I prepared my
talk for [BPASE 2017](https://cyber.stanford.edu/blockchainconf) as I struggled
to clearly communicate the ideas I was presenting. The diagrams went a long way
for my talk, and afterwards there was significant interest in TXGL as a
stand-alone work, so I decided to try to better document how to read and
construct TXGL diagrams.

One of the key insights of TXGL is to draw (loosely) from EE schematics as a form
of "transaction circuit diagram". Each component in the diagram represents
something that _could_ appear on the blockchain during execution. This is an
important point.  There are many considerations in actually executing such
complex multi-transaction contracts, such as program storage, deadlocks, and
multi-party construction/negotation. I've covered some of these complexities in
my BPASE talk.

TXGL is by no means a finished product, but hopefully by putting it out there,
the academic community can begin experimenting with it as a rough standard and
provide feedback on how to improve! 😁


## TXGL Standard

One of the issues that arises when describing multi-transaction bitcoin
contracts is that the distinction between the terms _input_ and _output_ is not
clear. This disturbing lack of clarity is because during a transaction, a set
of unspent outputs are treated the set of inputs and create a new set of
unspent outputs. But what is an input? Is it a spent output? Not quite, the
input is a reference to the unspent output.  This concept is difficult to
disambiguate orally and graphically.  Instead of using terminology which can be
misunderstood, we will instead refer to either an input or an output as a
transaction component when it is not being created or consumed specifically.

![An isolated transaction component]({{site.baseurl}}/public/img/txgl/component.png){: .center-image-plain}

A component should have a label. A component without a label shouldn't be
referred to in any accompanying text. Labels allow us to template out (in the
c++ sense) generalizable information. For instance, a component could be
"spent" via an M-of-N script or via a direct P2PKH. If the information is
pertinent, it's preferable to include it in an accompanying table rather than
jam it into the diagram (an Asterisk on the label can be used to emphasize that
there is more information needed).


Each component (may) have a set of arrows pointing into it. An inwards arrow
shows how the component was created. If there is no such arrow, then the source
of the component is irrelevant.


Each component (may) have a single arrow\* pointing out of it. An outwards arrow
shows how the component will be used. It is important to note that it may be
possible that the component has other possible outwards arrows! An outward
arrow does not "guarantee" execution, it only demonstrates intended spend.


An arrow between two components composes a transaction.

![A basic transaction]({{site.baseurl}}/public/img/txgl/transaction.png){: .center-image-plain}



### Special Components

There are a few special types of component that have some additional rules.

#### Multiplexer "Select One" Component

A mux component takes in wires through the side-port, and emits only one of it's branches.
Above each black arrow, an optional condition can be placed. One such condition must be satisfied
in order for the spend to occur (essentially, a kind of "switch" statement).

![A mux]({{site.baseurl}}/public/img/txgl/or_outputs.png){: .center-image-plain}

You can think of this as being like the following bitcoin script.

`OP_DUP <0> OP_EQUAL OP_IF A OP_ELSE OP_DROP OP_DUP <1> OP_IF B OP_ELSE ... OP_ENDIF OP_ENDIF OP_VERIFY`

It is important to note that a bijection between conditions and outputs IS
NOT ENFORCED by the mux component natively.  Thus, one must consider the mux
component as a list of possible spend conditions and a list of outputs which
could occur under the intended execution. One must layer in some additional
logic to ensure the bijection, and layer in further logic to ensure that one
branch must be taken. This will be demonstrated in the "TXGL Extensions" section.

#### Demultiplexer "Select All" Component

A demux takes in wires through the side-port and is intended to emit all of
it's outputs. Again, bijection is not guaranteed and the engineer must be careful to
ensure that this is the case.

![A demux]({{site.baseurl}}/public/img/txgl/and_outputs.png){: .center-image-plain}

This is essentially the following Bitcoin Script:

`P_1 OP_VERIFY P_2 OP_VERIFY ... P_N OP_VERIFY`

### TXGL Extensions
These extensions depend on new features in Bitcoin, which are all well within
the realm of possibility. I'm not completely pleased with the graphical
representations here, but they are a start.

#### Covenant
We allow adding a constraint of a covenant to specify some invariant that must hold of the output.

![]({{site.baseurl}}/public/img/txgl/covenant.png){: .center-image-plain}

#### Join Covenant

A component with a dome hat is generated by what we'll call a Join Covenant.

![]({{site.baseurl}}/public/img/txgl/input_join_component.png){: .center-image-plain}

In a Join Covenant, it is restricted that the input components must be spent together.

This is a property which could be correct either by construction (ie, the only
component signed by N-of-N for each input) or by computation (the inputs script
checks a property).

![]({{site.baseurl}}/public/img/txgl/input_join.png){: .center-image-plain}




_Partial Join_

In the case where only one input component depends on the others, a dotted
arrow pointing upwards can be made.
![]({{site.baseurl}}/public/img/txgl/partial_input_join.png){: .center-image-plain}

#### Virtual and Intermediate Components

In many cases, an output is a "temporary" value -- that is, it is meant to be
spent atomically with it's parent.

In this case, the component should be drawn with a dashed border.
![]({{site.baseurl}}/public/img/txgl/virtual_component.png){: .center-image-plain}

An example of such a component being used is as follows:

![]({{site.baseurl}}/public/img/txgl/virtual.png){: .center-image-plain}

In the above example, B must be consumed for A to be validly consumed.



#### Impossible Component Covenant

It is possible to make a transaction depend on a proof that a component could not be constructed.

We draw an "un-constructible" component as follows:

![]({{site.baseurl}}/public/img/txgl/not_component.png){: .center-image-plain}

Naively, this can be done in Bitcoin by emitting an output component on spend
which is consumed by dependents of that output. Such a dependent impossible
component covenant can be drawn as follows:

![]({{site.baseurl}}/public/img/txgl/impossible_constructive.png){: .center-image-plain}

Note that we still black-out and complement the component for clarity, although
clearly this sentinel-value output is possible to construct.

An impossible component covenant could also be implemented as an introspective proof on the blockchain, as in:

1. Specify a component $$I$$ desired to be proved impossible 
1. Provide witness of how to construct $$I$$
1. Provide witness of another component $$R$$ that already exists which shares
has an ancestor input $$A$$ that $$I$$ must consume in it's construction.
1. If $$R$$ consumes $$A$$, this implies that $$I$$ cannot also consume $$A$$
1. Therefore, $$I$$ is impossible to construct because $$R$$ exists.

For this construction, we won't actually show how the proof is constructed.

![]({{site.baseurl}}/public/img/txgl/impossible.png){: .center-image-plain}

Relatedly, the trivial case of this proof is a _Consumed Output Proof_, which
is simply a proof that some component has been spent.


#### Sequentially Existent Output Covenant

Similarly, it is possible to simply require that an input component does exist.

The simplest way to implement this in Bitcoin, is via a transaction which
recreates one of its inputs.

Requiring this is possible with simple covenants (Russel O'Conner has
demonstrated a quine).

Such an observation is said to be Sequential, because observing the existence
of the component serves to consume it, and re-emit it with a different txid,
thus forcing an ordering of operations.

#### Conditional Covenant

Using a Multiplexer component and two covenants, we can construct a component which is guaranteed to select one of it's outputs:

![]({{site.baseurl}}/public/img/txgl/conditional_component.png){: .center-image-plain}


#### Execution

In order to highlight what path through the multi-transaction contract is
actually taken, red highlights can be used.

![]({{site.baseurl}}/public/img/txgl/execution.png){: .center-image-plain}


### Examples

#### Covenant MAST

This contract allows for $$O(log(n))$$ program compression by hashed branch elimination.

![]({{site.baseurl}}/public/img/txgl/mast_covenant.png){: .center-image-plain}


#### Optical Isolation Contract

Much like sensitive electronics can isolate components using an optical isolator, we 
can build bitcoin contracts which isolate value from control flow. In the
diagram below, $$M_0$$ provides the fee amount (like Gas in Ethereum) and
$$M_1$$ provides the value. $$M_1$$ cannot spend to $$G$$ unless it is proven
that the protocol can no longer progress to $$F$$.

![]({{site.baseurl}}/public/img/txgl/isolated.png){: .center-image-plain}


The below figure demonstrates the possible executions:

![]({{site.baseurl}}/public/img/txgl/isolated_executions.png){: .center-image-plain}


## Future Work

There are certainly more things to be able to add to TXGL. This is a rough
working list of things I'll hopefully add in the coming weeks.

1. Locktimes/CSV
1. [MULTIINPUT](https://arxiv.org/abs/1612.05390)
1. SIGHASH\_ANYONECANPAY


_You can download the TXGL SVG template [here]({{site.baseurl}}/public/img/txgl/txgl.svg)._
