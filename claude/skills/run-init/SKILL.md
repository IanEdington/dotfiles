---
name: run-init
description: Install the run process (controller, worker, reviewer, auditor) into the current repo so a long task can be executed by a controller session with Opus subagents in Claude Code cloud. Copies the agent definitions, the guard hook, the process doc, and the decisions log, wires settings and CLAUDE.md, and verifies the hooks. Use when asked to set up a repo for a controller run, long-running agent tasks, or a worker and reviewer process. Not for planning the task itself; that is run-plan.
---

# run-init: install the run process in a repo

Installs the files a controller run needs.
The design and its evidence: `../../research/controller-worker-reviewer.md` in dotfiles; the protocol the files implement: `files/docs/run-process.md`.

Requirements: a GitHub repo worked in a Claude Code cloud environment with Node 18+, the GitHub MCP server, and a check command (lint, typecheck, tests) that passes on the base branch.

## Package layout

```
files/agents/{worker,reviewer,auditor}.md   subagent definitions with their role hooks
files/hooks/run-guard.mjs                   PreToolUse, Stop, PermissionRequest guard
files/settings-hooks.json                   hooks block for .claude/settings.json
files/run-config.json                       base branch, check command, protected paths
files/docs/run-process.md                   the protocol
files/docs/decisions.md                     append-only process log, seeded with inherited lessons
files/claude-md-section.md                  section for the repo's CLAUDE.md
```

## Steps

1. **Preflight.** Repo root, GitHub remote, base branch name, the check command.
   Stop and ask if `.claude/agents/{worker,reviewer,auditor}.md`, `.claude/hooks/run-guard.mjs`, or `docs/run/` already exist.
   If `.claude/settings.json` already has hooks, merge the entries from `files/settings-hooks.json` by hand, do not overwrite.
2. **Copy.** `files/agents/*` to `.claude/agents/`; `files/hooks/run-guard.mjs` to `.claude/hooks/`; `files/run-config.json` to `.claude/run-config.json` with `base` and `check` filled in; `files/docs/*` to `docs/run/` replacing `TODAY` with today's UTC date; the hooks block into `.claude/settings.json`.
3. **Permissions.** Add to `.claude/settings.json` `permissions.allow` every command a worker needs without a prompt: the check command, `git status|diff|log|show|fetch|checkout|add|commit|merge|worktree`, `git push -u origin claude/*`, and the GitHub MCP tools `issue_read`, `issue_write`, `search_issues`, `search_pull_requests`, `pull_request_read`, `create_pull_request`, `update_pull_request`, `add_issue_comment`, `merge_pull_request`.
   A command missing here is a denied prompt and a `blocked` worker.
4. **CLAUDE.md.** Append `files/claude-md-section.md`; add `docs/run/run-process.md` and `docs/run/decisions.md` to the knowledge-base list if the repo has one.
   If the repo has a doc map (`docs/doc-map.tsv`), map `.claude/**` and `docs/run/**` to `docs/run/run-process.md`.
5. **Verify the hooks** in this session, each with a throwaway file:
   - `echo '<json>' | node .claude/hooks/run-guard.mjs pre-tool reviewer` with an Edit inside the repo: expect a deny; with `/tmp/x`: expect silence.
   - Same for `pre-tool worker` with `mcp__github__merge_pull_request`: deny.
   - Spawn a `worker` subagent (Agent tool, `subagent_type: worker`) whose task is to create and delete a scratch file under the repo and report whether it was allowed.
     This checks the role hooks in the agent frontmatter fire and that the project-level hook does not treat a subagent as the controller.
     If the write is denied, the harness passed no subagent marker to the project hook; set `controllerWritable` to include the repo root until the harness carries one, and record the finding in `docs/run/decisions.md`.
   - Push a commit to a throwaway branch with the check command made to fail (a lint error): expect the push denied with the output tail; fix, push, delete the branch.
6. **Deliver.** Commit on a feature branch and open a PR.
   It is a `process` PR: the owner approves it on GitHub.
   The PR body lists the labels `run-plan` will create and the controller prompt from the `controller` skill.

Done when: the four hook checks in step 5 behave as stated, `node --check .claude/hooks/run-guard.mjs` passes, and the PR is open.
