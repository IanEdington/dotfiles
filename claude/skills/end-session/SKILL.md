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

Write the audit in the third person: "this session decided", not "I
decided" or "you decided". The model that did the work is the worst-placed
reviewer of it; it defends what it built and agrees with what the user
said. Distance in the wording is the cheapest correction available.

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

## Step 2: Decision inventory

The audit needs something to bite on. Without this list it drifts to code
defects and never examines a choice.

- **Intent.** One line: what was this session supposed to produce,
  taken from the original request rather than from what got built. If the
  two differ, that difference is the first finding.
- **Decisions.** Each choice that shaped the outcome: approach, scope cut,
  library, data model, premise accepted. For each, who put it on the table
  first (user or session), and whether it is a one-way door (expensive to
  reverse: a schema, a public interface, a deleted thing, a sent message)
  or a two-way door.

Keep it to the decisions that mattered. A ten-minute session may have one.
The one-way doors get the full audit below; two-way doors get a line at
most.

## Step 3: The three questions

Answer all three, in the report, every time. They are the point of this skill:
the user is asking them so they don't have to remember to. What makes them
work is honesty under specificity, so hold your answers to this bar: an
answer that could be pasted into a different session's wrap-up is a failed
answer. Name the file, function, decision, or claim from this session that
it is about.

**1. What is this session least confident about in what it just did?**

There is always an answer. Judgment calls were made, verifications
skipped, and patterns matched from training data at some point in this
session; name the ones most likely to bite. Good answers sound like
"`top_errors` was never run against a log with unicode in the messages,
and the regex may not match those lines" or "the claim that the hook
fires before compaction was inferred from the docs' ordering rather than
tested". Weak answers sound like "the code could use more tests". If
everything was genuinely verified, say what was verified and name the
strongest remaining assumption instead.

**2. Assume the main decision this session made turns out to be wrong.
Why?**

Pick the one-way door that would cost most to reverse. Write the failure
as if it already happened: not "this could break if" but "this broke
because". Name the claim the decision rested on and tag that claim as one
of:

- **ran**: a command or test was executed and its output seen. Name it.
- **inferred**: derived from reading code or docs, never executed.
- **assumed**: never checked, taken as given.

A good answer sounds like "this session chose to key `top_errors` on the
raw message string; that rests on the assumption that messages are stable,
which was never checked against a real log". If every claim was run, say
what was run and name the strongest inferred or assumed claim instead.
Question 1 is about the work; this one is about the choice. If they
collapse into the same answer, say so once rather than twice.

**3. What is the user probably missing?**

Check three places and report every real finding. "Nothing material; the
closest is X" is a valid answer for any of them and better than a padded
one.

- **Silent assumptions.** What did this session assume rather than ask?
  Models notice ambiguity far more often than they raise it; this is the
  place to raise it. Mark which assumptions are load-bearing: if wrong,
  does the result collapse?
- **Adopted positions.** Which position did this session hold because the
  user held it? Would it survive if the user had proposed the opposite?
  If a premise was accepted at the start and the code has since weakened
  it, say so.
- **Missing information.** If this decision were made again in a month,
  what would you want to know, and can it be fetched now? Name the
  command, the person, or the document.

If a one-way door was marked in Step 2, add one line: a new engineer
inherits this branch with no history. Do they keep the approach?

**Findings discipline.** No cap: a long session often has several
findings worth reporting, and each earns its place by naming the artifact
and the concrete failing case. A finding that cannot do that is dropped.
Order by cost if ignored. Say what was checked and ruled out where that
changes what the user does next. Never invent a finding to fill a section;
a reviewer told to find gaps will find some whether or not they exist, and
the user cannot tell the real ones from the padding.

## Step 4: Lessons worth persisting

Most sessions produce none, and forcing one dilutes the file it lands in.
A lesson is a behaviour change, not an observation. It takes this form,
or it is not a lesson:

> Next time [situation], do [Y] instead of [Z], because [the trigger:
> the correction the user gave, the error text, or the command that
> failed].

Triggers that earn one: the user corrected you, you made the same mistake
twice, or you burned time discovering something non-obvious about the
project (a build quirk, a naming convention, a footgun). Something you
noticed once and never acted on is an observation; give it one line in
the report or drop it.

Scope decides where a lesson goes. `CLAUDE.md` (project file for
project-wide, `~/.claude/CLAUDE.md` for cross-project) is loaded at every
session start, so it holds only what every session in that project needs:
a line or two each, and only if you would tell it to a new developer on
day one. Anything narrower lives next to what it is about: a lesson about
one feature or area of the codebase goes in that area's docs, a lesson
about one kind of document goes in its style guide or template, a fact
about a person or project goes in its memory note. If the repo has a
memory or docs skill, follow its write protocol. Read the target before
proposing, so the lesson is not a duplicate or a contradiction of a line
already there.

Propose `CLAUDE.md` entries rather than applying them: give the exact
text and the target, and let the user say yes. Apply scoped edits
directly and list the files touched in the wrap-up.

## Step 5: Handoff

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
### Decisions
### Least confident about
### If the main decision is wrong
### What you're probably missing
### Workspace state
### Lessons to persist (or "none this session")
### Handoff

## Scale to the session

A ten-minute question-answering session gets a short wrap-up: skip the git
theatre if nothing was touched, and the decision inventory may be a single
line, but never skip the three questions; analysis has assumptions too. Never
fabricate activity to fill the template. A long multi-repo session gets the
full treatment, and the state check matters more than the prose.
