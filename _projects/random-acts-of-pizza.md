---
comments: True
disqusId: 3172f039e5d30aaacc09904e70c88170209a240d
layout: project
title: Machine Learning on Reddit
shorttitle: ML on Reddit
pic: /public/img/raop.png
date: 2014-01-01
---

![raop homepage]({{site.baseurl}}{{page.pic}})
This past semester, I have been working on a project (viewable here) for my
Comparative Media Studies (CMS) independent study with Chris Peterson (CMS.603
        class). Chris is a fantastic mentor, and I will be TA'ing a class on Reddit for
him this spring. 

The focus of this study is a subreddit known as Random Acts of Pizza (RAOP) .
RAOP is a quite interesting community; the basic premise is that redditors post
with their current situation, and why they deserve/would really like a pizza.
Then, generous community members will order them a pizza. The reasons asking
for a pizza could be anything from sob stories to wanting to celebrate but
being tight on cash. On the main page, you can see the titles of recent
posts. 

RAOP is a really fascinating idea.  Strangers empathizes with each other on the
internet, exchanging more than just text. Before I started doing the
independent study, I toyed with the idea of predicting who would get pizza'ed.
When a class conflict forced me to drop another class, I saw the perfect
opportunity to do this study as a part of my humanities concentration in CMS.
So I set out doing some preliminary research on the topic and designing my
model. 

The demo provides the RAOP community with an automated predictor to surface
deserving posts. Throughout the semester, I considered several different
demonstrations, including likely to get pizza post generation, but I determined
that such formats would be damaging to the community, whereas the chosen demo
is potentially helpful. It is important to note that the algorithm may be wrong
and does not reflect my personal sentiments -- any labels reflect analysis on
the community's prior actions performed by a computer. For example, if someone
posted "I am a hungry neo-nazi and...", the models would not necessarily be
able to filter on this fact alone, as the word "nazi" would likely be the only
one in the data set, and would be filtered by threshold. Throughout the
project, I tried to keep my code as agnostic as possible to Reddit itself, such
that it may be useful for analyzing other text-based interactions. To that
extent, I plan to release my work under an unrestrictive license in the coming
weeks. 
