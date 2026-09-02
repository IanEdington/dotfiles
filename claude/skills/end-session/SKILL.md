---
name: end-session
description: Wrap up a Claude Code session before the user walks away. Runs an honest confidence audit, surfaces blind spots, verifies git and workspace state, captures lessons worth persisting, and writes a handoff for the next session. Use whenever the user invokes /end-session or signals the session is ending, for example "wrap up", "let's stop here", "I'm done for today", "closing out", "before I go", or "end the session", even if they don't ask for a summary explicitly.
---

# end-session: wrap up before walking away

The end of a session is the last moment this context exists. Everything you
know right now, every doubt you suppressed mid-task, every loose end, is
about to be garbage-collected. The user is about to walk away trusting that
what happened here is done and safe. This skill exists to make that trust
earned: surface what is shaky while you can still point at it, and leave the
next session (human or Claude) able to pick up cleanly.

Run the checks first, then reflect, then report. Do not answer from memory
what you can verify with a command.

## Step 1: Verify workspace state

Memory of what you did drifts from what actually happened, so check. Run
whichever apply:

- `git status` and `git log` on every repo touched this session: uncommitted
  changes, untracked files worth keeping, unpushed commits, branches created.
- Open PRs from this session, and their CI state if cheaply checkable.
- Temp or scratch files you created outside the repo, and background
  processes you started that are still running.

Never commit, push, or delete anything in this step; the wrap-up reports,
the user decides. If state needs action ("2 unpushed commits on
fix-parser"), name it precisely enough that the fix is a copy-paste away.

Verify immediately before writing the report, not merely at the start of
the wrap-up. Anything you run in between, even a smoke test dropping a
`__pycache__`, makes an earlier status stale, and a wrap-up that says
"clean" over a dirty tree teaches the user to distrust the whole report.

## Step 2: The two questions

Answer both, in the report, every time. They are the point of this skill:
the user is asking them so they don't have to remember to. What makes them
work is honesty under specificity, so hold your answers to this bar: an
answer that could be pasted into a different session's wrap-up is a failed
answer. Name the file, function, decision, or claim from this session that
it is about.

**1. What are you least confident about in what you just did?**

There is always an answer. You made judgment calls, skipped verifications,
and pattern-matched from training data at some point in this session; pick
the one most likely to bite. Good answers sound like "I never ran
`top_errors` against a log with unicode in the messages, and the regex may
not match those lines" or "I claimed the hook fires before compaction, but I
inferred that from the docs' ordering rather than testing it". Weak answers
sound like "the code could use more tests". If you genuinely verified
everything, say what you verified and name the strongest remaining
assumption instead.

**2. What's the biggest thing the user is probably missing that they
haven't thought to ask?**

This is about the gap between what the user asked and what matters. Look
for: an assumption baked into their request that was never validated, a
consequence of this change somewhere the session never looked, a simpler
approach that would make today's work unnecessary, or a risk that only
shows up in production or at scale. You have context they don't, and after
this session it's gone; spend it. If the honest answer is a question the
user should ask someone else (their team, their ops, their future self),
say that.

## Step 3: Lessons worth persisting

Most sessions produce none, and forcing one dilutes the file it lands in.
But if during this session the user corrected you, you made the same
mistake twice, or you burned time discovering something non-obvious about
the project (a build quirk, a naming convention, a footgun), write it
down: nothing else survives the session.

Scope decides where it goes. `CLAUDE.md` (project file for project-wide,
`~/.claude/CLAUDE.md` for cross-project) is loaded at every session start,
so it holds only what every session in that project needs: a line or two
each, and only if you would tell it to a new developer on day one.
Anything narrower lives next to what it is about: a lesson about one
feature or area of the codebase goes in that area's docs, a lesson about
one kind of document goes in its style guide or template, a fact about a
person or project goes in its memory note. If the repo has a memory or
docs skill, follow its write protocol.

Propose `CLAUDE.md` entries rather than applying them: give the exact
text and the target, and let the user say yes. Apply scoped edits
directly and list the files touched in the wrap-up.

## Step 4: Handoff

Write for a reader with zero context: the next session starts cold, and
"continue where we left off" means nothing to it. Cover, briefly:

- What changed this session, in terms of outcomes rather than narrative.
- Decisions made and why, including alternatives rejected. Without the
  why, the next session relitigates what was already settled.
- Open threads: what is unfinished, blocked, or deliberately deferred, and
  anything that rots overnight (expiring credentials, a pending approval,
  a CI run still in flight).
- How to confirm things still work: the command a skeptical next session
  runs before trusting any of the above.
- The first concrete action to take next time, specific enough to paste as
  the opening prompt.

If the work is mid-flight and worth resuming with full context, mention
that `claude --resume` restores this conversation, and suggest naming the
session if it isn't named. If the repo has an established place for session
notes, offer to write the handoff there; when writing it to a file, stamp
it with the date and current git ref so staleness is detectable, and put
the next action under a scannable `## Pick up here` heading. Otherwise the
report itself is the handoff.

## Report structure

Use this shape, in this order. Lead with the reflection; it is what the
user came for. Omit a section only when it is truly empty, and say so in
one line rather than silently dropping it.

## Session wrap-up
### What happened
### Least confident about
### What you're probably missing
### Workspace state
### Lessons to persist (or "none this session")
### Handoff

## Scale to the session

A ten-minute question-answering session gets a short wrap-up: skip the git
theatre if nothing was touched, but never skip the two questions; analysis
has assumptions too. Never fabricate activity to fill the template. A long
multi-repo session gets the full treatment, and the state check matters
more than the prose.
