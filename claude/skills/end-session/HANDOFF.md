# Handoff: end-session skill development

Written 2026-08-05 on branch `claude/skill-creator-end-session-oehlv9` at
commit `8eff43e`. Open PR:
[IanEdington/dotfiles#14](https://github.com/IanEdington/dotfiles/pull/14).

## What this skill is

A user-scoped `/end-session` skill that wraps up a Claude Code session:
answers two reflective questions Ian specified ("What are you least
confident about in what you just did?" and "What's the biggest thing I'm
probably missing that I haven't thought to ask?"), verifies workspace
state without mutating it, proposes CLAUDE.md lessons only when earned,
and produces a cold-start handoff. Built with the skill-creator loop
(evals, with-skill vs baseline runs, grading, benchmark).

## State of development

- `SKILL.md` is at iteration 2. Iteration 1 was the initial draft;
  iteration 2 folded in community research and one empirical fix.
- `evals/evals.json` holds three test cases with assertions: feature work
  wrap-up, dirty-git-state honesty, and research-only session. Each ran
  once per configuration per iteration against a small synthetic "logtool"
  Python repo (log parser with a strict regex; recreate from the eval
  descriptions if needed, it is two short files).
- Benchmarks (1 run per config per eval, so directional):
  - Iteration 1: with skill 15/15 assertions, baseline 11/15 (73%).
  - Iteration 2: with skill 15/15, baseline 12/15 (80%).
  - Cost of the skill: roughly +32s and +16-18% output tokens per wrap-up.
- The eval workspaces and review viewers lived in session-scoped scratch
  space and are gone when the container is reclaimed. The durable
  artifacts are this repo's `SKILL.md`, `evals/evals.json`, and the
  numbers above.

## Decisions made and why

- **The two questions are the core, kept verbatim and interactive.**
  Research found no prior art for an interactive confidence-audit ritual
  (retrospective skills exist but as document sections), and every single
  baseline assertion failure across both iterations was a missing
  "least confident" answer. This is the skill's entire measured edge; do
  not dilute it into a generic checklist.
- **Report, never act, on git state.** Ian's explicit requirement: the
  wrap-up flags uncommitted work, stray branches, and temp files but
  never commits, pushes, or deletes. Baselines sometimes auto-commit to a
  feature branch; that is exactly what this skill exists to prevent.
- **Verify state immediately before writing the report.** Added in
  iteration 2 after an iteration 1 run claimed a clean tree while its own
  smoke test had left `__pycache__/` untracked. Iteration 2 runs then
  used `python3 -B` or cleaned up, and every state claim verified true.
  Empirically load-bearing; keep it.
- **Handoff includes decision rationale, a verification command,
  time-sensitive flags, and a `## Pick up here` anchor.** From community
  research: Matt Pocock's anti-relitigation argument, thenguyenvn90's
  verification section and anchor, softaworks' staleness stamps, and
  rohitg00's time-sensitive flags. Sources are linked in the PR
  discussion and the session transcript.
- **CLAUDE.md proposals are gated hard** ("most sessions produce
  nothing") with the "would you tell a new developer joining?" filter
  (SilenNaihin's gist, official best-practices docs on CLAUDE.md bloat).
  All six test runs correctly proposed nothing; the gate works.
- **Single SKILL.md, no scripts or references directory.** The skill is
  judgment, not mechanism; everything fits comfortably in one file.

## Open threads

- **Ian has not reviewed the iteration 2 results.** Two review viewers
  were delivered in the original session; no feedback.json ever came
  back. Before iterating further, get his read on the with-skill outputs,
  especially whether the wrap-up length feels right (it costs ~32s).
- **Description optimization was never run.** The skill-creator flow has
  a final loop that tunes the frontmatter `description` for triggering
  accuracy (when Claude should auto-invoke vs explicit `/end-session`).
  Deliberately deferred until Ian approves the skill body.
- **Assertion drift**: baselines are starting to volunteer blind-spot
  content as "follow-ups" (eval 0 baseline passed that assertion in
  iteration 2 on substance). If the delta keeps narrowing, the eval
  assertions, not the skill, may need sharpening.
- **Variance is unmeasured**: one run per configuration per eval. If a
  future change shows a small delta, run 3+ runs per config before
  trusting it.
- **[IanEdington/dotfiles#14](https://github.com/IanEdington/dotfiles/pull/14)
  is open and unmerged.**

## How to verify things still work

Run the skill-creator test loop on eval 1 (the most discriminating case):
seed a repo with an uncommitted regex change and an untracked
`scratch.txt`, run a with-skill session per `evals/evals.json`, and check
the wrap-up flags both files, commits nothing, and answers both questions
with session-specific content. Cheaper smoke test: invoke `/end-session`
at the end of any real session and check the report against `git status`
yourself.

## Pick up here

Ask Ian for his verdict on the iteration 2 outputs (or just proceed if
this session's prompt implies approval), apply any feedback to
`SKILL.md`, rerun the three evals with baselines via skill-creator, then
run the description-optimization loop and merge
[IanEdington/dotfiles#14](https://github.com/IanEdington/dotfiles/pull/14).
