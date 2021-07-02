---
comments: True
disqusId: 44f7db5bc4b35bf7c51d7d5cb460919dadfd72bb
layout: post
title: Templates, Eltoo, and Covenants, Oh My! 
date: 2021-07-02
---

![](/public/img/post-covenant-meme.png)

If you've been following The Discourse, you probably know that Taproot is
merged, locked in, and will activate later this November. What you might not
know is what's coming next... and you wouldn't be alone in that. There are a
number of fantastic proposals floating around to further improve Bitcoin, but
there's no clear picture on what is ready to be added next and on what
timeline. No one -- core developer, technically enlightened individuals, power
users, or plebs -- can claim to know otherwise.


In this post I'm going to describe 4 loosely related possible upgrades to
Bitcoin -- SH_APO (BIP-118), OP_CAT, OP_CSFS, and OP_CTV (BIP-119). These four
upgrades all relate to how the next generation of stateful smart contracts can
be built on top of bitcoin. As such, there's natural overlap -- and competition
-- for mindshare for review and deployment. This post is my attempt to stitch
together a path we might take to roll them out and why that ordering makes
sense. This post is for developers and engineers building in the Bitcoin space,
but is intended to be followable by anyone technical or not who has a keen
interest in Bitcoin.


## Bitcoin Eschews Roadmaps and Agendas.


I provide this maxim to make clear that this document is by no means an
official roadmap, narrative, or prioritization. However, it is my own
assessment of what the current most pragmatic approach to upgrading Bitcoin is,
based on my understanding of the state of outstanding proposals and their
interactions.


My priorities in producing this are to open a discussion on potential new
features, risk minimization, and pragmatic design for Bitcoin.


### Upgrade Summaries


Below follows summaries of what each upgrade would enable and how it works. You
might be tempted to skip it if you're already familiar with the upgrades, but I
recommend reading in any case as there are a few non obvious insights.


#### APO: SIGHASH_ANYPREVOUT, SIGHASH_ANYPREVOUTANYSCRIPT


Currently proposed as
[BIP-118](https://github.com/bitcoin/bips/blob/d616d5492bc6e6566af1b9f9e43b660bcd48ca29/bip-0118.mediawiki). 


APO provides two new signature digest algorithms that do not commit to the coin
being spent, or the current script additionally. Essentially allowing scripts
to use outputs that didn’t exist at the time the script was made. This would be
a new promise enforced by Bitcoin (ex. “You can close this Lightning channel
and receive these coins if you give me the right proof. If a newer proof comes
in later I’ll trust that one instead.”).


APO’s primary purpose is to enable off chain protocols like
[Eltoo](https://blockstream.com/2018/04/30/en-eltoo-next-lightning/), an
improved non-punitive payment channel protocol. 


APO can also
[emulate](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-June/017038.html)
some of the main features of CTV and could be made to work with Sapio,
partially. See the complimentary upgrades section for more detail.


#### CAT (+ variants)


Currently no BIP. However, CAT exists in
[Elements](https://github.com/ElementsProject/elements/blob/bd2e2d5c64d38286b2ca0519f1215bed228e4dcf/src/script/interpreter.cpp#L914-L933)
and [Bitcoin
Cash](https://github.com/bitcoincashorg/bitcoincash.org/blob/3e2e6da8c38dab7ba12149d327bc4b259aaad684/spec/may-2018-reenabled-opcodes.md)
as a 520 byte limited form, so a proposal for Bitcoin can crib heavily from
either.


Cat enables appending data onto other pieces of data. Diabolically simple
functionality that has many advanced use cases by itself and in concert with
other opcodes. There are many "good" use cases of cat like requiring sighash
types, requiring specific R values, etc, but there are too many devious use
cases to list here.


#### CSFS: CHECKSIGFROMSTACK


Currently no BIP. However, CSFS exists in
[Elements](https://github.com/ElementsProject/elements/blob/bd2e2d5c64d38286b2ca0519f1215bed228e4dcf/src/script/interpreter.cpp#L1580-L1618)
and in [Bitcoin
Cash](https://github.com/bitcoincashorg/bitcoincash.org/blob/master/spec/op_checkdatasig.md),
so a proposal for Bitcoin can crib heavily from either.


CSFS enables checking of a signature against a message and key from the stack
without including any transaction data.


Use cases include oracle protocols, key delegations, a [channel update
invalidation
variant](https://stanford2017.scalingbitcoin.org/files/Day1/SB2017_script_2_0.pdf)
(Laolu claims this can be tweaked to be fully non punitive like eltoo, but
you'll need to bug him to write it up), and (+CAT) full covenants.




#### CTV: OP_CHECKTEMPLATEVERIFY


Currently proposed as
[BIP-119](https://github.com/bitcoin/bips/blob/master/bip-0119.mediawiki).


CTV enables committing to a specific "next" transaction from script. This is
the ability to make an unbreakable promise on chain which Bitcoin can enforce
(e.g. “This coin can only be spent to my multisig, or my backup after a
timelock”). This is a departure from normal script which is traditionally only
concerned with restrictions on the sender, CTV imposes restrictions on the
recipient. More technically, CTV is essentially the ability to embed a
signature of a specific transaction inside of a script without needing any
elliptic curve operations. The validation costs are low. For more advanced
logic, you can nest multiple different CTV Hashes either using taproot or up to
the script length limits in regular script.


CTV can be used for vaults, channels, and [many other
uses](https://utxos.org/uses/). There’s also
[Sapio](https://learn.sapio-lang.org) which is a language and toolkit for
creating many kinds of programs with CTV.


CTV compliments CSFS to be able to emulate APO-like functionality
sufficient to build Eltoo, potentially making APO feature-wise redundant.


## Comparative Analysis


Now that we've got the basics covered, let's explore these upgrades
comparatively across several dimensions.


### Design Specificity


"Design Specificity" is a subjective measure of how substantially an upgrade
could change from its current design while still meeting the features goals. It
is not to be confused with security or safety. Ranked in order from most to
least design specific, with non-exhaustive lists of design questions based on
ongoing community discourse as well as my own personal understanding of what
might be desirable.


1. CSFS
2. CTV
3. CAT
4. APO


#### Explanations & Open Questions:
1. CSFS is very simple and there is essentially a single way to implement it. Three open questions are:
   1. Should CSFS require some sort of tagged hash? Very likely answer is no --
      tags interfere with certain use cases)
   2. Should CSFS split the signature's R & S value stack items for some
      applications that otherwise may require OP_CAT? E.g. using a pinned R
    value allows you to extract a private key if ever double signed, using 2 R
    values allows pay-to-reveal-key contracts. Most likely answer is no, if that is
    desired then OP_CAT can be introduced
   3. Should CSFS support a cheap way to reference the taproot internal or
      external key? Perhaps, can be handled with undefined upgradeable
    keytypes. One might want to use the internal key, if the signed data should be
    valid independent of the tapscript tree.  One might want to use the external
    key, if the data should only be valid for a single tapscript key + tree.
2. CTV is a commitment to all data that can malleate TXID besides the inputs
   being spent, therefore CTV does not have much space for variation on design.
   1. Should the digest be reordered or formatted differently? If there were
      more data on what types of covenants might be built in the future, a
    better order could be picked. Some thought has already gone into an order and
    commitments that make covenants easier, see the BIP for more. It's also
    possible the serialization format for the variable length fields (scriptsigs,
    outputs) could be changed to make it easier to work with from script. (Maybe,
    minor change)
   2. Should CTV include more template types? Possibly, CTV includes an upgrade
      mechanism baked in for new template types, so it is extensible for future
    purposes. 
   3. Should CTV commit to the amounts? CTV does not commit to the amount that
      a coin has. Input-inspecting functionality should be handled by separate
    opcodes, as CTV would be overly restrictive otherwise. E.g. dynamic fees
    through new inputs would be harder: given CTV's design it is not possible to
    detect which field did not match therefore it is not possible to script against
    unexpected amount sent errors without some compromise (e.g. timeouts).
3. CAT is simplistic, and there are really few ways to implement it. However,
   because it requires some restrictions for security, there are difficult to
    answer open design questions:
   1. What is the appropriate maximum stack size CAT should permit? Currently
      the design in Elements is 520 bytes, the max general stack size permitted
    in script.
   2. Should CAT be introduced or
      [SHASTREAM](https://github.com/ElementsProject/elements/pull/817),
    SUBSTRING, or another variant? There is a strong argument for SHASTREAM because
    when constructing covenants (e.g. for use with CTV) based on TX data it's
    possible for size of a data field (e.g., serialization of all outputs) to
    exceed 520 bytes.
4. There are many tough questions that the community has grappled with during
   APO's design and engineering process, generally asking how APO-like
    techniques can be made 'Generally Safe' given iit breaks current assumptions
    around address reuse.
   1. Should APO require chaperone signatures (in order to ensure that replay
      is not done by 3rd parties)? Current Answer: No, anyone is free to burn
    their keys by revealing them to similar effect.
   2. Should APO use key tagging to mark keys that can use APO: Current Answer:
      yes, APO should be "double opt-in" (both requiring a tag and a signer to
    produce such a signature)
   3. Should APO allow signing with the external taproot key: Current Answer:
      no, because it makes APO not "double opt-in".
   4. Should APO optimize signing with the internal taproot key? Answer:
      default key 0x01 refers to taproot internal key, so it can be made
    cheaper if you're going to need it without having to repeat the entire key. 
   5. Should APO commit to the signing script? Answer: let's do two variants.
   6. Should APO instead be a larger refactoring of sighash logic that
      encapsulates APO (e.g. sighash bitmasks)? Current Answer: No, APO is good
    enough to ship as is and doesn't preclude future work.


### Safety


This category covers how "safe" each change is ranked from safest to least
safe. What makes a change more or less safe is how limited and foreseeable the
uses are of a specific opcode, in other words, how well we understand what it
can do or where it might interact poorly with deployed infrastructure.

1. CTV
2. CSFS
3. APO
4. CAT


CTV is the safest new feature since fundamentally what it introduces is very
similar to what can be done with pre-signed transactions, so it is only a pivot
on trust and interactivity. Where there is some risk from CTV is that addresses
(or rather, invoices) that are reused might have the same program behind them
which could cause unintended behavior. This differs from the reuse problem in
APO because the problem is stateless, that is, if you verify what is behind an
address you will know what exists and does not exist. E.g., two payment channel
addresses will create distinct payment channels that updates cannot be replayed
across. In contrast with APO, paying one APO using address twice creates two
instances of the same channel, state updates from one channel can be used on
the other.


CSFS is the next safest, it is just a small piece of authenticated data. CSFS
and CTV are relatively close in terms of safety, but CSFS is slightly less safe
given a remote possibility of surprising  uses of it to perform unforeseen
elliptic curve operations. This functionality already exists for up to 5-byte
messages. A hash preimage revelation can emulate a signer compactly. Using
binary expansions and addition could be used to allow signing of values more
compactly (e.g., 2x16x32 byte hashes could be used to construct a signature of
a post-hoc selected Sequence lock). Therefore it is appropriate to think of
CSFS as an expansion of the efficiency of this technique, reusability of keys,
and the types of data that can be signed over. Although CSFS is famously used
to build covenants by comparing a CSFS signature to a CHECKSIG signature and
getting transaction data onto the stack, CSFS cannot do that without CAT.


APO. This is the next safest because APO has some questions around key reuse
safety and statefulness of information. See the above description in CTV for
why this is tangibly worse for APO than CTV. [See more discussion of APO's
safety & design trade offs
here](https://lists.linuxfoundation.org/pipermail/lightning-dev/2019-September/002176.html). 


CAT is the least 'safe' in terms of extant Bitcoin concepts as it is highly
likely CAT introduces at least advanced covenants if added, especially in
conjunction with the above opcodes, but may also enable other unintended
functionality. CAT is a source of continual surprise with regards to what it
enables in composition with existing opcodes, therefore a systematic review of
composability and known uses should be done before considering it. That CAT was
forked out by Satoshi is of limited relevance as the variant proposed for
reintroduction would not have the vulnerability present initially.


### Complimentary Upgrades


Pairings of upgrades can work together to deliver functionality that neither
could alone:


1. CAT + CSFS: full blown arbitrary covenants
   1. With arbitrary covenants you can deploy many different kinds of smart
      contracts which are out of scope for this article.
2. CAT + CTV: Expanded covenants
   1. slightly simpler to use interface but fewer features than CSFS + CAT which can
      covenant over witness data and inputs.
3. CTV + CSFS: Eltoo
    1. This can add very similar functionality to eltoo with the script fragment:
    `CTV <musig(pka, pkb)> CSFS <S+1> CLTV`
    The protocol is essentially identical to the Eltoo paper, however there are
    a couple subtle differences required for dynamic fee rates.
4. CTV + APO: Slightly Different
   1. It's commonly claimed that APO is a perfect substitute for CTV. This is
      false. Their digests are slightly different, as such there are some niche
    smart contracts that could use the differences in commitment structure for
    interesting effects (CTV commits to all scriptsigs and sequences, APO cannot
    cover that data but can cover a few variants of less data covered).


By all means not an exhaustive list -- feel free to message me with additions.


### Recommendation


My recommendation is to deliver the upgrades described in this document in the
following order:


1. CTV
2. CSFS
3. APO
4. CAT/SHASTREAM/SUBSTRING/etc


This recommendation comes as a synthesis of the thoughts above on the
composability, safety, and open design considerations of the various proposals
currently in flight. 


With CTV in place, we can begin experimenting with a wide variety of contracts
using the Sapio toolchain, as well as improve and invest in maturing the
toolchain. Mature toolchains will make it easier to safely engineer and deploy
applications making use of CTV and future upgrades.


CSFS is an independent change that can be deployed/developed in parallel to or
before CTV, the implementation from Elements could be easily ported to Bitcoin.
With CSFS and CTV, Eltoo-like constructions will be possible as well.


APO can then be deployed as an optimization to existing use patterns driven by
market adoption of CTV+CSFS based use. This also gives us time to kick the can
down the road on the design questions that APO prompts around generalization of
signature digests and key reuse safety.  A similar approach was [discussed on
the mailing
list](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2019-May/016996.html),
but without the insight that CSFS + CTV was sufficient for Eltoo like
constructions, requiring CAT instead. 


Lastly, OP_CAT can be delivered as part of an effort towards generalized
arbitrary covenants and perhaps in conjunction with some special purpose
opcodes (such as OP_CHECKINPUT) that can more easily handle common cases. CAT,
although it has safe implementations used in Elements, deserves very strict
scrutiny given it's documented surprising uses.


This approach represents a gradual relaxation of Bitcoin's restrictions around
smart contract programming that introduces useful, safe primitives and gives
the community time to build and deploy useful infrastructure. The path
described in this post is an opportunity to upgrade bitcoin with simple
primitives that compose nicely for permissionless innovation.


_Thanks to those who reviewed drafts of this post and provided valuable
feedback improving the clarity and accuracy of thi post, including
[pyskell](https://github.com/pyskell), [Keagan
McClelland](https://twitter.com/ProofOfKeags), [Ryan
Gentry](https://twitter.com/RyanTheGentry), and [Olaoluwa
Osuntokun](https://twitter.com/roasbeef). Edit + Feedback &#8800; Endorsement._
