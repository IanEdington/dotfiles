---
run-process-version: 2
last-reviewed: TODAY
review-interval-days: 60
---

# Run process: controller, workers, reviewers

How a long task is worked in Claude Code cloud: every role is its own session, titled `<group>: <role> <n>`, and recognised by the hook from the first words of its first prompt.
The controller's procedure is the `controller` skill; the architect's is the `architect` skill; the factory's is the `factory` skill; the leaf prompts are `docs/run/prompts/{worker,reviewer,auditor}.md`; the rules agents broke as prose are hooks in `.claude/hooks/run-guard.mjs`.
Design and evidence: `claude/research/work-group.md` and `claude/research/controller-worker-reviewer.md` in the dotfiles repo.

## Roles

| Role | Model | Holds | Does | Never |
|---|---|---|---|---|
| Manager | Fable, the whole project | Quality and routing history | Starts the architect and the factory, asks the factory for the first controller, proposes process changes | Sets a timer, answers a controller question, fills a verdict, writes product code |
| Architect | Fable, the whole project | The plan as a tracking issue with sub-issues | Writes the plan and the holdouts, answers design questions in the issue, reviews `triage` issues | Writes any file but `docs/run/holdout/` on `claude/run-state` |
| Factory | Opus, the whole project | Which controllers it spawned | Spawns one controller per verified request | Anything else |
| Controller | Opus, one context window | The queue, the roster, spend, the Questions list | Spawns leaves, gates, merges, records, routes questions | Reads a diff, writes product code, resolves a conflict, answers a one-way door |
| Worker | Opus, one issue | One issue | Implements on its own branch, pushes, opens the PR, reports | Merges, reads the holdout |
| Reviewer | Opus, one PR at one SHA | One PR | Fetches the diff, runs the checks and the holdout, posts the review, reports | Writes to the repo |
| Auditor | Opus, four merged PRs | Four PRs | Files each real defect as an `audit` issue | Writes to the repo or PRs |
| Owner (the human) | Decisions and credentials | Approves the plan, answers questions, fills verdicts and spot checks | |

## State: the run PR

One draft PR titled `Run state`, branch `claude/run-state` from the base branch, labels `run-state` and `do-not-merge`, never merged or closed.
Its body is the controller's state (template in the `controller` skill); its Run line names the controller session every leaf reports to, the architect, the factory, and the approval comment that started the run.
Only the controller writes that body and pushes the branch; the hook refuses every other role, and refuses every role but the controller and the manager any GitHub write from a shell.
The branch carries `docs/run/holdout/<issue>.md`, the held-out checks workers must not see (workers branch from the base branch, which never has them), `docs/run/questions.md`, `docs/run/quality.md`, and `docs/run/handoff.md`, the handoff request the factory verifies.

## The plan: a tracking issue

The architect writes the plan as one tracking issue (goal, non-goals, one-way doors with the owner's decision requested, areas with owning paths, ordered units) with one sub-issue per unit and a milestone per release.
The owner approves it with a comment starting `approved` on the tracking issue; the first controller records that comment's URL on the Run line, and no controller spawns a leaf without it.
Every unit issue carries `Depends on`, `Paths` (two busy issues never share a path), `Read first`, `Deliverable`, `Acceptance`, and a `Holdout` line naming the file only the reviewer reads.
Labels: `ready`, `claimed`, `review`, `blocked`, `audit`, `triage`, `owner-review`, `process`.

## Reports

A leaf's report is a PR comment (an issue comment on the tracking issue for an auditor) opening with `Run report:`, in the shape its prompt gives.
After posting it, the leaf reads the Controller on the Run line (the one in its prompt may have handed off) and sends it one message, `Report on #<n>`, which wakes the controller; a message that is lost costs one check-in, not the work, because the controller rebuilds from the `Run report:` comments on every wake.

## Definition of done

The controller merges a PR when, on its head SHA, all of these hold:

- the repo's check command (`.claude/run-config.json`, `check`) and every required check are green;
- a reviewer `Run report:` with verdict `merge` is posted for that exact SHA, with the held-out check reported as run;
- GitHub shows no conflict with the base;
- every dependency issue is closed;
- no one-way-door question is open;
- for a `process` PR, the owner has merged it or commented approval after the last commit; the guard hook refuses the merge until then.

Anything else goes back to the worker as a fix round, or to the Questions list.

## Review rounds

A reviewer is spawned by the controller, never by the worker, with the prompt in `docs/run/prompts/reviewer.md`.
Three counted rounds per issue; a round that only verifies a merge of the base branch, or only the previous round's blocking fixes, does not count.
Blocking findings left after the third counted round make the issue `blocked`; the controller decides whether to allow another round.
Non-blocking findings still open at merge are filed as `audit` issues by the controller's next worker pass.

## Questions: who answers what

| Question | Goes to |
|---|---|
| Reversible implementation choice | Nobody; the worker takes its recommended option and records it in the PR body |
| Design question (approach, where a behaviour belongs, a unit that no longer fits) | The architect, by a message from the controller; the answer is a comment on the issue |
| One-way door (security, credentials, data loss, public interface or schema, irreversible external action, `CLAUDE.md` hard rule) | The owner, on the controller's Questions list |
| Product question the architect cannot settle from the plan | The owner, as a comment on the tracking issue |
| Process change | The owner, as an `approved` comment on the process PR |
| Something outside the asker's work | An issue labelled `triage`; the architect relabels it `ready` or closes it |

Every routed question is a row in `docs/run/questions.md`: date, asked by, routed to, question, answer, and a `verdict` the owner fills later (`right`, `should have been <role>`, `not worth asking`).
Research before asking: every option carries its cost; if the options are unknown the question is premature and becomes a research issue.

## Quality signals

The controller appends one row per merged PR to `docs/run/quality.md`: PR, review rounds, holdout result, audit issues naming it, reopened or reverted, and a spot-check column the owner fills on every fifth row (`good`, `acceptable`, `wrong: <one line>`).
The manager reads this file; it never fills a row.

## Process changes

A PR touching `.claude/`, `docs/run/`, or `CLAUDE.md` beyond an index line is a `process` PR.
Workers take them like any issue; the merge waits for the owner's approval comment, enforced by the hook.
Every protocol failure observed in a run gets a row in `docs/run/decisions.md` (append-only, one line per row) before the fix is made.

## Budgets

| Limit | Default | Set by | On breach |
|---|---|---|---|
| Controller context | 250k tokens, 300k hard | Stop hook | Request a successor from the factory; leaves survive the handoff |
| Leaf cost | 30 USD list price | controller, from the leaf's result events when it records the report | A row in `decisions.md` if it recurs; the issue is too large for one unit |
| Busy workers | 3 | controller | Queue waits |
| Review rounds | 3 counted | controller | `blocked` |
| Run budget | from the controller's first prompt, in USD at list price, with a checkpoint | controller | At a checkpoint, spawn nothing until the owner approves; at the cap, let busy leaves finish |
| Audit | every 4 merged PRs | controller | One auditor, read-only |

## Wakes

The controller acts only when something wakes it: a leaf's `Report on` message, a message from the owner, the architect, or the factory, or its one usage-limit check-in (`send_later` at `rate_limit_info.resetsAt` plus 5 minutes).
It never sleeps, polls, or arms any other timer.
Leaves never schedule anything.
A permission prompt in any session but the manager's is denied by hook with a message; a leaf that needed it reports `blocked` naming the command.
Every session but the owner's own gets a fresh container, so the environment setup script must make the repo testable before a run starts.
