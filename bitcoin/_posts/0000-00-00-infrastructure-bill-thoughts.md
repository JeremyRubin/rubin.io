---
comments: True
disqusId: 35778c9628867fd7b7422a69fe6be93f1ecec17d
layout: post
title: "Infrastructure Bill: It's Go Time for Radical Self Custody"
date: 2021-08-02
hashtags: [CTV, BIP119, Bitcoin, SelfCustody]
---

[TL;DR: click here to answer call to action](https://github.com/JeremyRubin/utxos.org/pull/4)

[ ![](/public/img/bitcoin/virginchadcustody.png) ](https://github.com/JeremyRubin/utxos.org/pull/4)

The infrastructure bill draft has been circulating which contains language that
would have massive impact for the crypto ecosystem (and Bitcoin) in the United
States, and most likely globally. The broad implication of the proposed bill is
that many types of service provider would be categorized as brokers, even if
fully 'non custodial'. E.g., a coinjoin coordinator might be a broker, even if
they never take control of the funds, because they are facilitating a
transaction. There's a lot of nuance, and the language is still being changed,
so we'll see where it lands. But that's not the point of this blog post.


The point of this blog post is that we need to _hurry the fuck up_ and improve
the self-sovereign software available and widely used by bitcoiners. You heard
me right, _hurry the fuck up_.

While there's space for debate around perfect designs and optima for protocol
improvements, these discussions take years to turn into code running in end
users wallets. I do not believe that we have time to leisurely improve
self-sovereign custody solutions while regulators figure out a wrench to throw
in our spokes.

Why am I so concerned about this bill in particular? A confidential source
tells me that this language came out of the blue, an executive branch driven
regulatory ninja attack of sorts. Normally, when the government looks to
regulate an industry, the provisions and terms get floated around by
legislators for a long while with industry input, comment periods, and more.
Then, when a bill or other rules get passed, it's something that the industry
has at least had a chance to weigh in on and prepare for. My source claims no
one has seen the clauses in the infrastructure bill before, and they infer that
may mean this is a part of a broader crack-down coming from specific political
personalities and agencies. This means we may be seeing government actions
further restricting users' rights in the pipeline much sooner than anyone could
anticipate.

I've long been saying that we should be deploying [BIP-119
CTV](https://utxos.org) for congestion control _before_ we see broad congestion
on the network. If you wait until a problem is manifest, it can take years to
deploy a solution. This merits proactivity in solving a problem before it
comes. Today, the need to improve self-custody looms urgently on the horizon.

CTV is not a panacea solution. It doesn't magically fix all custodial issues.
But, along with [Sapio](https://learn.sapio-lang.org), it does offer a pathway
to dramatically improving self custody options, letting users customize vault
smart contracts which do not depend on any third parties. Deploying CTV now is
an opportunity to put in motion the wheels for broad ecosystem support for
these enhanced custody protocols. We may come up with better options in the
future which may obsolete CTV in place of more clever technologies. I cheer
those efforts. But we need solutions for Tomorrow.

A soft fork activation for CTV could be deployable for Bitcoin imminently,
should the community embrace it. The spec is nearly 2 years old, the code has
required only small updates to be mergeable with other changes to Bitcoin Core.
The review burden is 185 lines of consensus code, and a couple hundred lines of
tests. To that end I believe it is prudent for the Bitcoin community to embrace
the deployment of CTV and I'm calling on the community to [soft-signal
intent](https://github.com/JeremyRubin/utxos.org/pull/4) for a soft-fork
activation of CTV.

We cannot control what rules state authorities attempt to mandate. But we can
individually control our own compliance with measures we see as unjust, and as
a community we can advance technologies and solutions that ensure that choice
remains squarely in the hands of every user and not the service providers they
may use.
