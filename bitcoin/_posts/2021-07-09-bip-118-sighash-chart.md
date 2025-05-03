---
comments: True
disqusId: c5848eb3fe8becc556c00d9aa842adfa96070243 
layout: post
title: BIP-118 What Gets Hashed Chart
date: 2021-07-09
hashtags: [ANYPREVOUT, BIP118, Bitcoin]
---
As a part of my ongoing review of BIP-118 I put together a
[chart](https://docs.google.com/spreadsheets/d/1KeWJ_cly9zoRX5_h70RTniRT2m8_iaVceK_aF6obWeM)
of what gets hashed under the current proposal.

[![BIP-118 Chart](/public/img/bip-118.png)](https://docs.google.com/spreadsheets/d/1KeWJ_cly9zoRX5_h70RTniRT2m8_iaVceK_aF6obWeM)



Not tightly checked to be free of errors, but I figured such a chart would be
helpful for folks evaluating BIP-118.

Perhaps the BIPs (generally, incl 34x) could be updated to present the
information in such a chart -- at least for me it's much clearer than following
a bunch of conditional logic (maybe if there's ever desire for some consensus
refactoring this could be a table in the code replacing the cond logic).
A few highlighted nuances:

- input index is never signed (i previously thought one mode signed it). Key reuse under `APOAS | Default` and `APOAS | All` is a bit extra unsafe given susceptibility to the "half-spend" problem. This limits usability of APO for covenants a-la CTV because you can't stop someone from adding inputs to your contract nor can you prevent half-spend problems when reusing addresses.
- APO signs the Amounts, APOAS never does. 
- APO signs both the SPK and the Tapleaf hash, meaning that APO binds itself to the entire script rather than just it's fragment. There's no setting which is "just this fragment"
- APO's signature binds it to a specific script fragment *within* a taproot key, but not a specific script path
- the flag "default" is not really a flag at all -- when default is used (as a or'd byte) there are different results than when default is inferred (by absence of a byte) (this is maybe a bitcoin core specific quirk).
- There are 16 different possible modes total, so all combinations of flags mean *something* (advisable or not as with `ACP | None`)
- `*| Default` and `*| All` overlap, so there's an opportunity to either reserve or assign 4 additional sighash modes if desired. These could cover some of the gaps above, or be saved for future purposes rather than be wasted now. Another point of interest is -- not to rock the boat -- but because BIP-118 is defining a new key type we could do away with the notion that sighash flags are "flags" and convert to an enum (e.g., numbered 0-256 for whatever combination of fields each would incur) and give each signature type a sensible name, rather than thinking of things as a combo of flags (e.g., `APOAS` is not some intersection of what `APO` and `ACP` do independently).

