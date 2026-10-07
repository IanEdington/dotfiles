# Work group: the session topology for a run

Replaces the single-session design in `controller-worker-reviewer.md` for the parts below; the review, holdout, decision log, and hook mechanics stay.
Owner's definition, 2026-10-07.

## Roles

Every role is its own cloud session, titled `<group>: <role> <n>` (the wordpress-mcp group is `WP MCP`).
The owner talks to the manager, the architect, and the controller only.

| Role | Model | Lives | Spawned by | Does | Never |
|---|---|---|---|---|---|
| Manager | Fable | the whole project | owner | Measures quality and routing, proposes changes to dotfiles, starts the architect, spawns every controller | Sets a timer, auto-compacts, reads or answers a controller question, fills a verdict, writes product code |
| Architect | Fable | the whole project | manager | Plans (`run-plan`), answers design questions from the controller, reviews `triage` issues, keeps `docs/plan.md` | Writes code; hook denies Edit and Write outside `docs/` and inside `processPaths` |
| Controller | Opus | one context window | manager | The loop in the `controller` skill: spawns workers, reviewers, and auditors as sessions, gates, merges, records, routes questions | Reads a diff, writes product code, answers a one-way door |
| Worker | Opus | one issue | controller | Implements the issue, pushes, opens the PR, reports | Merges, reads the holdout |
| Reviewer | Opus | one PR at one SHA | controller | Runs the checks and the holdout, posts the review, reports the verdict | Writes to the repo |
| Auditor | Opus | four merged PRs | controller | Files `audit` issues | Writes to the repo or PRs |

## Why the manager spawns controllers

`create_session` nests: a child is one level deeper than its parent, and the platform refuses `create_session` and `send_later` at depth 8.
Last run burned 12 controller sessions and two whole lines on this.
With the manager at depth 1, every controller is at depth 2 for the life of the project, and the leaves it spawns are at depth 3; leaves spawn nothing, so no depth grows.
A controller handoff asks the manager for its successor instead of spawning one; each request costs the manager about 1k tokens and needs no judgment about the controller's work.

A dedicated spawner session was rejected: it is one more session that holds `create_session`, answers to anyone who can message it, and adds a role to detect and guard.

The manager spawns a successor only when all of these hold, all read from `claude/run-state` rather than from the message:

- The Run line names the requesting session as Controller.
- The Run line carries `Handoff: requested <time UTC>`, written by that controller.
- No successor has been spawned for that request.

The hook lets only the controller push `claude/run-state`, so a worker following injected issue text cannot forge a request.

## Why sibling sessions for workers, reviewers, and auditors

In-process subagents die with their session.
Last run lost at least 13 worker and reviewer turns, 80k to 180k tokens each, to controller handoffs.
A worker that is its own session survives the handoff.

Cost: each session is a fresh container, so the environment setup script must make the repo testable (`composer install`, MariaDB) before this topology is usable at all; a worker that cannot run the check command is a blocked worker.

## Reports: GitHub is the record, messages are wakeups

A leaf's report is a PR comment (an issue comment for an auditor) opening with `Run report:` in the shape the `controller` skill defines, including `Tokens: <n>k` from its Stop hook.
After posting it, the leaf reads the Controller field of the Run line on `claude/run-state` and sends that session one `send_message`: `Report on #<n>`.

The controller rebuilds its view from GitHub on startup, on every wake, and on every check-in: in-flight issues and PRs from the state, and the latest `Run report:` comment on each.
A message that is lost, delayed, or sent to an archived predecessor costs one check-in interval, not the work; there is no re-pointing step at handoff.

## Context thresholds

The controller hands off at the `run-config.json` thresholds, 250k soft and 300k hard.
Handoffs are cheap now that leaves survive them, and a controller's gating judgment degrades with context long before the window fills, so the thresholds stay low.
The manager warns itself at 500k and 800k, because it lives for the project and carries the quality history.

## Question routing

What is worth surfacing to the owner is the open question; the rules below are the first guess.

| Question | Goes to | Who decides it is this kind |
|---|---|---|
| Reversible implementation choice | Nobody. The worker takes its recommended option and records it in the PR body | worker |
| Design question: which approach, where a behaviour belongs, a plan unit that no longer fits | Architect, by `send_message` from the controller; the architect answers in the issue and messages back | controller |
| One-way door: security, credentials, data loss, public interface or schema, irreversible external action, `CLAUDE.md` hard rule | Owner, on the controller's Questions list | worker names it, controller confirms |
| Non-reversible product question the architect cannot settle from the plan | Owner, from the architect's Questions list in `docs/plan.md` | architect |
| Process change | Owner, as an `approved` comment on the process PR | hook |
| Something outside the asker's work that should be addressed | Nobody waits: the worker, reviewer, or auditor files an issue labelled `triage`; the architect relabels it `ready` with the unit fields or closes it | asker |

The architect's answer lives in the issue, so the controller and the next worker read the same decision; a design answer that exists only in a message is not an answer.

Every routed question gets a row in `docs/run/questions.md` on `claude/run-state`: date, asked by, routed to, the question in one line, the answer in one line, and a `verdict` the owner fills: `right`, `should have been <role>`, or `not worth asking`.

## Quality signals

The manager's first job is output quality; routing is tuned only where these do not get worse.
The controller records one row per merged PR in `docs/run/quality.md` on `claude/run-state`, from artifacts that already exist:

| Signal | Source | Read as |
|---|---|---|
| Review rounds | reviewer verdicts per head SHA | Rejects at the first SHA show what workers miss |
| Holdout failures | reviewer report | The worker passed its own checks and still missed acceptance |
| Audit issues per merged PR | `audit` issues naming the PR | Defects that passed review |
| Reopened or reverted | issue reopen, revert PR | Escaped defects |
| Owner spot check | owner, on every fifth row | `good`, `acceptable`, or `wrong: <one line>` |

The manager reports these per run and may propose a routing or process change only with the rows that justify it.
Verdicts in `questions.md` and spot checks in `quality.md` are the owner's alone; the manager never fills either.

## Session lifecycle

- The owner starts the manager with dotfiles and the project repo attached.
- The manager starts the architect with `model` and `title` set explicitly; `create_session` otherwise inherits the parent's model.
- The architect plans, writing the plan and the issues itself; the owner approves the plan PR; the manager spawns the first controller.
- The controller spawns workers, reviewers, and auditors with `create_session`, each with the prompt from the `controller` skill, and requests its successor through the Run line and a message to the manager.
- A worker, reviewer, or auditor is archived by the controller after its report is recorded.
- A controller is archived by its successor.

## Role detection by the hook

Agent frontmatter no longer carries the role hooks, because the roles are sessions, not subagents.
`run-guard.mjs` derives the role from the start of the session's first user prompt only, so a mark quoted in a later message never changes a role:

| Mark | Role |
|---|---|
| `You are the manager for` | manager |
| `You are the architect for` | architect |
| `You are the controller for` | controller |
| `You are a worker in` | worker |
| `You are the reviewer for` | reviewer |
| `You are the auditor for` | auditor |

`PermissionRequest` auto-denies for every role but the manager, which the owner watches.
The project `PreToolUse` matcher becomes the union of the frontmatter matchers it replaces, adding `create_pull_request`, `update_pull_request`, `create_branch`, and `add_issue_comment`.

## Changes to the bundle

| File | Change |
|---|---|
| `skills/controller/SKILL.md` | Spawn leaves with `create_session` (`model`, `title`, prompt); reports read from `Run report:` comments, messages are wakeups; rebuild from GitHub on every wake; handoff writes `Handoff: requested` and messages the manager; remove lineage depth from the Run line, the successor prompt, and "Handoff and stopping"; Spend from each report's `Tokens:`; routing table above; `questions.md` and `quality.md` rows |
| `skills/run-init/files/hooks/run-guard.mjs` | Role from the first prompt's prefix, one mark per role; architect writes only under `docs/` outside `processPaths`; only the controller pushes `claude/run-state`; leaf Stop hook prints the session's token total for the report; drop "at depth 7" from the hard-limit message; auto-deny permission for every role but manager |
| `skills/run-init/files/settings-hooks.json` | `PreToolUse` matcher adds `create_pull_request`, `update_pull_request`, `create_branch`, `add_issue_comment` |
| `skills/run-init/files/agents/*.md` | Become prompt templates under `files/prompts/`, without frontmatter hooks; each leaf prompt carries the report procedure above |
| `skills/run-init/files/docs/run-process.md` | Roles table, Wakes, and Budgets rewritten for sessions; controller context row loses lineage depth; worker tokens from the report |
| `skills/run-init/SKILL.md` | Verify role detection per mark, including a quoted mark in a second prompt; environment setup script is a requirement |
| `skills/run-plan/SKILL.md` | Plan lives at `docs/plan.md`; the plan PR is approved and merged by the owner |
| New `skills/architect/SKILL.md` | `run-plan` plus the design-question procedure, `triage` issue review, and the Questions list |
| New `skills/manager/SKILL.md` | Quality signals and routing review, the controller spawn checks, the 500k and 800k self-warnings |

## Open risks

- `send_message` delivery has not been load-tested at three workers plus reviewers messaging one controller; reports on GitHub make a lost message cost a check-in interval, and the controller's 60-minute unstick rule stays for a leaf that never reports.
- The leaf token total comes from the transcript the Stop hook can read; a leaf that dies before stopping reports nothing, and Spend undercounts it.
- Disk per session is no longer shared, so the three-worker ceiling from worktree size no longer applies, but the Opus usage window still does.
- `triage` issues are a new way for an agent to widen scope; the architect closes anything that is not a defect or a plan gap, and the manager counts them per run.
- The manager is a single point of failure for handoffs; if it is unreachable, a controller at its hard limit stops and puts "manager unreachable" on the Questions list.
