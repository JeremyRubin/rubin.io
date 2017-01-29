---
comments: True
disqusId: cc78a8412d1805c02920945aa5c68b6f01a61440 
layout: project
subtitle: Final Project for 6.s897 Large Scale Systems Engineering
title: BTCSpark&#58; Scalable Analysis of the Bitcoin Blockchain using Spark
shorttitle: BTCSpark
pic: /public/img/btcspark.png
featured: True
date: 2015-12-6
---
![BTC Spark Logo]({{site.baseurl}}{{page.pic}}){: .center-image}

There is a large demand in the Bitcoin research ecosystem for high quality, scalable analytic software. Analysis can help developers quantify the risks and benefits of modifications to the Bitcoin protocol, as well as monitor for errant behavior. Historians might use Blockchain analysis to understand how various events impacted on chain activity. Corporations can use analysis to understand their customers better1. To quote Madars Virza, Co-Inventor of Zerocash and researcher at MIT CSAIL, "I need to quickly prototype ideas for my research, but parsing the Blockchain for each project is an arduous task, so I’m forced to speculate. The research world is in great need for programmable Blockchain analysis tools."

In order to serve this need, I have developed BTCSpark for my Large Scale Systems (6.S897) final project under Matei Zaharia. BTCSpark is a layer on top of Apache Spark for analyzing the Bitcoin Blockchain. It provides an easy to use, flexible, and good performance environment for researchers and developers to query the Blockchain and to build Blockchain analysis tools. BTCSpark is open source software, in contrast to almost all other user-friendly Blockchain analysis tools available today.

[Read the full report]({{site.baseurl}}/public/pdfs/s897report.pdf)

[Get the code](https://github.com/JeremyRubin/BTCSpark)
