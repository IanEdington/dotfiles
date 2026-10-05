---
name: run-plan
description: Turn a long task into a run plan the controller can execute: a plan doc, one GitHub issue per unit of work with Paths, Acceptance, and a held-out check, and the run-state PR. Use when asked to plan, break down, decompose, or scope a long task, feature, migration, or project for a controller run, or when "You are the controller" finds no Run state PR. Requires the run-init bundle in the repo.
---

# run-plan: decompose a long task into issues a controller can run

The verifier is the plan.
A worker solves whatever the acceptance line says, so an acceptance line that can be satisfied by a wrong solution produces one.
Spend the time here.

1. **Understand** the task with Explore subagents, not by reading the repo yourself: which areas it touches, what tests exist, what the repo's check command covers.
2. **Write `docs/run/plan.md`** on branch `claude/run-plan-<slug>`: goal, non-goals, the one-way doors you can foresee (each with the owner's decision requested up front), the areas touched with their owning paths, and the ordered list of units of work.
   A unit is one PR an Opus worker finishes in one context: one behaviour, under about 400 changed lines, with a check that proves it.
3. **Adversarial review of the plan.** Spawn a reviewer-style subagent (Opus, fresh context) with only the goal and the plan, told to assume it is wrong: missing units, units that cannot be verified, hidden dependencies, paths two units share.
   Fix what it finds; two rounds at most.
4. **Write the issues**, one per unit, with `issue_write`, label `ready` (or `blocked` with its dependency), body:

   ```markdown
   Depends on: #<n>, #<m> (or none)
   Paths: <globs this issue owns; no other open issue owns them>
   Read first: <docs, at most three>
   Deliverable: <the behaviour, one paragraph>
   Acceptance: <each item with the test or command that proves it>
   Holdout: docs/run/holdout/<this issue>.md
   ```

   The acceptance line is what the worker sees and proves.
   Write it so that passing it by special-casing is hard: name behaviours, not fixtures; name the test file, not its contents.
5. **Write the held-out checks** on branch `claude/run-state`, one file per issue at `docs/run/holdout/<n>.md`: a check the reviewer runs that the worker was not told about.
   An end-to-end scenario, a property the acceptance tests do not cover, an input the obvious implementation gets wrong, or a command against the running app.
   Each must be runnable in the cloud session by the reviewer with what the repo provides.
   Never mention a holdout's content in the issue or the plan.
6. **Open the run PR**: branch `claude/run-state`, one commit with the holdout files and `docs/run/state.md` containing `Run state; the PR body is the state.`, draft PR titled `Run state`, labels `run-state` and `do-not-merge`, body from the controller skill's State template with the Queue filled in order.
   Create the labels (`ready`, `claimed`, `review`, `blocked`, `audit`, `owner-review`, `process`, `run-state`, `do-not-merge`) if missing.
7. **Open the plan PR** for `docs/run/plan.md` against the base branch; it is a `process` PR, so the owner approves it.

Done when: every issue has Paths that overlap no other open issue's, an Acceptance line a reviewer can check without asking, and a holdout file on `claude/run-state`; the plan reviewer's last round had no blocking findings; the owner has the controller prompt from the `controller` skill with a budget filled in.
