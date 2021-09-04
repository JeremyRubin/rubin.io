---
comments: True
disqusId: 058832a1d583110173ad3c0ada3b09173f57e8ab
layout: post
title: "CheckSequenceVerify DISCOURAGE_UPGRADABLE_NOPS Defect"
date: 2021-09-03
hashtags: [Bitcoin]
---

The other day I was writing some tests for BIP-119 (shoutout
[Gloria](https://twitter.com/glozow) for the detailed feedback on improving
tests). I noticed something peculiar while attempting to write static test
vectors for CTV. This peculiar thing led me to discover a minor flaw in
Bitcoin's interpreter -- it isn't going to break anything in the short term,
but it has implications for how certain upgrades might be done in the future.

In the interpreter we pass specific flags in at different times to check
different rules at different times. This is used because we generally want the
Mempool to be "restrictive" and block validation to be unrestrictive.  That
sounds like the opposite of what you would want, but it's because we want to
ensure that we never break a consensus rule, so our mempool is "strict" to
protect e.g. a miner from making a bad block, because our node's understanding
of consensus validation is less strict so we always know the mempool is full of
stuff that will pass consensus.

One of the specific types of "stricter" that is in the mempool is for things
that may be changed in the future. For example, Taproot (a change proposed to
Bitcoin) uses a Witness V1 script. Before Taproot activates, Witness V1 Scripts
are *always* valid no matter if they're signed or not. After it activates, a
new rule takes effect in consensus, and Witness V1 Scripts will be processed in
accordance with Taproot's rules. Because the Mempool is stricter, it never lets in
any Witness V1 script spends until it knows how to properly validate it. That way,
for a miner who doesn't want to upgrade to Taproot, they can use the old rules in their
Mempool and not ever mine a bad block.

One of the flags used for this purpose is DISCOURAGE\_UPGRADABLE\_NOPS. A NOP
is simply an opcode in bitcoin that has no effect (nada). In the future,
someone could add a rule to that NOP (e.g., check that the stack args present
when the NOP executes satisfy some properties or the transaction is invalid,
but do not remove anything from the stack so that the old consensus rules still
seem correct). This is sufficient for consensus, but maybe people have decided
that they want to create a bunch of outputs with NOPs in it because they are
cute. Then, a fork that would add new semantics to a NOP would have the impact
of locking people out of their wallets.  To prevent this, the Mempool uses the
rule DISCOURAGE\_UPGRADABLE\_NOPS which makes it so that if you try to
broadcast an output script with a NOP it gets bounced from the Mempool (but not
consensus of course, should a deviant miner mine such a transaction). Hopefully
our users get the message to not use NOPs because we... discourage upgradable
nops.

CheckSequenceVerify (CSV) was one such NOP before it grew up to be a big n'
important opcode. Essentially all that CSV does is check that the sequence
field is set in a particular manner. This lets you set relative block and time
lock (e.g., takes this much time before a coin is spendable again). However,
it's possible that we might come up with new kinds of lock times in the future,
so we have a bit we can set in the sequence that makes it ignored for consensus
purposes. Maybe in the future, someone would find something nice to do with it,
eh?

This is the sequence verification code:
```c++
case OP_CHECKSEQUENCEVERIFY:
{
    if (!(flags & SCRIPT_VERIFY_CHECKSEQUENCEVERIFY)) {
        // not enabled; treat as a NOP3
        break;
    }

    if (stack.size() < 1)
        return set_error(serror, SCRIPT_ERR_INVALID_STACK_OPERATION);

    // nSequence, like nLockTime, is a 32-bit unsigned integer
    // field. See the comment in CHECKLOCKTIMEVERIFY regarding
    // 5-byte numeric operands.
    const CScriptNum nSequence(stacktop(-1), fRequireMinimal, 5);

    // In the rare event that the argument may be < 0 due to
    // some arithmetic being done first, you can always use
    // 0 MAX CHECKSEQUENCEVERIFY.
    if (nSequence < 0)
        return set_error(serror, SCRIPT_ERR_NEGATIVE_LOCKTIME);

    // To provide for future soft-fork extensibility, if the
    // operand has the disabled lock-time flag set,
    // CHECKSEQUENCEVERIFY behaves as a NOP.
    if ((nSequence & CTxIn::SEQUENCE_LOCKTIME_DISABLE_FLAG) != 0)
        break;

    // Compare the specified sequence number with the input.
    if (!checker.CheckSequence(nSequence))
        return set_error(serror, SCRIPT_ERR_UNSATISFIED_LOCKTIME);

    break;
}
```

Spot anything funky? Look closer...

```c++
    // To provide for future soft-fork extensibility, if the
    // operand has the disabled lock-time flag set,
    // CHECKSEQUENCEVERIFY behaves as a NOP.
    if ((nSequence & CTxIn::SEQUENCE_LOCKTIME_DISABLE_FLAG) != 0)
        break;
```

Here, where we say it behaves as a NOP we don't check any rules and skip the checks.

See where the problem lies? If we ever *did* get around to a future upgrade
here, then old miners who refuse to upgrade would be more than happy to accept
invalid transactions into their mempool, and then following the fork, would end
up mining invalid blocks leading to potential network partitions.

That would be bad! Let's not do that.


What we really should be doing is:

```c++
    // To provide for future soft-fork extensibility, if the
    // operand has the disabled lock-time flag set,
    // CHECKSEQUENCEVERIFY behaves as a NOP.
    if ((nSequence & CTxIn::SEQUENCE_LOCKTIME_DISABLE_FLAG) != 0) {
        if (flags & SCRIPT_VERIFY_DISCOURAGE_UPGRADABLE_NOPS)
            return set_error(serror, SCRIPT_ERR_DISCOURAGE_UPGRADABLE_NOPS);
        break;
    }
```

Which is exactly what I propose to do in [this PR](https://github.com/bitcoin/bitcoin/pull/22871).

If this solution is adopted, then after the last release of the Bitcoin Core
Implementation that has the unpatched code goes
[End-of-Life](https://bitcoincore.org/en/lifecycle/), we could safely deploy
new sequence rules. Because it takes a while for software to go EOL, I hope we
can patch this soon.
