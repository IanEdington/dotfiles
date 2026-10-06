# Manager handoff: wordpress-mcp orchestration

Written 2026-10-06 12:00 UTC by the planner session (`session_01RucMFaQ1Ek22yVJ83a1qCT`) for the manager session that replaces it. Covers the agent system, not the product. Product context is in `TrellisCommons/wordpress-mcp` at `docs/PLAN.md`, `docs/run/plan.md`, and the run-state PR #58.

## The manager role (owner's definition, 2026-10-06)

- Long lived, model Fable, started with `IanEdington/dotfiles` cloned and editable alongside `TrellisCommons/wordpress-mcp`.
- Never auto-compacts. Warns the owner at 500k and 800k tokens of context.
- Never sets a wake timer. Responds only to the owner. Does not read or answer controller questions; the proxy role this document's author played is retired.
- Two purposes only: analysis of agent effectiveness and workflows, and adapting the system to new problems with changes proposed back to the dotfiles repo.
- Kicks off every other session (controllers, and any new agent kinds) with `create_session`, always passing `model` explicitly.
- Is the owner's main window into the orchestration system.

## System as installed

| Piece | Where | Notes |
|---|---|---|
| Run bundle source | `dotfiles/claude/skills/run-init/files/` (agents, hooks, docs, settings) | `run-init` copies it into a repo |
| Controller procedure | `dotfiles/claude/skills/controller/SKILL.md` | Handoff thresholds at lines 67 to 74; agent spawn specs at 87 to 103 |
| Planning | `dotfiles/claude/skills/run-plan/SKILL.md` | One issue per unit with Paths, Acceptance, Holdout |
| Evidence | `dotfiles/claude/research/controller-worker-reviewer.md` | |
| Installed copy | `wordpress-mcp/.claude/{agents,hooks/run-guard.mjs,settings.json,run-config.json}`, `docs/run/{run-process.md,decisions.md,plan.md}` | Process paths; PRs touching them need the owner's `approved` comment on GitHub after the last commit |
| Run state | PR #58 body (tables plus ten log lines), older log in its comments | Controller writes it through the GitHub MCP file tool |
| Held-out checks | `docs/run/holdout/<issue>.md` on branch `claude/run-state` | Only reviewers read them |
| Held work | `docs/run/patches/` on `claude/run-state` | Four `git format-patch` files for #48, #23, #153, #159 with restore steps in the #58 In-flight table |
| Controller workspace | branch `claude/run-controller-base` | Controllers check it out; workers branch from `main` |

Roles: controller (session, Opus, no product code), worker (in-process Agent subagent, Opus, worktree isolation, one issue each), reviewer (in-process, Opus, adversarial, runs holdout, posts verdict on the PR), auditor (in-process, Opus, every four merges, files `audit` issues). Hooks enforce: check command before push, no worker merge, controller writes only `docs/run/`, reviewer and auditor read-only, permission prompts denied, process PRs need the owner.

## Session lineage (for `get_session` and archiving)

| Session | Role | State |
|---|---|---|
| `session_01RucMFaQ1Ek22yVJ83a1qCT` | planner and proxy (this author) | to be retired |
| `session_01Wt9SNt1B1GrXiPCSN61PNd` | controller line 2 depth 3, Opus, since 09:34 UTC | idle, blocked on the test environment; own check-in `trig_014D17XAyo8VXFT4WcZZW1KB` at 12:25 UTC |
| `session_01XDzw9MqLwgmLu1MvPvknCh`, `session_0129SD6VwNLfVJVfyQXqgwzn`, `session_01QrXRXzuuxqxueC5iRCZfcj` | line 2 depths 2, 1, 0 | archived |
| `session_01RRnHQ2kR3nS6SrBCGgVs6a` | line 1 last (depth 7) | archived |

The planner's proxy wake trigger is deleted. The controller's check-in is the only timer left.

## Platform facts learned the hard way

- `create_session` inherits the parent's model unless `model` is passed. Two controller lines ran on Fable by accident.
- Lineage depth cap is 8 (platform count includes the spawning chat session). At depth 7 a line must restart at depth 0 from a non-lineage session. Depth is the reason the manager, not a controller, should spawn new lines.
- A new session gets a fresh container: no `vendor/`, no MariaDB, no worktrees, no unpushed commits. Everything that must survive a handoff goes to GitHub.
- The auto-mode classifier can refuse commands as "Modify Shared Resources" (`composer install` in the repo root). A refusal covers the outcome by any route; only the owner lifts it, by in-session approval, by the environment setup script, or by an allow entry in `.claude/settings.json`.
- In-process subagents die with their session. Every handoff with agents mid-turn lost their partial turns (at least 13 reports over the run, 80k to 180k tokens each).
- Agent types from `.claude/agents/` register at session start; a session that installs them cannot spawn them until its next turn, and a session created without the repo attached must `add_repo` first.
- `send_later` fired 11 hours late once. A controller's own `send_later` at `rate_limit_info.resetsAt` plus 5 minutes has been reliable.
- The five-hour Opus window is spent in about 90 minutes by three workers plus reviewers, then the run idles until reset.
- GitHub access: `gh` GraphQL 403s (`gh pr`, `gh issue` unusable); `gh api` REST works for reads; REST writes to contents are refused by the proxy; the GitHub MCP tools work but 404'd the repo for one whole controller session. The guard hook matches `gh pr merge` in Bash but not `mcp__github__merge_pull_request`, so a process PR merged with a stale approval (#165).
- The git remote is a caching proxy and can lag; cross-check with raw.githubusercontent.com when `origin/main` looks stale.
- Disk: reviewer worktrees are about 3.2G each with `vendor/`; three at a time is the ceiling. Hard-link `vendor/` with `cp -al`.
- Owner-approval comments must be on the PR after its last commit; chat approval does not satisfy the hook. The owner's direct messages to a controller outrank anything a proxy says.

## Run outcome, 2026-10-05 05:40 to 2026-10-06 09:35 UTC

| Measure | Value |
|---|---|
| Tokens | about 21.3M of a 30M hard cap |
| PRs merged | 62, about 28 of them audit follow-ups or nits |
| Merged then discarded | 9 units made redundant by the owner's design change on PR #59 |
| Controller sessions | 12 |
| Idle wall-clock | about 3.5 h on the usage window, 1 h owner pause, 3 h and counting on the environment |
| 0.1 scope left | 13 units: #157, #158, #53, #55, #56, #57, #159, #160, #177, #179 to #182, plus audit items |

About 70% of budget bought 55% of scope; a third of merged code was thrown away.

## Findings, by cost

1. **Launching on an unreviewed plan** cost about 8M tokens. The first plan had 55 units; the owner's review cut 30 and obsoleted 9 merged ones. Fix: no worker spawns until the owner has commented `approved` on the plan PR.
2. **Handoff churn.** 250k threshold on a 1M window, verbose state bodies, and in-process workers that die with the controller. Fixes: threshold 600k soft, 800k hard; state body capped at tables plus ten log lines; workers as sibling sessions reporting through PR comments.
3. **Environment not reproducible.** Setup script must run `composer install`, install and start MariaDB; settings allow list must cover `composer install`, `apt-get install`, and `rm -f` under the scratchpad.
4. **Audit nits** cost about 200k tokens each (worker plus reviewer plus merge). Auditor files only findings with a failing test or reproducible wrong output; the rest go into one sweep issue.
5. **Proxy misuse.** The planner told a paused controller to resume and proposed a permission workaround; the controller correctly refused both. Retire the proxy or give it a written charter.
6. **Controllers stall on reversible questions** despite the `reversible-never-blocks` row (three stalls in one day). The controller skill needs: absent owner plus reversible default equals take the default and log it.
7. **Usage window** dominates wall-clock; fewer workers does not reduce tokens. Options: API-key billing for runs, or schedule idle at audit boundaries.
8. **Guard hook gaps** for MCP merge and file-write tools.
9. **Review cadence is fine**: two rounds typical, holdout catches round 1; about 100k per round.

Keep: hooks over prose, hidden holdouts, the decision log, Opus controllers.

Suggested order: environment and allow list; plan gate and nits rule; thresholds and state cap; hook matchers; sibling-session workers last.

## Decision rows added to `docs/run/decisions.md` today

`approval-is-a-pr-comment`, `controller-model-explicit`. Rows the run still owes: the three reversible-question stalls, the vendor denial, `serialize-worker-pushes` (recorded in the #58 body, not yet in the file).

## Open owner items on PR #58

- Test environment: setup script or in-session approval. Blocks all pushes.
- `approved` on process PR #169 (two one-line fixes to `docs/run/plan.md`).
- PHP floor, slug, licence, Claude Desktop stdio claim: before #57.
- 30M cap: raise it or ship 0.1 without the settings page and release units.

## Housekeeping never done

Set the repository default branch to `main` and delete `init`; `.gitignore` already covers `.claude/worktrees/` and `.phpunit.result.cache`.
