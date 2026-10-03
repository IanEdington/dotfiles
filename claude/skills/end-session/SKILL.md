---
name: end-session
description: Wrap up a Claude Code session before the user walks away. Runs an honest confidence audit, surfaces blind spots, verifies git and workspace state, captures lessons worth persisting, and writes a handoff for the next session. Use whenever the user invokes /end-session or signals the session is ending, for example "wrap up", "let's stop here", "I'm done for today", "closing out", "before I go", or "end the session", even if they don't ask for a summary explicitly.
---

# end-session: wrap up before walking away

Run the checks, then reflect, then report. Never answer from memory what a
command can verify.

Write the audit in the third person ("this session decided", not "I" or
"you"). The model that did the work defends it and agrees with the user;
the distance in wording counters that.

## Step 1: Verify workspace state

Run whichever apply:

- `git status` and `git log` on every repo touched: uncommitted changes,
  untracked files worth keeping, unpushed commits, new branches.
- Open PRs from this session, and their CI state if cheap to check.
- Scratch files outside the repo, and background processes still running.

Don't commit, push, or delete; report, and let the user decide. Name state
that needs action precisely enough that the fix is copy-paste ("2 unpushed
commits on fix-parser").

Re-check immediately before writing the report. Anything run during the
wrap-up, even a smoke test leaving `__pycache__`, makes an earlier check
stale, and one false "clean" discredits the whole report.

## Step 2: Decision inventory

Without this list the audit drifts to code defects and never examines a
choice.

- **Intent**: one line on what the session was meant to produce, from the
  original request, not from what got built. A gap between the two is the
  first finding.
- **Decisions**: each choice that shaped the outcome (approach, scope cut,
  library, data model, accepted premise), who proposed it first (user or
  session), and whether it is a one-way door (schema, public interface,
  deletion, sent message) or a two-way door.

Keep it to the decisions that mattered; a short session may have one.
Only one-way doors get the full audit and a row in the Decisions table.
Two-way doors share one line at most, or none if skipping it changes
nothing.

## Step 3: The three questions

Answer all three every time. An answer that could be pasted into another
session's wrap-up fails: name the file, function, decision, or claim it is
about.

**1. What is this session least confident about in what it just did?**

There is always an answer: a skipped verification, a judgment call, a
pattern matched from training data. Good: "`top_errors` was never run
against a log with unicode messages; the regex may miss those lines."
Weak: "the code could use more tests." If everything was verified, say
what, and name the strongest remaining assumption.

**2. Assume the main decision turns out to be wrong. Why?**

Take the one-way door most costly to reverse; if there is none, take the
most consequential two-way door and say so. Write the failure in the past
tense ("this broke because"), name the claim it rested on, and tag it:

- **ran**: executed and output seen; name the command.
- **inferred**: from reading code or docs, never executed.
- **assumed**: never checked.

Good: "this session keyed `top_errors` on the raw message string; that
rests on the assumption that messages are stable, which was never checked
against a real log (assumed)." If every claim was run, name the strongest
inferred or assumed one. Question 1 is about the work; this one is about
the choice. If the answer still matches question 1, write "Same as the
first item under Least confident about" and nothing more.

**3. What is the user probably missing?**

Check each; "Nothing material; the closest is X" is a valid answer.

- **Silent assumptions**: what this session assumed rather than asked.
  Mark the load-bearing ones.
- **Adopted positions**: what this session held because the user held it.
  Would it survive the opposite proposal? Has the work since weakened a
  premise accepted at the start?
- **Missing information**: what you'd want if deciding again in a month,
  and the command, person, or document that can fetch it now.

If Step 2 found a one-way door, add one line: would a new engineer
inheriting this branch with no history keep the approach?

**Findings discipline**: no cap and no floor. Before writing the report,
re-read each finding and drop any that does not name the artifact and a
concrete failing case. Order by cost if ignored. Mention what was ruled
out only when that changes the user's next step. Never pad; the user can't
tell padding from real findings.

## Step 4: Lessons worth persisting

Most sessions produce none; a forced one dilutes the file it lands in. A
lesson takes this form or it is not one:

> Next time [situation], do [Y] instead of [Z], because [the correction,
> error text, or failed command].

Only three triggers earn one: the user corrected you, you repeated a
mistake, or you burned time on a non-obvious project fact. Anything else
is an observation: one line in the report, or drop it.

Place each lesson on the first rung that fits, and say why higher rungs
didn't:

1. **Recurring and visible in a tool call**: a hook or `permissions.deny`
   rule. Sketch event, matcher, condition, and action.
2. **Preventable by a script, CI check, or test.**
3. **About one tool, area, or document type**: that skill, doc, style
   guide, or memory note, following any memory or docs skill's write
   protocol.
4. **Needed by every session from day one**: `CLAUDE.md`, one or two
   lines.

Read the target first so the lesson doesn't duplicate or contradict it.
Apply rung 3 edits directly and list the files touched. Propose the rest
as exact text or a sketch plus its target, and let the user approve.

## Step 5: Handoff

Write for a next session that starts cold. Cover briefly:

- Outcomes, not narrative.
- Decisions and why, including rejected alternatives, so they aren't
  relitigated.
- Open threads: unfinished, blocked, or deferred work, and anything that
  rots overnight (expiring credentials, pending approvals, CI in flight).
- The command a skeptical next session runs to confirm things still work.
- The first action next time, pasteable as an opening prompt.

If the work is worth resuming with full context, mention `claude --resume`
and suggest naming the session if it isn't named. If the repo has a place
for session notes, offer to write the handoff there, stamped with the date
and git ref, with the next action under `## Pick up here`. Otherwise the
report is the handoff.

## Report structure

Use these sections in this order. An empty section gets one line saying
so; What happened is the one exception and is omitted when the user was
present throughout. Never fabricate activity to fill the template.

Done when every section is filled or marked empty, Workspace state
reflects a check run after the last command, and every item under Act on
these has an action.

```markdown
## Session wrap-up
### Act on these
[At most three, by cost if ignored. One line each: artifact, what is wrong
or unverified, and the action (a command, a check, or a decision the user
owes). Detail lives below.]
### What happened
### Decisions (one-way doors)
### Least confident about
### If the main decision is wrong
### What you're probably missing
### Workspace state
[One line when nothing needs action; itemize only what does.]
### Lessons to persist (or "none this session")
### Handoff
[A `claude --resume` note states only what will still be true when read;
no token counts.]
```

Evidence behind the questions: `RESEARCH.md`, read only when a step's
rationale is contested.
