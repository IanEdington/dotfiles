# Run process bundle

Three user-level skills and the files they install, for working a long task in one Claude Code cloud session with Opus subagents.

| Piece | Where it runs | Does |
|---|---|---|
| `run-init` | once per repo | Installs agents, guard hook, process doc, decisions log |
| `run-plan` | once per task | Plan doc, one issue per unit of work, held-out checks, the run-state PR |
| `controller` | the main session, started by the owner | Spawns workers, reviewers, and auditors; gates merges; keeps the Questions list |
| `worker` agent | subagent | One issue, own worktree and branch, short report |
| `reviewer` agent | subagent | Blind adversarial review at one SHA, runs the held-out check, posts on the PR |
| `auditor` agent | subagent | Post-merge audit every four PRs, files `audit` issues |
| `run-guard.mjs` | hook | The rules that were broken as prose: push check, no worker merge, controller writes only `docs/run/`, read-only reviewer and auditor, owner approval on process PRs, denied permission prompts, controller handoff thresholds |

Design positions and the evidence behind them: `../../research/controller-worker-reviewer.md`.
Lessons inherited from the google-mcp coordinated runs are the first rows of `files/docs/decisions.md`.

## What differs from google-mcp's coordinator

- Workers and reviewers are in-session subagents, so there are no mailboxes, relays, subscriptions, or lineage handoffs.
- The controller spawns the reviewer and receives the verdict directly; the worker never sees or relays it.
- Each issue has a held-out check on the run-state branch that only the reviewer runs.
- The controller hands off to a successor session at its context limit, up to lineage depth 7; in-flight subagents die with it, so it prefers handing off between worker turns.
- Opus only.

## Unverified

Checked in `run-init` step 5 on first install, and worth re-checking on each Claude Code release:

- Whether the project-level hook can tell a subagent's tool call from the controller's (`agent_id` in hook input, or an `agent-` transcript name).
- Whether `hooks` in agent frontmatter run with `$CLAUDE_PROJECT_DIR` set when the agent runs in a worktree.
- Whether background subagents survive the cloud session being backgrounded; the controller treats a missing report as a dead worker either way.
- Per-subagent token counts in the Agent result are the only spend signal; USD is not exposed.
