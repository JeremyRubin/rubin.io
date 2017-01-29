---
comments: True
disqusId: b8457ab407369bf3c07622fbb8188e4925e3beee
layout: project
title: Verified DSP in Coq
subtitle: Final Project for 6.888 Certified Systems Software
featured: True
pic: /public/img/coq.png
date: 2015-05-20
---
![Some Inductive type]({{site.baseurl}}{{page.pic}}){: .center-image }


Digital Signal Processors and microcontrollers are used widely in a wide range
of devices and machines. There are many life critical applications, including
medical equipment, transport, and communications. It is therefore of great
importance to ensure the proper functionality of such devices. Many of these
devices are simple, preferring to rely on a tried and true 8-bit architecture
without a full operating system so that they may more easily reason about
real-time responses to events. For in- stance, it could be disastrous to have
a garbage col- lection pause while trying to apply the brakes of a car.
However, this simplicity comes at a cost; without higher level constructs a
programmer must manually write and check a lot more code due to the high
resource constraints. Furthermore, it is hard for a programmer to verify that
the code they wrote is correctly translated into the binary loaded onto chip,
the compiled version may have different properties than desired. This paper
presents a new framework, VerifiedDSP, for programming 8-bit Intel 8051 series
microcontrollers and designing embedded Digital Signal Processing systems. It
includes an 8051 simulator, a prototyping framework for mocking out
specifications, and some higher level constructs to help programmers formalize
the behavior and run time of control loops.

[Read the full report here]({{site.baseurl}}/public/pdfs/888report.pdf)
