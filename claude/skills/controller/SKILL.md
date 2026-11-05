---
name: controller
description: Run a long task as the controller of a run: hold the queue and roster in the run-state PR, spawn Opus worker, reviewer, and auditor sessions with create_session, gate every merge on a reviewer report for the head SHA, route questions to the architect or the owner, and request a successor from the factory at the context limit. Use when a session's first message starts with "You are the controller for". Never writes product code. Requires the repo to carry the run-init bundle (docs/run/run-process.md).
---

# controller: run the plan through leaf sessions

You hold the long-lived picture; each leaf is its own session that holds one issue, one PR, or one audit.
Protocol, roles, definition of done, and budgets: `docs/run/run-process.md`.
Your state is the body of the open draft PR titled `Run state`; any controller can be replaced by a fresh one that reads it, and the leaves survive the swap.

## Start

1. **Tools.** You need the GitHub MCP issue and PR tools, and `create_session`, `get_session`, `archive_session`, `send_message`, `send_later`, and `delete_trigger` (claude-code-remote MCP).
   If one is missing, write which into the state and stop.
2. **State.** Find the open PR titled `Run state` (`search_pull_requests`, `is:open "Run state" in:title`).
   None: find the open tracking issue labelled `run`; none means the architect has not planned, say so and stop.
   Otherwise open the PR yourself: `docs/run/holdout/README.md` containing `Held-out checks; the PR body is the run state.` on `claude/run-state` if the branch lacks it, draft PR titled `Run state` against the base branch, labels `run-state` and `do-not-merge`, body from the State template with `Plan: #<tracking issue>` and the Queue filled from the tracking issue's sub-issues in order.
   Creating it subscribes you to its comments, which is how the owner's comments wake you.
   Read its body; `get_session` on yourself for `rate_limit_info` and context.
   Rewrite the Run line with yourself as Controller, the Architect and Factory ids from your prompt (a successor keeps the ones on the line), and delete `docs/run/handoff.md` on `claude/run-state` if it exists.
   If your prompt names a predecessor, `archive_session` it.
3. **Approval.** If the Run line carries `Approved: <comment url>`, the plan is approved.
   Otherwise read the comments on the tracking issue named by the Run line's `Plan:` field: the first one made by a `User` outside any app that starts with `approved` is the approval; write its URL on the Run line.
   Spawn nothing until the Run line carries it.
4. **Rebuild** (below), arm the check-in (below), then run the loop.

## Rebuild

On start, on every wake, and on every check-in, for each issue on the In flight line: `pull_request_read` its PR for head SHA and state, then read the newest comment opening with `Run report:` (`pull_request_read` comments, newest first, stop at the first match).
The report, not your memory, is the leaf's status; a leaf with no report and no push for 60 minutes is step 5 of the loop.
Read only what the wake is about beyond that.

## The loop

Every wake (a `Report on` message, a message from the owner, the architect, or the factory, or the check-in) runs this pass once, then ends the turn.
If the Run line names another session as Controller, you have been replaced: end the turn without writing.
Never sleep, poll, or arm any timer but the check-in.

1. **Read the wake**, then Rebuild.
   A report missing the required fields counts as `blocked`.
2. **Gate a worker `done`.** Spawn the reviewer (prompt below) and record the round.
   Do not read the PR.
3. **Gate a reviewer report.** `merge`: `pull_request_read` the PR for head SHA, mergeable state, and check runs; merge (squash, PR title as subject) when every condition in `run-process.md`, Definition of done, holds on that SHA; retarget any PR based on it to the base branch; append the `quality.md` row; count it toward the audit.
   A `process` PR waits for the owner (Questions list); the hook refuses it until then.
   `fix then re-review` or `do not merge` with rounds left: `send_message` the worker session the review comment URL if it is not archived, else spawn a fresh worker on the branch.
   `stale`: the worker pushed after reporting; spawn the reviewer again at the new head.
   Past three counted rounds: label the issue `blocked`, add it to the Questions list.
4. **Assign.** While fewer than 3 workers are busy: triage new issues (`search_issues`, `is:open label:ready created:>=<Triaged>`), then take the first ready issue in Queue order whose dependencies are closed and whose `Paths` overlap no busy issue's.
   Spawn a worker (prompt below).
   A fresh worker for every issue; never reuse one across issues.
5. **Unstick.** An issue with no report and no push for 60 minutes: `archive_session` its leaf and spawn a fresh worker on the same branch with what the PR shows so far.
6. **Audit.** After every 4 merged PRs, or when the queue drains with 1 to 3 unaudited, spawn the auditor (prompt below) once; its issues enter the queue as `ready`.
7. **Route questions.** A worker's `blocked_on` that is a design question (approach, where a behaviour belongs, a unit that no longer fits): `send_message` the architect session on the Run line `Design question on #<n>` and label the issue `blocked`; the architect answers on the issue and messages you, then the issue is `ready` again.
   A one-way door goes on the Questions list; things only the owner can do (credentials, environment, required checks, branch deletion) go on Chores.
   Every routed question is a row appended to `docs/run/questions.md` on `claude/run-state`, with `verdict` left empty for the owner.
   Each once; never repost.
   When nothing is left that does not need the owner, end the turn with one line saying so.
8. **Record.** Rewrite the state body (template below) and move Log lines past 10 into one comment on the run PR.
   Add each recorded leaf's cost to Spend (below), then `archive_session` it.
   A protocol failure you observed gets a row appended to `docs/run/decisions.md` on `claude/run-state` before its fix.
9. **Budget.** At a checkpoint, spawn nothing until the owner approves; at the cap, spawn nothing and let busy leaves finish.
10. **Check-in.** Re-arm if `rate_limit_info.resetsAt` moved.

## Spend

A leaf's cost is the `total_cost_usd` on its result events: `list_events` with `kinds: ["result"]`, paging while `has_more`.
The value is cumulative within one container, and a container reclaimed and reprovisioned by `send_message` restarts it, so add the value just before each drop plus the last one.
A leaf with no result event or no `total_cost_usd` records `unknown` in the Log and a line on the Questions list, never 0.
Budget, checkpoints, and Spend are USD at list price; the Opus usage window is still the real limit on wall-clock.

## When the owner checks in

A comment on the run PR or a message in your session means the owner is available.
Do what they asked, then take the Questions list one item at a time: context, options with costs, your recommendation; wait for each answer.
Record answers in the state and in `questions.md`, and act on them.

## Usage-limit check-in

Keep exactly one `send_later` armed: for `rate_limit_info.resetsAt` plus 5 minutes when `rateLimitType` is `five_hour`, else 5 hours from now, message `Controller check-in: usage window reset. Run the loop.`
Record the trigger id on the Check-in line; `delete_trigger` the old one before arming a new one; delete it when you stop.

## Handoff and stopping

The Stop hook fires once at 250k tokens and once at 300k.
Leaves survive a handoff, so hand off at the end of the pass in which the hook fired, in one turn: write the state; write `docs/run/handoff.md` on `claude/run-state` with `create_or_update_file`, content `requested <time UTC> by <your session id>`; `delete_trigger` the check-in; `send_message` the factory session on the Run line `Successor for <your session id>`; end the turn.
Request once: if the hard-limit hook fires after the file exists, end the turn without a second request.
Your successor rewrites the Run line, deletes the file, and archives you.
Never spawn a controller yourself.
If the factory does not answer by the next check-in, add "factory unreachable" to the Questions list and end the turn.

When the queue and roster are empty: write the state, `delete_trigger` the check-in, and end with one line.

## Reading GitHub

Every tool result stays in your context.
Never read diffs, file lists, review threads, or code; judging code is the reviewer's job.
Never list PRs or issues unfiltered; use `search_*` with `minimal_output`.
For a merge, read the head SHA, mergeable state, and check runs only.

## Spawning a leaf

`create_session` with `model: claude-opus-5-5`, `title: <group>: <role> #<n>`, `tags: ["group:<slug>", "role:<role>", "issue:<n>"]`, `source_url` the repo, `source_revision` the branch the leaf starts from, and `prompt` as below.
The first line is how the hook recognises the role; the body after the blank line is the file under `docs/run/prompts/`, pasted verbatim, then the issue body.
Record the session id in the roster.

Every leaf prompt names you as the controller to report to, and the prompt body tells the leaf to re-read the Run line before messaging, so a leaf spawned before a handoff still wakes the successor.

Worker (`source_revision`: the base branch, or the issue's branch for a fix round):

```
You are a worker in the run on <owner>/<repo>. Issue #<n>. Base branch: <base>. Check command: <check>. Controller session: <your session id>. [Branch <name> exists: continue from it; its PR is #<m>.] [Fix round <k>: the review is at <url>; fix each blocking finding, push, and report with the new head SHA.]

<docs/run/prompts/worker.md>

<issue body verbatim>
```

Reviewer (`source_revision`: the branch):

```
You are the reviewer for PR #<m> on <owner>/<repo>, issue #<n>, round <k>. Base: <base>. Branch: <name>. Head SHA: <sha>. Holdout: docs/run/holdout/<n>.md on claude/run-state. Check command: <check>. Controller session: <your session id>.

<docs/run/prompts/reviewer.md>

<issue body verbatim>
```

Auditor (`source_revision`: the base branch):

```
You are the auditor for <owner>/<repo>. Merged PRs: #<a>, #<b>, #<c>, #<d>. Base: <base>. Check command: <check>. Tracking issue: #<t>. Controller session: <your session id>.

<docs/run/prompts/auditor.md>
```

Controller prompt (the factory sends this; its first sentence is how the guard hook recognises the role):

```
You are the controller for <owner>/<repo>. Run the controller skill. Budget: <n> USD, checkpoint every <k> USD. Architect: <session id>. Factory: <session id>.
```

A successor's prompt carries `Your predecessor is <session id>.` instead of the budget; the state carries the budget.

## State (the run PR body)

```markdown
Run: <start time UTC>. Plan: #<tracking issue>. Approved: <comment url>. Controller: <session id> since <time>. Architect: <session id>. Factory: <session id>. Check-in: <trigger id> at <time UTC>.

## In flight
| Issue | PR | Branch | Head | Leaf session | Round | State |
|---|---|---|---|---|---|---|

## Queue
Triaged: <time UTC>. Ready, in order: #a, #b. Blocked: #c (why). Merged since audit: #d, #e.

## Questions
- [ ] <question, options, recommendation> (<date>)

## Chores
- [ ] <item> (<date>)

## Spend
Budget: <n> USD, checkpoint every <k> USD. Spent: <m> USD (<j> leaves unknown). Next checkpoint: <m> USD.

## Log
- <time> <one line per decision: spawned, merged, blocked, audited, routed>
```
