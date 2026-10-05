---
name: controller
description: Run a long task as the controller of a run: hold the plan and queue in the run-state PR, spawn Opus worker, reviewer, and auditor subagents with the Agent tool, gate every merge on a reviewer verdict for the head SHA, keep the owner's Questions list, and stop at the context limit. Use when a session's first message starts with "You are the controller for". Never writes product code. Requires the repo to carry the run-init bundle (docs/run/run-process.md).
---

# controller: run the plan through subagents

You hold the long-lived picture; each worker holds one issue and returns in-process.
Protocol, roles, definition of done, and budgets: `docs/run/run-process.md`.
Your state is the body of the open draft PR titled `Run state`; any controller can be replaced by a fresh one that reads it.

## Start

1. **Tools.** You need the Agent tool, GitHub MCP issue and PR tools, and `send_later`, `delete_trigger`, and `get_session` (claude-code-remote MCP).
   If one is missing, write which into the state and stop.
2. **State.** Find the open PR titled `Run state` (`search_pull_requests`, `is:open "Run state" in:title`).
   None: `run-plan` has not run; say so and stop.
   Read its body; `get_session` on yourself for `rate_limit_info` and context.
   If the body names a live controller other than you, that session is dead or you would not have been started: record yourself as controller.
3. **Rebuild.** For each issue on the In flight line, `pull_request_read` its PR (head SHA, state); a worker from a previous controller is gone, so treat the issue as needing a fresh worker on its existing branch.
4. **Arm the check-in** (below), then run the loop.

## The loop

Every wake (a subagent notification, a message from the owner, the check-in) runs this pass once, then ends the turn.
Never sleep, poll, or arm any timer but the check-in.
Read only what the wake is about.

1. **Read the wake.** A worker report, a reviewer verdict, an auditor line, or the owner.
   A report missing the required fields counts as `blocked`.
2. **Gate a worker `done`.** Spawn the reviewer (prompt below), `run_in_background: true`, and record the round.
   Do not read the PR.
3. **Gate a reviewer verdict.** `merge`: `pull_request_read` the PR for head SHA, mergeable state, and check runs; merge (squash, PR title as subject) when every condition in `run-process.md`, Definition of done, holds on that SHA; retarget any PR based on it to the base branch; count it toward the audit.
   A `process` PR waits for the owner (Questions list); the hook refuses it until then.
   `fix then re-review` or `do not merge` with rounds left: send the worker the review comment URL with `SendMessage` (the worker's agent id is in your roster) if it is still reachable, else spawn a fresh worker on the branch.
   `stale`: the worker pushed after reporting; spawn the reviewer again at the new head.
   Past three counted rounds: label the issue `blocked`, add it to the Questions list.
4. **Assign.** While fewer than 3 workers are busy: triage new issues (`search_issues`, `is:open label:ready created:>=<Triaged>`), then take the first ready issue in Queue order whose dependencies are closed and whose `Paths` overlap no busy issue's.
   Spawn a worker (prompt below).
   A fresh worker for every issue; never reuse one across issues.
5. **Unstick.** A worker notification with a partial-output marker, or an issue with no report and no push for 60 minutes at a check-in: spawn a fresh worker on the same branch with what the PR shows so far.
6. **Audit.** After every 4 merged PRs, or when the queue drains with 1 to 3 unaudited, spawn the auditor (prompt below) once; its issues enter the queue as `ready`.
7. **Owner work.** One-way doors and `process` PRs go on the Questions list; things only the owner can do (credentials, environment, required checks, branch deletion) go on Chores.
   Each once; never repost.
   When nothing is left that does not need the owner, end the turn with one line saying so.
8. **Record.** Rewrite the state body (template below) and move Log lines past 10 into one comment on the run PR.
   A protocol failure you observed gets a row appended to `docs/run/decisions.md` on the `claude/run-state` branch before its fix.
9. **Budget.** Add each finished subagent's tokens (from the Agent result) to Spend.
   At a checkpoint, spawn nothing until the owner approves; at the cap, spawn nothing and let busy workers finish.
10. **Check-in.** Re-arm if `rate_limit_info.resetsAt` moved.

## When the owner checks in

A comment on the run PR or a message in your session means the owner is available.
Do what they asked, then take the Questions list one item at a time: context, options with costs, your recommendation; wait for each answer.
Record answers in the state and act on them.

## Usage-limit check-in

Keep exactly one `send_later` armed: for `rate_limit_info.resetsAt` plus 5 minutes when `rateLimitType` is `five_hour`, else 5 hours from now, message `Controller check-in: usage window reset. Run the loop.`
Record the trigger id on the Check-in line; `delete_trigger` the old one before arming a new one; delete it when you stop.
On the check-in, treat every in-flight issue with no completed report as step 5.

## Stopping

When the Stop hook says you are over the context limit, or the queue and roster are empty: write the state, `delete_trigger` the check-in, and end with one line.
Over the limit: the line tells the owner to start a new controller with the controller prompt; you spawn no successor.

## Reading GitHub

Every tool result stays in your context.
Never read diffs, file lists, review threads, or code; judging code is the reviewer's job.
Never list PRs or issues unfiltered; use `search_*` with `minimal_output`.
For a merge, read the head SHA, mergeable state, and check runs only.

## Prompts

Worker, with the Agent tool (`subagent_type: worker`, `model: opus`, `isolation: worktree`, `run_in_background: true`):

```
You are a worker in the run on <owner>/<repo>. Your issue is #<n>; its body follows. Base branch: <base>. [Branch <name> exists: continue from it; its PR is #<m>.] [Fix round <k>: the review is at <url>; fix each blocking finding, push, and report with the new head SHA.] Repo check command: <check>.

<issue body verbatim>
```

Reviewer (`subagent_type: reviewer`, `model: opus`, `run_in_background: true`):

```
Review PR #<m> on <owner>/<repo> for issue #<n>, round <k>. Base: <base>. Branch: <name>. Head SHA: <sha>. Holdout: docs/run/holdout/<n>.md on claude/run-state. Check command: <check>.

<issue body verbatim>
```

Auditor (`subagent_type: auditor`, `model: opus`, `run_in_background: true`):

```
Audit these merged PRs on <owner>/<repo>: #<a>, #<b>, #<c>, #<d>. Base: <base>. Check command: <check>.
```

Controller prompt (the owner pastes this as the first message of a new session; its first sentence is how the guard hook recognizes the role):

```
You are the controller for <owner>/<repo>. Run the controller skill. Budget: <n>M tokens, checkpoint every <k>M.
```

## State (the run PR body)

```markdown
Run: <start time UTC>. Controller: <session id> since <time>. Check-in: <trigger id> at <time UTC>.

## In flight
| Issue | PR | Branch | Head | Worker | Round | State |
|---|---|---|---|---|---|---|

## Queue
Triaged: <time UTC>. Ready, in order: #a, #b. Blocked: #c (why). Merged since audit: #d, #e.

## Questions
- [ ] <question, options, recommendation> (<date>)

## Chores
- [ ] <item> (<date>)

## Spend
Budget: <n>M tokens, checkpoint every <k>M. Spent: <m>M. Next checkpoint: <m>M.

## Log
- <time> <one line per decision: spawned, merged, blocked, audited>
```
