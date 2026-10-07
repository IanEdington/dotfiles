---
name: run-plan
description: Turn a long task into a run plan the controller can execute: a tracking issue, one sub-issue per unit of work with Paths, Acceptance, and a held-out check, a milestone, and the run-state PR. Use when asked to plan, break down, decompose, or scope a long task, feature, migration, or project for a controller run, or when the architect starts a run. Requires the run-init bundle in the repo. Writes no repo files except the holdouts on claude/run-state.
---

# run-plan: decompose a long task into issues a controller can run

The verifier is the plan.
A worker solves whatever the acceptance line says, so an acceptance line that can be satisfied by a wrong solution produces one.
Spend the time here.
Everything is written through the GitHub MCP tools; the architect's hook refuses any file write but `docs/run/holdout/` on `claude/run-state`.

1. **Understand** the task with Explore subagents, not by reading the repo yourself: which areas it touches, what tests exist, what the repo's check command covers.
2. **Write the tracking issue** with `issue_write`, label `run`: goal, non-goals, the one-way doors you can foresee (each with the owner's decision requested up front), the areas touched with their owning paths, and the ordered list of units of work, each one line.
   A unit is one PR an Opus worker finishes in one context: one behaviour, under about 400 changed lines, with a check that proves it.
   Create a milestone per release and attach the tracking issue to it.
3. **Adversarial review of the plan.** Spawn a reviewer-style subagent (Opus, fresh context) with only the goal and the tracking issue body, told to assume it is wrong: missing units, units that cannot be verified, hidden dependencies, paths two units share.
   Fix what it finds; two rounds at most.
4. **Write the unit issues**, one per unit, with `issue_write`, label `ready` (or `blocked` with its dependency), attached to the milestone and added as sub-issues of the tracking issue with `sub_issue_write`, body:

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
5. **Write the held-out checks** with `create_or_update_file` on branch `claude/run-state` (create it from the base branch with `create_branch` if missing), one file per issue at `docs/run/holdout/<n>.md`: a check the reviewer runs that the worker was not told about.
   An end-to-end scenario, a property the acceptance tests do not cover, an input the obvious implementation gets wrong, or a command against the running app.
   Each must be runnable in a fresh cloud session by the reviewer with what the repo and its setup script provide.
   Never mention a holdout's content in the issue or the plan.
6. **Open the run PR** if none is open: `docs/run/holdout/README.md` containing `Held-out checks; the PR body is the run state.` on `claude/run-state`, draft PR titled `Run state`, labels `run-state` and `do-not-merge`, body from the controller skill's State template with `Plan: #<tracking issue>` on the Run line and the Queue filled in order.
   Create the labels (`ready`, `claimed`, `review`, `blocked`, `audit`, `triage`, `owner-review`, `process`, `run`, `run-state`, `do-not-merge`) if missing.
7. **Ask for approval.** Comment on the tracking issue: what the plan commits to, the one-way doors awaiting a decision, and that a comment starting `approved` starts the run.
   The controller records the question in `docs/run/questions.md`; the architect only asks.

Done when: every unit issue has Paths that overlap no other open issue's, an Acceptance line a reviewer can check without asking, a holdout file on `claude/run-state`, and a parent tracking issue; the plan reviewer's last round had no blocking findings; the owner has been asked for `approved`.
