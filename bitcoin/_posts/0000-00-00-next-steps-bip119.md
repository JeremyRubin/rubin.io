---
comments: True
disqusId: f6bbf00808c926dd264a3e0e89cbcfece2f53976
layout: post
title: "7 Theses on a next step for BIP-119"
subtitle: "Martin Luther had 99, I'm going to give you 7"
date: 2022-04-17
hashtags: [Bitcoin, Covenants, Sapio]
---

This post starts with a conclusion:

Within a week from today, you'll find software builds for a CTV Bitcoin Client
for all platforms linked here:

- Mac OSX TODO:
- Windows TODO:
- Linux TODO:

These will be built using GUIX, which are reproducible for verification.  The
intended code to be built will be
https://github.com/JeremyRubin/bitcoin/tree/checktemplateverify-v23.0rc5-paramsv0
which is based on Bitcoin Core v23.0 release candidate 5, with commit hash
dd9a4e0ea8a109d1607ca1ec16119b1bc952d8b0. You can begin testing this
immediately, and even producing your own GUIX builds as well.

Signatures for the builds will be available below:

- TODO: ... .asc

The source tarball:

- TODO: ... .tar.gz

The client has a Speedy Trial release similar to Taproots with parameters
proposed to be:

- Signal Start MTP: 1651708800 (May 5th, 2022, 00:00 UTC)
- Signal Timeout MTP: 1660262400 (August 12th, 2022, 00:00 UTC)
- Activation Height: 762048 (Approximately Nov 9th)

See the appendix to verify these parameters.

This ensures 6 signalling periods to activate CTV. The Start and Timeout are
targeting mid-period (if hashrate stays steady) times to ensure that it is
unlikely we would have more or fewer periods.

The week delay between this post and builds is to provide time for review on
the selection of parameters as well as ability to rebase onto a final v23.0
release, should it become ready within the week. Backports are in the works for
v22.0, but release builds may not be made available as Bitcoin's release build
processes have changed since v22.0 to use GUIX. The branch for backports is
available here:
https://github.com/JeremyRubin/bitcoin/tree/checktemplateverify-v22.0 with
current commit hash 4d2c39314834a28cd46da943a12300cca8ffcb10, if you would like
to help with testing.

-------------------------

## Why this, why now?

I've just returned from the Bitcoin Miami "Bacchanal". Personally, I had a
couple different goals for being there[^skate]. One of my primary focuses was
on talking to as many people as possible about BIP-119 and the future road to
take.


While consensus has to happen among a much broader set of people than can fit
in a conference in Miami, the reality is that there were more than 20,000
Bitcoiners at this event and a good representation across industry, developers,
journalists, podcasters, plebs, whales, pool operators, miners, venture
capitalists, and more. To say it was a representative sample wouldn't be fair,
but it certainly was not a homogeneous crowd. And I spoke to as many people as
I could.

There were a couple common threads across the feedback I received:

1. Agree or disagree with CTV in particular, folks generally liked how/that I
   was driving a conversation forward, and respected the hustle required to do
   so.
1. A lot of people felt that CTV would help them in a tangible way, and more
   than a few times, individuals approached me with a concrete use case they
   *needed* but had not fully written it up yet.
1. A lot of people wanted to know what the next step was and what I was
   planning to do to get it activated and when.

Some people had some suggestions on what I should do as a next step:

1. Some folks said I should just do a UASF and rally the users.
1. Some said I needed to organize a summit for developers to explore covenants[^pleb].
1. Some said I didn't need to do a UASF, nor advocate for it, but I *did* need
   to decide on exact release parameters and distribute a reproducible binary
   so that it was clear what should be run and when so that end-to-end
   activation testing could proceed.

It's (un?)remarkably difficult to integrate all feedback on a complex topic
like a Bitcoin upgrade coherently. But, having thought it through, I decided
that the approach above was the correct next step. Below, you'll find some
reasoning on why I believe this to be proper and not out-of-line with how soft-fork
development should go.

However, if I'm wrong _in your view_, consider me a mere messenger and _please
don't shoot the messenger_. You just need to communicate clearly to the
community why they should *not* run and signal for CTV and I'm confident that
the wisdom of the consensus set will decide in it's best interests.

------------

So why ship a binary and release parameters?

# 1) CTV passes a basic pre-flight checklist.

This discussion has to start anchored in a "pre-flight checklist" for CTV.
These are fundamental questions that we should be able to tick boxes for for
*any* proposed upgrade...  Sadly, the community at large doesn't have a
codified checklist[^doit], but personally I tick off the following boxes:

[^doit]: I think defining such a process more formally would be great, but it'd be controversial.

1. No material changes to the BIP/Spec/Ref Impl necessary for ~2 years (beyond rebases).
1. A reasonably well reviewed and tested PR-implementation exists.
1. ~5 Months of a 5.5 BTC Bounty for bugs in CTV
1. I socialized a similar
   [roadmap](https://rubin.io/bitcoin/2021/12/24/advent-27/) 5 months ago,
   which received a reasonably warm response so there are 'few surprises' here
   against previously communicated intent.
1. A [community](https://utxos.org/signals) of supporters: breakdown, 16
supporting orgs, 109 individuals, 3 mining pools (totalling about 15-18%
depending on when you look).
1. Only 3 individual NACKs + 1 org (owned by one
of the individuals).
You should read them yourself, but I think the NACKs are summarizable as "it's
too soon" and "there should be a different process" rather than "I have
identified a flaw in the proposal". See section 4 for more on this.
 The NACKs are linked below:
    - [Michael Folkson](https://github.com/JeremyRubin/utxos.org/issues/27)
    - [John Carvalho/Synonym](https://github.com/JeremyRubin/utxos.org/issues/28)
    - [Dr M Robotix](https://github.com/JeremyRubin/utxos.org/issues/39)
1. Ample time to have produced a nack with a technical basis.
1. There exists software from multiple different parties for using CTV to
accomplish various tasks. None of these users have uncovered issue or difficulty
with CTV.
1. Many in the community are arguing for _more_ functionality than what CTV
offers, rather than that the functionality of CTV might be unsafe. CTV ends up
being close to a subset of functionality offered by these upgrades.
1. CTV does not impose a substantial validation burden and is designed carefully to
not introduce any Denial of Service vectors.
1. There exists a Signet with CTV active where people have been able to experiment.
1. Backports for current release and prior release (will be) available.

# 2) Unforced errors

In tennis, an unforced error is a type of lost point where a player loses
because of their own mistake. For example, suppose your opponent shoots a shot
that's a lob high in the air and slow. But it looks like it's going out, so you
do a little victory dance only to uncover that... the ball lands in. You had enough
time to get to the ball, but you chose not to because you didn't think it would
go in. Contrast this to a forced error -- your opponent hits a shot so hard and
fast across the court no human could reach it let alone hit it.

What's this got to do with Bitcoin?

Community consensus is the ball, and we don't know if by August it will be in
or out.

Getting to where the ball might land is preparing a software artifact that can
activate.

If an artifact isn't prepared that does this, even if community consensus is
ready by then, it's an unforced error that it wasn't ready which precludes us
from being live in August.

When should you avoid an unforced error like this? When the cost of getting to
the ball is sufficiently small.

I'm already maintaining a backportable to Bitcoin Core 23 and 22 patchset for
CTV. It's not much work to set parameters and do a release.

Which brings us to...

# 3) Product Management is not "my Job" -- it's yours.

Devs don't swing the racquet, we get to the ball. It's the community's job to
decide to swing or not. One might rebutt this point -- the community isn't well
informed to make that call, but fortunately devs and other tuned in individuals
can serve as "coaches" to the public and advise on if the swing should happen.

Producing the code, the tools, the reviews, the builds, the dates, these are all
getting to the ball activities.

It's possible that as a developer, one could say that we should not get to the ball
unless we know the community wants to swing.

But that's false. What if the community wants to take a swing at it but
developers haven't gotten to the ball? What if developers _refuse_ to get to the
ball because they don't want the community to take that shot? Well, tennis can
be a game of doubles (I'm really sticking with this metaphor), and maybe your
teammate -- the community itself -- strives to go for it and sprints cross court
to make up and take a shot. Maybe that shot looks like a UASF, maybe it looks
like a hard fork, maybe it's lower quality since there was less time to make the
right shot placement (worse code if usual devs don't review). But ultimately,
the economic majority is what backstops this, the devs just have the
opportunity to help it along, perhaps, a little smoother.

Largely, the formal critiques of CTV (the 3 NACKs) are based on topics of
whether or not to swing the racquet, not if we should be at the ball.
_There are other critiques as well, about the generality of the upgrade, but
we'll discuss those later in this post._

I'll excerpt some quotes from the NACKs below:

Michael writes,

> I also think attempting regular soft forks with single features is a
> disturbing pattern to get into having just activated Taproot. As I say in the
> linked post it means less and less community scrutiny of consensus changes, it
> becomes a full time job to monitor the regular soft forks being activated (or
> attempting to be activated) and only a tiny minority of the community can
> dedicate the time to do that.

So this seems to be a point largely about product management -- we should only
take a shot when we can line up more than once, due to the cost of swinging the
racquet. Not really my job, it's the communities.

> Hence I'd like to register a "No" soft signal as I fundamentally disagree that a
> CTV soft fork should be attempted in the near future and my concerns over
> premature activation outweigh my enthusiasm for digging into the speculated real
> world use cases of CTV.

If you disagree that it should be attempted, that's fine. Your time to voice
your concerns is in making the swing.

John writes,

> Generally, I do not think Bitcoin is ready for any new soft forked features at
> all in the short term. Taproot just arrived and there is already so much work to
> be done to adopt and utilize it.

This is a product management point. "Work on feature X should block all work on
other features". It's not a point on if CTV is a feature of independent merit.

Further, it's a layer violation. Wallet progress is wholly independent of
consensus upgrades, and generally, we don't operate on a waterfall development
model.

> Any improvements CTV-eltoo may bring to LN are not significant enough to claim
> they are urgent for adoption or R&D for LN progress and adoption.

Again, a product management point. How do we measure what is important to the
Lightning Community?  Oh, on [utxos.org](https://utxos.org/signals), there are
multiple Lightning Network companies and individuals (Lightning Labs, Muun
Wallet, Roasbeef, ZmnSCPxj, LN Markets, Breez, fiatjaf, and more). So if _that_
represents the community, then it seems like a greenlight.

> Since I am not qualified, nor are 99% of Bitcoiners, to evaluate this deeply,
> I feel much more time and scrutiny is required to accept CTV and the related
> projects Jeremy has prepared with it.

_If you're not qualified, remind me why we're listening?_

Sorry, I couldn't help the snark. Graciously, let's accept the framing for a
second -- who are the stakeholders who need to sign off? What is this process
like, concretely?

Is this a process that happens before or after we 'get to the ball'?

It can definitely be after we get to the ball, and the decision to swing or not
is a bit too product-management-y for how a dev should engage.

Also, related projects are a bit like the mix-ins at Cold Stone Creamery™. You
are free, of course, to just get ice cream! That there are a myriad of uses
doesn't mean you need to accept all of them, it's sufficient to just consider
the one or two you care about.

> I am currently happy with what we have in Bitcoin, and would prefer Core
> development prioritize optimizations and cleanup work over more and more
> features that have no urgent need or chance of adoption anytime soon.


This belies a basic misunderstanding of FLOSS:

1. People work on what they want to
1. CTV is already 'finished'

A non-dev's preference to spend time on cleanup or optimization doesn't make
any dev write that code or shift focus. Most core devs don't have a boss, and
if they do, it's probably not you! It's structurally impossible to direct the
attention of developers.

And it so happens that *I* am not happy with what we have in Bitcoin, so I did
something about it. With respect to adoption,  people will likely be using CTV
pretty soon after it's available, since it is a big step up for a number of
critical uses like vaults. These applications are already being built. They can
be used on signet which can be deployed to mainnet immediately[^sec]. The
implementation details for basic custody contracts are pretty simple and don't
require the level of coordination for support that other contracts like
lightning or DLCs, so adoption can be at the individual level.

The path around prioritization remains a product management question, and not
something devs can be compelled to follow.





# 4) There are other things to work on.

I can get to the ball for this shot, but then I'd like to work on getting in
position for the next shot on time.

There are other important technologies to work on, keeping covenants in limbo
ties up a lot of human capital in trying to solve for _getting something_, vs.
_having something_ and being able to work on building solutions using it plus
designing new technologies that make Bitcoin even better in different or
complimentary ways.


What's the right amount of rumination (chewing) to swallowing? Eventually, the
mouthful you have is stopping you from taking the next bite.



# 5) Consensus is memoryless


A memoryless process is something that "never makes progress". For example,
consider a board game, where you need to roll a 6 to win. You expect to need 6
rolls to win. You roll a 5. How many more rolls do you need? It's not 5. It's 6
-- the process is memoryless.

Clearly consensus isn't entirely memoryless. Something that is a concept only
obviously has to be turned into a hard artifact.

CTV has been a 'hard artifact' for 2 years. 2 years ago I took a poll of 40 or
so developers who attended my utxos.org workshop in Feb 2020. An average
sentiment was that maybe we try to do CTV in a year or so, and that we could
definitely do it maybe in 2 years.

I hear the same today from people who advocate a slower process. Maybe a year
from now, we could definitely do it in maybe 2 years.

In 2 years, if we wait, won't we hear the same?

Here's a few reason why we might hear the same complaints in the future:

In 2 years, suppose Bitcoin is ~2x the price.

Shouldn't we acknowledge twice as much at risk and do twice as much work to
security audit things going into it? What if it's not just El Salvador with
Bitcoin as a national currency, but now Guatamala too?

Suppose we want to get to a point where 50% of the community has reviewed a
change. In 2 years, what if the community is 2x the size?  Then even if we hit
50% of today's community, we only have 25% of the community read up.

Hopefully we keep innovating. And if we do keep innovating, we'll come up with
new things.  If we come up with a new thing that's 2x as good as CTV in 2 years,
but it takes another 2 years to implement it concretely, should we wait till we
finish that? But what happens when we come up with something 2x better than
that? Wait another 2 years? Now we're 4 years out from when the swing to get CTV
over the net was doable, and we'd have 0 in hand solutions for the problems CTV
tries to solve.

All this points to the nature of the memorylessness of trying to get consensus
in an open network.

The best I can do is to get to the ball and let the community decide to take the
shot.

Concretely -- what is the cost to having CTV in bitcoin during this time while
the "better" alternative is being worked on, if we do decide to activate
knowing we might one day obsolete CTV? What are the benefits to having 3-5
years of basic covenants in the meantime? On the balance it seems, to me, net
positive. It also seems to be a decision that the community at large can judge
if the costs are worth the benefits.





# 6) You can fight against it.

A criticism of the soft fork process is it's not safe with Speedy Trial (ST)
and ST is bad so we shouldn't do it.  This is not a strong criticism: with
Taproot,  our most important upgrade in years, went smoothly even though there
was sharp disagreement over the safety of the mechanism at the time.

Here's a breakdown of why Speedy Trial is OK from the perspective of different participants:

## You want CTV and won't take no for an answer.

Start with a ST. After 3 months, it either goes or it doesn't. At least we were
at the ball.  Now, let's do a UASF with a LOT=true setting. Because ST is a fail
fast, it's in theory using time where otherwise we'd have to spend coordinating
for the harsher realities of a LOT=true effort, so it's a happy-path
optimization.

If you're a miner, you should signal during the period.

## You'd like CTV and might take no.

ST is for you. Can always follow up with another ST if the first fails, or
another option if your opinion changes.

If you're a miner, you should signal during the period.

## You do not want CTV, but if others do want it, whatever.

ST is for you -- it only goes through if others signal for it.

If you're a miner, you can signal no during the period, and you can write a
blogpost on why you don't.

## You do not want CTV, and will not take yes for an answer.

I've written [forkd software](https://github.com/jeremyrubin/forkd) in 40 lines
of python which guarantees you to be on a non-activating chain.  Resist my
evil[^really] fork!

If you're a miner, you signal no during this period. You may want to optimize
the forkd code for never building on the chain you don't like.

# 7) Bitcoin Core is not Bitcoin

Bitcoin Core is a 'reference client' for the Bitcoin network, but it is not the
job of *any* of the maintainers of Bitcoin Core to decide what happens with respect to
consensus upgrades.

When I've previously asked maintainers for clarity on what 'merge rubric' they
might apply to the CTV pull request, I've been effectively stonewalled with no
criterion (even for things that were historically merged) and claims that
soft-fork discussion is outside the purview of maintainership. To be clear, I'm
not asking maintainers _to merge_, merely when they do make the decision to,
what they are evaluating. The reticence to make clear guidelines around this
was surprising to me, at first.

But then I understood: it isn't the maintainer's fault that they cannot give me
any guidance, it's how it **must** be.

The idea that Bitcoin Core might serve as the deciding body for consensus
upgrades puts developers of Bitcoin Core into a dangerous position in the
future, whereby various agents might wrongfully attempt to compel Core
developers (e.g., using the legal system) to release a soft-fork client for
whatever nefarious goal. Making it clear that soft-forks are released by
independent efforts and adopted by the community at large is the only process
we can take that keeps Bitcoin Core apolitical and unexposed.

We've seen in other communities what it looks like when lead devs exert too
much influence over the protocol and reference clients directly. Not good. We
do not want to have a similar precedent for Bitcoin.

While previous soft-forks have generally been released by Core, I have no
qualms with leading by example for how future soft-fork development should be.
And if Core wants to merge CTV and do a release with compatible parameters,
they are welcome to, without such a release being driven by the project
maintainers directly, but rather to maintain compatibility with the will of the
community.

Thus, _Alea Iacta Est_.



[^really]: sigh, if you really think I'm not working in good faith it's a lost cause...
[^skate]: including roller skating along the beach of course...
[^pleb]: in theory, pleb.fi was intended to be part of this...
[^sec]: probably following a thorough security review


# Bonus: What do I do now?

I believe the community's next steps are:

1. Evaluate the software proposed above and find any bugs (claim 5.5 BTC Bounties?)
1. Discuss vociferously through the next few months if BIP-119 should be
   activated or not (that means you should e.g. post publicly if you/your org endorses
   this particular path, cover it in your news org, etc).
1. Before the end of July, Miners should signal if the speedy trial should succeed
1. Before November, if Speedy Trial passes, then all users should ensure they
   upgrade to validate CTV
1. If Speedy Trial fails, at least we were at the ball, and we can either try
   again _next year_ or we can re-evaluate the design of CTV against
   alternatives that would take more time to prepare engineering wise (e.g.,
   more general covenants, small tweaks to CTV).

## What is *Jeremy Rubin* going to do?

Well, at this point I am unemotional about any outcome. Judica, my startup, is
focused on Bitcoin infrastructure that can be used to great impact with or
without CTV, so I've explicitly positioned myself to be personally indifferent
to outcome. I personally think that CTV is ready to go, and will deliver
immense benefits to the network, so I'll advocate for signalling for it.

However, in my advocacy, I'll be careful to note that it's not a _must_. All
actors must decide if it's in their own rational self-interest to have the
soft-fork proceed.

## But what about UASF?

Regrettably, no one has produced the ST compatible UASF code since last year,
for various reasons. I understand the motives and tradeoffs of a UASF out the
gate, but I still personally believe a UASF is best done as a follow-up to a
ST, as I detailed in my mailing list post on the subject
[here](https://lists.linuxfoundation.org/pipermail/bitcoin-dev/2021-April/018833.html).




# Appendix: Parameter Check!

```bash
$ gdate -d@1651708800 -u
Thu May  5 00:00:00 UTC 2022
$ gdate -d@1660262400 -u
Fri Aug 12 00:00:00 UTC 2022
```

The below script simulates the passage of time and confirms that we are
beginning at an expected mid-period time, and we are also ending near a
mid-period time, given the assumed number of SIGNAL\_PERIODS. This technique
should guarantee with high certainty at least SIGNAL\_PERIODS - 1, and
repeating the simulation with up-to-date numbers as the signalling window
progresses will produce more accurate forecasts.

```python
import datetime
SIGNAL_PERIODS = 7
current_time = 1650301349
height_now = 732450
minutes_till_may_5th = 23457
height = int(height_now + minutes_till_may_5th/10.0)
print("Expected Height", height)
start_height = height + (2016 - (height % 2016))
print("Expected Start Height", start_height)
print("Start is mid period: ", (start_height-height)/2016.0)
minutes_from_now = 10*(start_height - height_now)
print("In This many Minutes", minutes_from_now)
print("In This many days", minutes_from_now/60.0/24.0)
stop_height = start_height + 2016*SIGNAL_PERIODS
print("Stopping at height", stop_height)
total_blocks = stop_height - height_now
end_time = (total_blocks - 2016/2)*10*60 + current_time
print("End of signalling at expected time", datetime.datetime.fromtimestamp(end_time))

active_height = 762048
secs_till_active = (active_height - height_now)*10*60
print("Active at", datetime.datetime.fromtimestamp(current_time + secs_till_active))
```

```
Expected Height 734795
Expected Start Height 735840
Start is mid period:  0.5183531746031746
In This many Minutes 33900
In This many days 23.541666666666668
Stopping at height 749952
End of signalling at expected time 2022-08-10 23:02:29
Active at 2022-11-09 23:02:29
```
