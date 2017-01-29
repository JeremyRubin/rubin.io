---
comments: True
disqusId: 81c572be501de7cdd4e162f86967e0934ecdc90f 
layout: project
subtitle: Final Project for 6.338	Parallel Computing
title: Pure Julia MapReduce
pic: /public/img/julia.png
date: 2015-12-20
---

This is still a work in progress, as I'm waiting on Julia mutlithreaded support to improve, but this is an effort to implement a full MapReduce framework in Julia. This includes a fault tolerant file system built on Paxos.

The basic architecture is that
[Excavator](https://github.com/JeremyRubin/Excavator.jl) is a MapReduce system
which reads files from [Cairn](https://github.com/JeremyRubin/Cairn.jl), the
distributed file system built on
[Rock](https://github.com/JeremyRubin/Rock.jl), the Paxos implementation.
