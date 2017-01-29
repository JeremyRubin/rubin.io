---
comments: True
disqusId: c712a732d2b57c54497e8406aaeb4a28ddac3231
layout: project
title: Pokerbots
pic: /public/img/poker.png
date: 2013-01-13
---

![Pokerbots Mascot]({{site.baseurl}}{{page.pic}})

I competed in Pokerbots IAP contest with a brother from my fraternity, and we
won second place in the new team bracket! Check out [the
code](https://github.com/JeremyRubin/pokerbots2013) .  

We used statistics tracking to follow opponent's strategy and mold our
aggression and looseness to counter theirs. We did not focus highly on
attempting to calculate absolute odds - we found that after ten thousand rounds
of Monte-Carlo, the percent error is relatively small and this certainly was
not our performance bottleneck. We did not use huge look-up tables to determine
our moves; we opted to use our opponent's strategy and the equity of our hand
to determine our aggressiveness. A lookup table may have been useful to store
some really good hands, but we preferred to develop a 'thinking' bot rather
than a 'reading' one.  
