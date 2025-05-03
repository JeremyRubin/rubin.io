---
title: "Giving Money Away?"
date: 2018-06-30T12:18:08-07:00
disqusId: 876aa5904c07b9ffb4e1dfb735157c1191d7e678 
draft: false
author: Jeremy Rubin
comments: True
tweet: "It's hard to give money -- here's why:"
layout: post
---
_a version of this originally appeared on [tokendaily.co](https://www.tokendaily.co/blog/giving-money-away), I still need to verify all edits match._

*Give a Man a Bitcoin, and You Feed Him for a Day. Teach a Man To Mine Bitcoin, and You
Feed Him for a Lifetime. -- Ancient Proverb*


Don't snooze -- many cryptocurrency projects are giving away coins for free -- act
fast and you can get some too!
Whatever they call it: an airdrop, a share, a gift, a giveaway, etc, the idea is
the same, noble intentions of correcting long-standing social iniquities by
"giving money away" (in the form of cryptocurrency) to disenfranchised
groups[^0]. The disenfranchised group varies project-to-project; sometimes it is F/LOSS developers,
sometimes all internet users, low-income individuals, etc.

There's a catch that subverts this good intention -- even ignoring difficult
issues around identification of real users -- it's really hard to effectively
correct these iniquities by giving away cash.

Plans that simply give out assets are misguided, because they conflate *money*
with a different, though related, concept: *wealth*.

There are many ways to define these terms, but in this article I'll define
wealth as an individual's ability to instigate changes that improve their
current situation in some capacity. For example, I am wealthy if I know how to
fix my own car when it breaks down. There are also harder to quantify forms of
this wealth which only exist relative to a group such as leadership ability.

On the other hand, for this article, I'll define money as a tool for convincing
others of an individual's wealth when they want something. For example, I could
get a mechanic to fix my car in exchange a service or good of equal value --
perhaps I can give the mechanic some advice on her ICO pitch deck -- but in many
cases it's difficult to find something the other party wants, values equally,
knows I have, or that I am able to offer currently.  Instead, I give the
mechanic a fixed amount of money, which is an easier to agree on *means of
exchange*, *unit of account*, and *store of value*.


In another sense, money is a symptom of wealth. Where there is smoke, there is
fire. Where there is money, there should be wealth. If one has a valuable skill,
such as knowing how to rebuild an engine, one can use it to acquire money. While
having money might be a good indicator that one possesses some valuable skill,
you can easily imagine situations where this would be a false indicator -- like
lottery winners.

Giving money to a person lacking financial responsibility is unlikely to
increase their wealth; like trying to use a cloud of smoke to start a fire.
Lottery winners exemplify the challenge of converting 'unearned' money into
wealth, about a third or more quickly go bankrupt despite their winnings[^3].
Intuitively, if you wouldn't invest in a slot jockey with your money before they
hit the jackpot, what makes you think they'd do any better with their winnings?

Giving people wealth is more effective than giving them money. But is giving away
wealth possible? And just how effective can giving away money truly be?


-----------
Let's set those questions aside for a moment, we'll revisit them later.

For now, we'll construct a toy model[^inspiredby] for discussing giveaways. As with any
model, this toy model is overly simplified for many reasons -- I'll do my best
to clarify which things are simplified. The main purpose in presenting a toy
model is to establish a common framework for how to think about giveaways.

Suppose we can represent everyone in the world's assets as a vector \\(v_a\\)
and their wealth as a vector \\(v_w\\). Assets are tangible things usable for
transactions or ownership, and wealth is a measure of an individuals quality.
For instance, a debit card uses assets and a credit card uses wealth.


We can model assets as a proxy for wealth, and model the efficiency of the proxy
with a cost function such as Euclidean distance between the normalized vectors.
We normalize the vectors to account for unit bias[^unit], if everyone had $100 or $1M,
it wouldn't matter.

$$ C_P(v_a, v_w) = \sqrt{(\hat{v}_m - \hat{v}_w)^2} $$

In reality, Euclidean distance may be a really poor choice of cost function --
perhaps a better choice is cosine similarity, perhaps there is a regularization
parameter that says cost should be higher if the distribution doesn't fall
along a power law, perhaps Gini coefficient[^1]  should be included, etc. But we
will get a lot of mileage out of using a simple cost function for discussing the
general shape of the problem.

I posit you can only meaningfully give people assets insofar as the giveaway
works to minimize the cost function subject to a regularization parameter (otherwise our
giveaway might be *too* radical, which could destabilize the economy). For
example, the following formula is one possible giveaway cost function:

$$C_G(v_a, v_w, \Delta v_a) = C_P(v_a + \Delta v_a, v_w
) - C_P(v_a, v_w) + \eta \cdot || \Delta v_a||$$

In plain English, you want the smallest giveaway for the largest correction in
wealth/assets disparity. If \\(C_G(v_a, v_w, \Delta v_a) > 0\\), then you
destabilize the monetary supply.

Again, this cost function is only offered as an example. We may also care
about other regularizations against different types of giveaways -- for
instance, we might want to penalize giveaways that are 'unfair' with high
variance between amounts -- but we can use this model a starting point to look
at a few examples.


If you want to follow along, the model is in python below:
```python
def norm(v):
  w = sqrt(sum(map(lambda x: x**2, v)))
  if w == 0: return v
  return [x/w for x in v]

def cp(m, w):
  return sqrt(sum(map(lambda (a,b): (a-b)**2, zip(norm(m), norm(w)))))

def cg(m,w,dm, eta=0.01):
  return cp([a+b for (a,b) in zip(m, dm)], w) - cp(m, w) + eta*sqrt(sum(x**2 for x in dm))
```


To work a quick, concrete example of correcting inequalities:

Suppose Alice has $10 and Bob has $20, but
Alice is "worth" $10 and Bob is "worth" $12. I.e., \\(v_a = [10, 20], v_w = [10,
12]\\). To correct for the inequality, we either want Alice to have more money
or Bob to have less. How bad is the current inequality? The cost function tells
us \\(C_P([10, 20], [10, 12]) \approx 0.23\\).

Suppose \\(\eta = 0.01\\).

Let's examine four plausible giveaways


**What if we give everyone a small amount?**
$$\Delta v_a = [1, 1] \to C_G \approx -0.0046$$

Negative cost! It works! By increasing Alice's and Bob's assets, we made the
overall efficiency of the monetary supply better.

**What if we give everyone a lot!**

$$\Delta v_a = [10, 10] \to C_G \approx 0.018 $$

Too much! Our money is less efficient.

**What if we tax Bob a little and give to Alice?**

$$\Delta v_a = [1, -1] \to C_G \approx -0.047$$

**What if we tax Bob a lot and give the tax to Alice?**

$$\Delta v_a = [6, -6] \to C_G \approx 0.011$$

**What if we just destroy some of Bob's assets?**

$$\Delta v_a = [0, -11] \to C_G \approx 0.023$$

Let's look at these examples as graphs. In the below graphs of giveaways, the blue
areas are efficient, the red is inefficient, and the white areas are neutral.
On the X axis is the amount Alice is to receive, on the Y axis Bob. Mind the scales on the right.

![Small Eta](/public/img/bitcoin/giveaway/cost-eta-0.01.png)

Nice -- there is a large blue region where we can improve the inequality! This
region is roughly a line segment from \\((-10, -20)\\) to \\((18, 12)\\).


In reality, in this model we might want to pick \\(\eta\\) such that the
regularization amount is 1 if the size of the giveaway is the same as the
monetary supply:

$$ \eta = \frac{1}{||v_a||} = \frac{1}{\sqrt{10^2 + 20^2}} \approx 0.045 $$


![Big Eta](/public/img/bitcoin/giveaway/cost-eta-0.045.png)

Now, the blue region is much smaller, and the maximum magnitude of the benefit
is several orders of magnitude smaller. The giveaway doesn't work that well! 

Finding cost-reducing giveaways may be impossible in many circumstances (e.g.,
with a slightly greater \\(\eta\\)). This is always the case if the
cost-function \\(C_G\\) is positive semi-definite with respect to the initial
condition.


It bears repeating: this model is heavily simplified. In a real scenario, the
regularization is much likely much larger.

Major wealth transfers often involve war,
death, and destruction. Intuitively, if I stand to lose $M dollars, I am willing
to spend $M dollars to prevent that loss (even if the total loss may be larger
-- see war of attrition[^war])

We also can't simply find the blue-zones easily -- ultimately, we don't know how
wealthy everyone is exactly and there are billions of people, not just two.
Wealth is not a fixed quantity. Just giving someone assets doesn't make them
wealthier, nor does taking away some of their assets in the short term. In the
long term, however, people's wealth drifts and moves.

----------------

There's been a lot of research that's been done on the efficacy various forms of
giveaway. Here's a run down on 4 cases:

Example 1: Finland gave away 560 euros/month to 2,000 randomly selected
unemployed Finns for two years. Finland didn't find an increase in employment,
but did find increased happiness. When the recipients base was slated to
increase, unsavory side effects such as increased nationalism manifested[^6].

Example 2: GiveDirectly gives unconditional cash transfers to impoverished areas
in East Africa. GiveDirectly claims to have seen a large improvement in the
earnings of those who received unconditional cash transfers several years after
the transfer[^givedirectly].

Example 3: The EU Africa Emergency trust, which is referenced in the
Economist[^6], set up gifts to give to residents of countries which were below a
certain poverty threshold if the government would share key reports and data.
The program faced budgetary issues.

Example 4: [GiveCrypto](https://www.givecrypto.org) is a brand new initiative
which gives crypto wallets with coins (unclear *which* ones) to those in need.
This is substantial because cryptocurrency also helps fill in with banking
infrastructure, unlike previous programs like GiveDirectly which relied on
existing analog systems.

A problem shared across these studies broadly is that they are not large enough.
The amounts of money dispersed is significantly smaller than the magnitude of
inequality between the sponsors and the recipients. Performing such socioeconomic
experiments at scale may self destruct an economy and society unwilling to bear
the cost of a non-experiment sized giveaway. Increasing nationalism, as seen in
Finland, could be a precursor for increased violence or decreased long term
global development.

A second issue is that these programs are targeted at increasing wealth, not
decreasing inequality. As is often said, a rising tide raises all boats. If the
global economy improves as a result of assisting impoverished individuals, the
benefit is not clearly greater for the receiver than the giver. For instance,
the giver may benefit greatly from having new agricultural trade, sources of
cheap educated labor, advanced manufacturing capability, or from increasing
peace in troubled regions defraying the risk of costly wars.

A third concern is that such programs create subversive reliance. For instance,
in Gambia, when politicians wanted to stop passing on surveillance data to the
EU, which would end the payments, mass protests erupted. The Gambian citizens
were put into a precarious relationship with the EU, whereby the EU had the
power to influence their politics and conduct -- perhaps against their longer
term interests. This emphasizes the importance of unconditionality, as
promulgated by GiveDirectly. Unfortunately, the discretion to continue or not
continue a giveaway itself constitutes a conditionality. It's best to structure
programs so as to minimize the chance of dependence or economic reliance for
the independence and freedom of the recipients.


--------

Let's look examine some strategies in light of the real world research and our
model.

## Give Small Amounts, Frequently

Giving away a large amount should be mostly infeasible because of
regularization.  However, by giving away small amounts repeatedly, we have an
opportunity to re-examine the money to wealth ratios for each individual, and we
also give the money distributed a chance to impact wealth. This is reminiscent
of gradient descent as used in Machine Learning[^grad].

The down side is that if the distributions are too small then the economy can
sufficiently absorb and dissipate the extra money without benefiting anyone, and
if they are too frequent then it may not be different than a single larger
    giveaway, causing chaos. 


## Target Specific Groups with Bad Wealth : Assets Ratios

One way to improve the odds of our distribution working is by finding
small communities with bad money to wealth ratios and focusing on them
exclusively. This is essentially the GiveDirectly model for working in East
Africa.

However, we must be careful. Because of the normalization of the assets vector,
giving money to one person fundamentally takes money from everyone else.


Shown below, 90 people with 10 wealth and 10 assets each, and 10 people with 10
wealth and 1 assets each. We give all 10 asset-poor people X assets each. Y is
\\(\eta\\), the learning rate.


![One Poor Person](/public/img/bitcoin/giveaway/one-poor-give.png)

This shows us that there is a range of reasonable giveaways, so long as we
discount giving money heavily (above \\(\eta \approx 0.01 \\) everyone is made
worse off giving away any money).

It's also critical to ensure that this is somewhat Pareto Efficient -- if
increasing the wealth of one group puts them on par or above another, that other
group may suffer. For instance, if supporting a poor community results in a
flood of agricultural products, existing farmers quality of life may be made
worse.

## Self Determination & Currency Competition

One way to improve the efficiency of the money supply is to allow people to
issue currencies at will for whatever group wants to.

The price discovery process for this currency on the open market serves as a
feedback loop for if that distribution formed a good giveaway or not and the
integrity of those who operate and hold the new currency.

Internally to the group self-determining, the new currency should be viewed as
more efficient among the group itself.

In a parallel world, instead of GiveCrypto, there's GiveLiquidity which buys and
sells cryptocurrencies issued by communities to help them bootstrap
internationally. This would help avoid  colonialist
influence because communities would have more autonomy over the new money supply
they are adopting.


## Increase Wealth Directly

This is a bit of a trick. Recall, our cost functions from our toy model are
about optimizing our money supply -- not our overall outcome.

Individual wealth can increase directly without a gift of assets. For instance,
sponsoring educational programs is a way to increase the wealth of society --
this is commonly done through subsidized school programs. There's evidence that
shows that unconditional cash transfers increase attendance at schools more
than conditional transfers, but improving the quality of education available
could provide an even larger boost.

Another take on this is to remove "wealth-conversion depressants". An example of
this is hair stylist licenses[^2], they ultimately serve as a barrier for entry
based on assets available (not based on skill).



## Counteracting Another "Giveaway"

If other contemporaneous events emulate a giveaway that redistributes assets in
such a manner that there is a substantial worsening of wealth to assets ratio, a
concurrent giveaway could counteract this. Two examples of this are giving
resources to educated refugees and asylum seekers who left behind their property
and assets (the conflict is reassigning their assets via violence) as is being
done in Turkey[^turkey] and proposals to use Bitcoin in Venezuela to counteract
the instability of the Bolivar[^4].

------------------

In writing this article, my hope was not to convince you that you can't make
people's lives better -- au contraire! Working to improve the human condition is
something that each and every one of us should do every day, and I laud those
trying, even if I disagree with their tactics.

I do hope that you are left understanding how difficult it is to give away money
with good effect. Fully fixing the inequality would cause massive upheaval and
disorder, increasing the fairness but decreasing the wealth. Peer reviewed
experiments with promising results are unlikely to scale because they don't run
up against this societal regularization. They also, at scale, may cause an
untold loss of liberty as more income is unearned and dependent on the
discretion of the ruling class.

I'll leave you with this: In setting up the dichotomy between wealth and assets,
I've completely side-stepped the much more interesting question: wealth
inequality. Is it an issue if someone else is, by natural virtue, exponentially
better off than me?  Should that inequality be rectified? Can it be?  When a new
disease breaks out, the immunologist's value to society increases, maybe that's
how it should be.  Maybe we could all attain equal wealth at the cost of our
individuality. Or perhaps we could all be equal, but none great. Maybe our best bet
is for each of us to ask, are we better off than we were before; and what can
we do for those of among us who are not as fortunate?




------------------



[^0]: *disclosure: I am an advisor to Stellar, which aspires to give away cryptocurrency to many people.*
[^1]: A measure of centralization of wealth distribution. See [the wikipedia entry.](https://en.wikipedia.org/wiki/Gini_coefficient)
[^2]: [Hair Licenses](https://www.theatlantic.com/business/archive/2016/08/hair-braider/494084/)
[^3]: [Powerball](http://fortune.com/2016/01/15/powerball-lottery-winners/  )
[^4]: [Sending coin to Venezuela](https://www.coindesk.com/plan-send-millions-bitcoin-venezuela-taking-shape/)
[^6]: [Economist on UBI](http://worldif.economist.com/article/13518/giving-money-everyone)
[^7]: [NYTimes on UBI](https://www.nytimes.com/2018/05/02/opinion/universal-basic-income-finland.html)
[^unit]: Accounting for the fact that there could be X 'dollars' per unit wealth.
[^inspiredby]: This model is inspired by general format of a gradient descent problem.
[^givedirectly]: [GiveDirectly](https://givedirectly.org/research-on-cash-transfers)
[^turkey]: [Turkey](https://www.ft.com/content/5c7fdfde-e187-11e6-9645-c9357a75844a)
[^grad]: Two great interactive sites demonstrating these methods, [one](https://www.benfrederickson.com/numerical-optimization/) and  [two](https://distill.pub/2017/momentum/).
[^war]: [https://en.wikipedia.org/wiki/War_of_attrition_(game)](<https://en.wikipedia.org/wiki/War_of_attrition_(game)>)
