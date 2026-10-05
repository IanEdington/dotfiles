---
run-process-version: 1
last-reviewed: TODAY
review-interval-days: 60
---

# Run process: controller, workers, reviewers

How a long task is worked in one Claude Code cloud session: a controller in the main context, and Opus subagents (worker, reviewer, auditor) spawned with the Agent tool.
The controller's procedure is the `controller` skill; the plan format is the `run-plan` skill; the agents are `.claude/agents/{worker,reviewer,auditor}.md`; the rules agents broke as prose are hooks in `.claude/hooks/run-guard.mjs`.
Evidence behind the design: `claude/research/controller-worker-reviewer.md` in the dotfiles repo.

## Roles

| Role | Model | Holds | Does | Never |
|---|---|---|---|---|
| Controller | main session, Opus | The plan, the queue, the roster, spend, the Questions list | Spawns, gates, merges, records | Reads a diff, writes product code, resolves a conflict, answers a one-way-door question |
| Worker | subagent, Opus | One issue | Implements on its own branch and worktree, pushes, opens the PR, returns a short report | Merges, reads the held-out check, schedules anything |
| Reviewer | subagent, Opus | One PR at one SHA | Fetches the diff itself, runs the checks and the held-out check, posts the full review on the PR, returns a verdict | Edits files, sees the worker's reasoning or report |
| Auditor | subagent, Opus | About four merged PRs | Files each real defect as an issue labelled `audit` | Changes the repo or its PRs |
| Owner (the human) | Decisions and credentials | Answers the Questions list, works the Chores list, approves process changes | |

## State: the run PR

One draft PR titled `Run state`, branch `claude/run-state` from the base branch, labels `run-state` and `do-not-merge`, never merged or closed.
Its body is the controller's state (template in the `controller` skill), so any controller session can be replaced by a fresh one that reads it.
The branch also carries `docs/run/holdout/<issue>.md`, the held-out checks workers must not see: workers branch from the base branch, which never has them.
Conversation with the owner happens as comments on this PR or as messages to the controller's session.

## The unit of work: an issue

Every worker gets exactly one issue, written by `run-plan` with these fields in the body: `Depends on`, `Paths` (the files it owns; two busy issues never share a path), `Read first`, `Deliverable`, `Acceptance` (what the worker proves, with the test or command), and a `Holdout` line naming the file on the run-state branch, which only the reviewer reads.
Labels: `ready`, `claimed`, `review`, `blocked`, `audit`, `owner-review`, `process`.

## Definition of done

The controller merges a PR when, on its head SHA, all of these hold:

- the repo's check command (`.claude/run-config.json`, `check`) and every required check are green;
- a reviewer verdict of `merge` is posted for that exact SHA, with the held-out check reported as run;
- GitHub shows no conflict with the base;
- every dependency issue is closed;
- no one-way-door question is open;
- for a `process` PR, the owner has merged it or commented approval after the last commit; the guard hook refuses the merge until then.

Anything else goes back to the worker as a fix round, or to the Questions list.

## Review rounds

A reviewer is spawned by the controller, never by the worker, with the fixed prompt in `.claude/agents/reviewer.md`: issue number, issue body, base, branch, head SHA, holdout path.
It fetches the diff itself.
Three counted rounds per issue; a round that only verifies a merge of the base branch, or only the previous round's blocking fixes, does not count.
Blocking findings left after the third counted round make the issue `blocked`; the controller, not the owner, decides whether to allow another round.
Every round is posted on the PR by the reviewer; non-blocking findings still open at merge are filed as issues by the controller's next worker pass, labelled `audit`.

## Decisions: what blocks

Only a one-way door stops work for the owner: security or credentials, data loss, a public interface or schema that cannot be reverted, an irreversible external action (send, pay, delete, publish), or a `CLAUDE.md` hard rule.
Everything else is reversible: the worker takes the option it would recommend, records it in the PR body, and carries on.
The controller routes it: urgent (wrong behaviour would ship before the next audit) goes on the Questions list; otherwise it becomes an `owner-review` issue.
Research before asking: every option carries its cost; if the options are unknown the question is premature and becomes a research issue.

## Process changes

A PR touching `.claude/`, `docs/run/`, or `CLAUDE.md` beyond an index line is a `process` PR.
Workers take them like any issue; the merge waits for the owner's approval comment, enforced by the hook.
Every protocol failure observed in a run gets a row in `docs/run/decisions.md` (append-only, one line per row) before the fix is made, so the next run does not pay for the same lesson.

## Budgets

| Limit | Default | Set by | On breach |
|---|---|---|---|
| Controller context | 250k tokens, 300k hard | Stop hook | Hand off to a successor session one lineage level deeper when no worker is mid-turn (at 300k, at once); at depth 7 the owner starts a new line |
| Worker turns | `maxTurns` 200 | agent definition | Partial report; the controller spawns a fresh worker on the same branch |
| Worker tokens | 600k | recorded by the controller from the Agent result after the fact | A row in `decisions.md` if it recurs; the issue is probably too large for one unit |
| Busy workers | 3 | controller | Queue waits |
| Review rounds | 3 counted | controller | `blocked` |
| Run budget | from the controller's first prompt, in millions of tokens, with a checkpoint | controller | At a checkpoint, spawn nothing until the owner approves; at the cap, let busy workers finish |
| Audit | every 4 merged PRs | controller | One auditor, read-only |

## Wakes

The controller acts only when something wakes it: a subagent completion notification, a message from the owner, or its one usage-limit check-in (`send_later` at `rate_limit_info.resetsAt` plus 5 minutes).
It never sleeps, polls, or arms any other timer.
Workers and reviewers never schedule anything.
A permission prompt in an unattended session is denied by hook with a message; a worker that needed it reports `blocked` naming the command.
