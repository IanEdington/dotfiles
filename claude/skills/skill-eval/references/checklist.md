# Skill evaluation checklist

Derived from `RESEARCH.md`. Apply to any `SKILL.md` before merging it and at each review. Sections are ordered so an early fail stops the review: a skill that fails A should be deleted or moved, not polished.

## A. Should this be a skill at all?

Any "no" here means stop.

- [ ] **Baseline failure is documented.** The task was run without the skill and the specific, repeatable failures are written down. No failures found means no skill.
- [ ] **The content is non-derivable.** It holds something the model cannot produce on its own: private IDs, repo conventions, an internal API, a regulated sequence, a house format. General knowledge of a public framework does not qualify.
- [ ] **It is a named, triggered workflow, not always-on knowledge.** If every task in the repo needs it, it belongs in `CLAUDE.md` / `AGENTS.md`. If it must run every time an event happens, it is a hook.
- [ ] **A human wrote or rewrote the procedure.** Generated-from-docs or agent-authored text was used only as bundled reference, never as the skill body.
- [ ] **No other skill covers the same ground.** Overlapping descriptions degrade selection for both.

## B. Will it trigger?

- [ ] Description states **what it does and when to use it**.
- [ ] Description is in **third person** ("Drafts the monthly update…", never "I can…" or "You can…").
- [ ] Description contains the **literal words a user would type**: file types, tool names, synonyms, the slash-command name, the recurring event that should fire it.
- [ ] Description also makes clear **when not to fire**, if adjacent tasks exist that should not trigger it.
- [ ] `name` is lowercase-hyphenated, specific, and consistent with sibling skills (no `helper`, `utils`, `tools`).
- [ ] Description is under 1,024 characters and the budget is spent on triggers, not on restating the body.

## C. Is the body the right size and shape?

- [ ] Body targets **roughly 1,000 tokens** of procedure; hard ceiling 500 lines.
- [ ] Every sentence changes a decision. No explanations of concepts the model already knows.
- [ ] **One default with an escape hatch**, never a menu of alternatives.
- [ ] Multi-step work is a **numbered workflow**, with a copyable checklist for anything longer than five steps.
- [ ] There is a **"done when"** clause: a verifiable end state.
- [ ] There is a **feedback loop** for quality-critical output: validator (script or checklist document) → fix → repeat.
- [ ] Batch or destructive operations produce a **plan file that is validated before execution**.
- [ ] Degree of freedom matches fragility: exact commands where sequence matters, general direction where many paths work.
- [ ] Output style that matters is shown with **input/output examples**, not described.
- [ ] One term per concept, used consistently.
- [ ] No time-sensitive text; superseded material sits in a collapsed "old patterns" section.

## D. Are the supporting files usable?

- [ ] Every reference file links **directly from `SKILL.md`** (one level deep, never chained).
- [ ] Reference files over 100 lines open with a **table of contents**.
- [ ] File and directory names describe their content (`reference/finance.md`, not `docs/file2.md`).
- [ ] Each script is marked **run** or **read**; deterministic steps are scripts, not prose the agent re-implements.
- [ ] Scripts handle their own errors and explain every constant.
- [ ] Required packages are listed and confirmed available in the target runtime.
- [ ] MCP tools are **fully qualified** (`Gmail:search_threads`).
- [ ] Forward-slash paths only.

## E. Has it been measured?

Nothing above substitutes for this section.

- [ ] **At least three real tasks** exist as evals, each targeting a documented baseline failure from A.
- [ ] **With/without arms** were run on the same tasks, model, and harness.
- [ ] **Trigger rate** was recorded: did the skill actually fire on each with-arm run?
- [ ] **Correctness lift** is positive on the eval set.
- [ ] **Token cost** with the skill was recorded and is acceptable for routine use.
- [ ] Tested on every model it will run under (a skill tuned for the largest model may under-specify for a smaller one).
- [ ] Observed navigation: which bundled files were read, which were ignored, whether anything was partially read. Ignored files are deleted or re-signposted.

## F. Review cadence

At each scheduled review, re-run E on the current model. Remove the skill if any of these hold:

- [ ] Trigger rate on relevant tasks is below what a user would tolerate, and a description rewrite did not fix it.
- [ ] Correctness lift is within noise of zero.
- [ ] The base model now handles the baseline tasks without it.
- [ ] Token cost exceeds the value of the lift on routine work.

## Scoring

| Section | Result if any box unchecked |
|---|---|
| A | Not a skill. Delete, or move to always-on context or a hook. |
| B | Will not fire reliably. Fix before anything else; body quality is irrelevant until it triggers. |
| C, D | Fires but under-delivers or wastes tokens. Fix in order of leverage: size, done-when, feedback loop, then the rest. |
| E | Unmeasured. Treat every claim about the skill as a guess. |
| F | Configuration debt. Remove. |
