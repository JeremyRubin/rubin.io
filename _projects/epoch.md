---
comments: True
disqusId: 1ad96a6f3368db52539e0e1e08096e2193bfbc03
layout: project
title: Epoch Mempool
subtitle: Hansel and Gretel, left bread crumb trails as they went, but birds ate them all.
pic: /public/img/epoch.png
date: 2019-10-26
---
[![Judica](/public/img/epoch.png)](https://github.com/bitcoin/bitcoin/pull/17268)
{: .center-image .rounded }

The Epoch Mempool is a project to improve the asymptotic complexity of many of
the mempool's algorithms as well as makes them more performant in practice.

In the mempool we have a lot of algorithms which depend on rather
computationally expensive state tracking. The state tracking algorithms we use
make a lot of algorithms inefficient because we're inserting into various sets
that grow with the number of ancestors and descendants, or we may have to
iterate multiple times of data we've already seen.

To address these inefficiencies, we can closely limit the maximum possible data
we iterate and reject transactions above the limits.

However, a rational miner/user will purchase faster hardware and raise these
limits to be able to collect more fee revenue or process more transactions.
Further, changes coming from around the ecosystem (lightning, OP_SECURETHEBAG)
have critical use cases which benefit when the mempool has fewer limitations.

Rather than use expensive state tracking, we can do something simpler. Like
Hansel and Gretel, we can leave breadcrumbs in the mempool as we traverse it,
so we can know if we are going somewhere we've already been. Luckily, in
bitcoind there are no birds!

These breadcrumbs are a uint64_t epoch per CTxMemPoolEntry. (64 bits is enough
that it will never overflow). The mempool also has a counter.

Every time we begin traversing the mempool, and we need some help tracking
state, we increment the mempool's counter. Any CTxMemPoolEntry with an epoch
less than the MemPools has not yet been touched, and should be traversed and
have it's epoch set higher.

Given the one-to-one mapping between CTxMemPool entries and transactions, this
is a safe way to cache data.

Using these bread-crumbs allows us to get rid of many of the std::set
accumulators in favor of a std::vector as we no longer rely on the
de-duplicative properties of std::set.

We can also improve many of the related algorithms to no longer make heavy use
of heapstack based processing.

[Keep up on the Epoch Mempool progress.](https://github.com/bitcoin/bitcoin/projects/14#card-31846646)