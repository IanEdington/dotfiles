# Run process bundle

Six user-level skills and the files they install, for working a long task as a group of Claude Code cloud sessions.

| Piece | Where it runs | Does |
|---|---|---|
| `run-init` | once per repo | Installs the leaf prompts, guard hook, process doc, decisions log |
| `manager` | one Fable session per project, started by the owner | Starts the architect and the factory, measures quality and routing, proposes process changes |
| `architect` | one Fable session per project | The plan as a tracking issue with sub-issues (`run-plan`), design answers on the issue, `triage` review |
| `factory` | one Opus session per project | One controller per verified request, so lineage depth never grows |
| `run-plan` | once per task, by the architect | Tracking issue, one sub-issue per unit, held-out checks, the run-state PR |
| `controller` | one Opus session per context window | Spawns workers, reviewers, and auditors as sessions; gates merges; routes questions |
| `worker` prompt | one Opus session per issue | One issue, own branch, `Run report:` comment |
| `reviewer` prompt | one Opus session per PR and SHA | Blind adversarial review, runs the held-out check, posts on the PR |
| `auditor` prompt | one Opus session per four merges | Post-merge audit, files `audit` issues |
| `run-guard.mjs`, `run-guard.test.mjs` | hook and its table test | The rules that were broken as prose: role from the first prompt, push check, no worker merge, controller writes only `docs/run/`, read-only reviewer, auditor, architect, and factory, only the controller updates the state PR, owner approval on process PRs, denied permission prompts, controller handoff thresholds |

Design positions and the evidence behind them: `../../research/work-group.md` and `../../research/controller-worker-reviewer.md`.
Lessons inherited from earlier runs are the first rows of `files/docs/decisions.md`.

## Unverified

Checked in `run-init` step 5 on first install, and worth re-checking on each Claude Code release:

- Whether `create_session` with `source_url` gives the leaf the repo's `.claude/settings.json` hooks before its first tool call.
- Whether `send_message` delivery holds at three workers plus reviewers messaging one controller; the controller rebuilds from `Run report:` comments either way.
- Whether `total_cost_usd` on a session's result events restarts when its container is reprovisioned; the controller sums before each drop in case it does.
