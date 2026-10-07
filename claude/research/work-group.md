# Work group: the session topology for a run

Replaces the single-session design in `controller-worker-reviewer.md` for the parts below; the review, holdout, decision log, and hook mechanics stay.
Owner's definition, 2026-10-07.

## Roles

Every role is its own cloud session, titled `<group>: <role> <n>` (the wordpress-mcp group is `WP MCP`).
The owner talks to the manager, the architect, and the controller only.

| Role | Model | Lives | Spawned by | Does | Never |
|---|---|---|---|---|---|
| Manager | Fable | the whole project | owner | Analyses agent effectiveness and the question routing; proposes changes to dotfiles; starts the architect and the factory | Sets a timer, auto-compacts, reads or answers a controller question, writes product code |
| Architect | Fable | the whole project | manager | Plans (`run-plan`), answers design questions from the controller, reviews the queue when asked, keeps `docs/run/plan.md` | Writes code; hook denies Edit and Write outside `docs/` |
| Factory | Haiku | the whole project | manager | On a message from the manager or a controller, runs `create_session` for a new controller with the Opus model and the group title, replies with the session id | Anything else |
| Controller | Opus | one context window | factory | The loop in the `controller` skill: spawns workers, reviewers, and auditors as sessions, gates, merges, records, routes questions | Reads a diff, writes product code, answers a one-way door |
| Worker | Opus | one issue | controller | Implements the issue, pushes, opens the PR, reports | Merges, reads the holdout |
| Reviewer | Opus | one PR at one SHA | controller | Runs the checks and the holdout, posts the review, reports the verdict | Writes to the repo |
| Auditor | Opus | four merged PRs | controller | Files `audit` issues | Writes to the repo or PRs |

## Why a factory

`create_session` nests: a child is one level deeper than its parent, and the platform refuses `create_session` and `send_later` at depth 8.
Last run burned 12 controller sessions and two whole lines on this.
With the manager at depth 1 and the factory at depth 2, every controller is at depth 3 for the life of the project; a controller handoff asks the factory for its successor instead of spawning one.
Workers, reviewers, and auditors are spawned by the controller directly at depth 4; they spawn nothing, so their depth never matters, and routing them through the factory would only add a message round trip.
Haiku is enough for the factory: the job is one tool call with a fixed prompt, and it holds no judgment.
An idle factory's container is reclaimed, but `send_message` reprovisions it.

## Why sibling sessions for workers, reviewers, and auditors

In-process subagents die with their session.
Last run lost at least 13 worker and reviewer turns, 80k to 180k tokens each, to controller handoffs.
A worker that is its own session survives the handoff: the successor controller reads the state PR, messages each in-flight worker with its new session id, and loses nothing.
Reports arrive as `send_message` to the controller, which wakes it like a subagent notification did; the PR comment stays the human-readable record.

Cost: each session is a fresh container, so the environment setup script must make the repo testable (`composer install`, MariaDB) before this topology is usable at all; a worker that cannot run the check command is a blocked worker.

## Question routing

This is the part the manager watches most closely; what is worth surfacing to the owner is the open question, and the rules below are the first guess.

| Question | Goes to | Who decides it is this kind |
|---|---|---|
| Reversible implementation choice | Nobody. The worker takes its recommended option and records it in the PR body | worker |
| Design question: which approach, where a behaviour belongs, a plan unit that no longer fits | Architect, by `send_message` from the controller; the architect answers in the issue and messages back | controller |
| One-way door: security, credentials, data loss, public interface or schema, irreversible external action, `CLAUDE.md` hard rule | Owner, on the controller's Questions list | worker names it, controller confirms |
| Non-reversible product question the architect cannot settle from the plan | Owner, from the architect's own Questions list in `docs/run/plan.md` | architect |
| Process change | Owner, as an `approved` comment on the process PR | hook |
| Something outside the asker's work that should be addressed | Nobody waits: the worker, reviewer, or auditor files an issue labelled `triage`; the architect reviews `triage` issues, relabels them `ready` with the unit fields or closes them | asker |

Every routed question gets a row in `docs/run/questions.md` on `claude/run-state`: date, asked by, routed to, the question in one line, the answer in one line, and a `verdict` column the owner or manager fills later: `right`, `should have been <role>`, or `not worth asking`.
The verdict column is the data the manager uses to adjust the rules; expect several revisions.

## Session lifecycle

- The owner starts the manager with dotfiles and the project repo attached.
- The manager starts the architect and the factory, with `model` and `title` set explicitly; `create_session` otherwise inherits the parent's model.
- The architect plans, writing the plan and the issues itself; the owner approves the plan PR; the manager asks the factory for the first controller.
- The controller spawns workers, reviewers, and auditors with `create_session`, each with the prompt from the `controller` skill plus the controller's session id to report to, and asks the factory for its own successor.
- A worker, reviewer, or auditor is archived by the controller after its report is recorded.
- A controller is archived by its successor.

## Role detection by the hook

Agent frontmatter no longer carries the role hooks, because the roles are sessions, not subagents.
`run-guard.mjs` derives the role from the first user prompt instead: `You are the controller for`, `You are a worker in`, `You are the reviewer for`, `You are the auditor for`, `You are the architect for`.
The role rules stay as they are; only the source of the role changes.

## Changes to the bundle

| File | Change |
|---|---|
| `skills/controller/SKILL.md` | Spawn workers, reviewers, and auditors with `create_session` (`model`, `title`, prompt); report shape arrives by message, not Agent result; handoff asks the factory for a successor; Rebuild re-points live workers instead of restarting them; routing table above; thresholds 600k soft, 800k hard; `questions.md` row on every routed question |
| `skills/run-init/files/hooks/run-guard.mjs` | Role marks for every role; architect rule (writes only under `docs/`); thresholds from config |
| `skills/run-init/files/agents/*.md` | Become prompt templates under `files/prompts/`, without frontmatter hooks |
| `skills/run-init/files/docs/run-process.md` | Roles table, Wakes, and Budgets rewritten for sessions |
| `skills/run-init/SKILL.md` | Verify role detection per mark instead of subagent hooks; environment setup script is a requirement |
| New `skills/factory/SKILL.md` | The factory's one procedure and its reply shape |
| New `skills/architect/SKILL.md` | `run-plan` plus the design-question procedure, `triage` issue review, and the architect's Questions list |
| New `skills/manager/SKILL.md` | The manager's two purposes, the 500k and 800k self-warnings, how to read `questions.md` and the state PR |

## Open risks

- `send_message` delivery has not been load-tested at three workers plus reviewers messaging one controller; a lost message is a worker that looks stalled, so the controller's 60-minute unstick rule stays.
- Disk per session is no longer shared, so the three-worker ceiling from worktree size no longer applies, but the Opus usage window still does.
- A Haiku factory with `create_session` permission can be told to spawn by anyone who can message it; it must accept requests only from the manager and from the controller named on the state PR's Run line.
- `triage` issues are a new way for an agent to widen scope; the architect closes anything that is not a defect or a plan gap, and the manager counts them per run.
