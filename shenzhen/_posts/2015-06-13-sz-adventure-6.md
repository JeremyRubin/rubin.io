---
comments: True
disqusId: 3e86229d92665a8850827ec238791223688b16c1 
layout: post
subtitle: Shenzhen Adventure Day 6, 7
title: Intro to Bootcamp Project
date: 2015-06-13
tags:
  - shenzhen
  - project
---
Friday and Saturday were free form days, we just worked on our projects for the most part.

Our projects are basically to doing a small customization to the Orchard platform, which the instructors designed. In a nutshell:
<blockquote>Orchard is a low-power, multi-band radio-connected embedded computing solution. In other words, it's an IoT platform.

Orchard is open source hardware and software.

Orchard is also a supply chain solution. Derivatives of Orchard are meant to be prototyped easily and brought to volume manufacturing with less effort than typical. Unlike breadboard solutions like Arduino, Orchard is targeted toward prototyping through board spins. This is possible thanks to China's low-cost prototyping infrastructure. The effort to prototype is higher than a breadboard, but the on-ramp to scale production once you've got your design finished is also less steep.</blockquote>

Orchard is really cool, you can read more about it <a href="http://www.kosagi.com/w/index.php?title=Orchard_Main_Page">here</a>.

My customization is adding a sensor chip called an APDS 9960. It's a hell of a sensor: it can do ambient light, proximity, and gesture sensing baked into a tiny tiny package and communicates over I2C.

![](https://shenzhenadventure.files.wordpress.com/2015/06/apds9960.png){: .center-image}

Originally I was going to try to do a radio astronomy antenna on the board, so that you could chuck out a bunch of orchard boards in a field and make a radio telescope, but getting the RF engineering correct was going to be too difficult for the scope of the course and my background in said materials.
