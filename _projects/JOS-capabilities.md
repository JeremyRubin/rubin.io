---
comments: True
disqusId: 8d6f40a790729f0f99d55ca43e8496f0ba5fe1c6
layout: project
subtitle: Final Project for 6.828 Operating Systems Engineering
title: Capabilities in JOS
pic: /public/img/cap.png
date: 2014-12-11
---
6.828 is a really fantastic operating system class taught at MIT.

> 6.828 teaches the fundamentals of engineering operating systems. You will
> study, in detail, virtual memory, kernel and user mode, system calls,
> threads, context switches, interrupts, interprocess communication,
> coordination of concurrent activities, and the interface between software
> and hardware. Most importantly, you will study the interactions between
> these concepts, and how to manage the complexity introduced by the
> interactions.
-- 6.828 Class Description

For my final project, I worked on the following:


>When developing code, it can be difficult to reason about what a process is
>able to do, should be able to do, and does (these are three separate things).
>Often when designing secure software, it is desirable to follow the principle
>of least privilege, that is, an element can only perform the tasks which is
>must perform. Capabilities exist as a way of assisting the programmer
>properly permission and sandbox code. The core idea is that a master
>environment creates all the resources (such as file descriptors) that will be
>needed for the rest of the programs life, then removes its (and its
>children’s) ability to create further resources, then passes them to its
>children as appropriate. These file descriptors can be bundled with a set of
>permissions such as read only, append only, etc such that the master process
>can get fine grained control of what the child process may affect. In
>addition, certain syscalls can be “revoked” from an environment. These
>practices makes reasoning about application security much easier. For my
>final project, I augmented JOS with an inter environment capabilities system.

[See the full report here]({{site.baseurl}}/public/pdfs/828report.pdf)
