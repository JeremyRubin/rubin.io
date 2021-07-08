---
comments: True
disqusId: ef6b1778a418b2c4afc943de00421bbdc066b315
layout: post
title: Drawing the Blockchain
date: 2017-02-25
permalink: /blog/2017/02/25/correct-blockchain-pointers/
---

![This is correct]({{site.baseurl}}/public/img/bitcoin/blockchainpointers.png)

One of my major pet peeves in presentations about the blockchain is that most
people seem to draw the arrows/pointers in the incorrect direction.

Pointers should point from newer blocks to older blocks. This is because in a
blockchain, each block is immutable so it would be impossible to update older
blocks to point to newer ones. This is also in line with most singly linked
list representations. Because it can be confusing, it's always best to include
reference heights for extra clarity.



