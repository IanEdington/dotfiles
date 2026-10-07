---
name: run-init
description: Install the run process (controller, workers, reviewers, auditors as cloud sessions) into the current repo so a long task can be executed by a controller session in Claude Code cloud. Copies the leaf prompts, the guard hook, the process doc, and the decisions log, wires settings and CLAUDE.md, and verifies the hooks. Use when asked to set up a repo for a controller run, long-running agent tasks, or a worker and reviewer process. Not for planning the task itself; that is run-plan.
---

# run-init: install the run process in a repo

Installs the files a controller run needs.
The design and its evidence: `../../research/work-group.md` and `../../research/controller-worker-reviewer.md` in dotfiles; the protocol the files implement: `files/docs/run-process.md`.

Requirements: a GitHub repo worked in a Claude Code cloud environment with Node 18+, the GitHub MCP server, the claude-code-remote MCP server, a check command (lint, typecheck, tests) that passes on the base branch, and an environment setup script that makes the check command runnable in a fresh container (every leaf is a fresh container).

## Package layout

```
files/prompts/{worker,reviewer,auditor}.md   leaf prompt bodies; the controller prepends the role line
files/hooks/run-guard.mjs                    PreToolUse, Stop, PermissionRequest guard, role from the first prompt
files/hooks/run-guard.test.mjs               table of each role's allowed and denied calls
files/settings-hooks.json                    hooks block for .claude/settings.json
files/run-config.json                        base branch, check command, protected paths
files/docs/run-process.md                    the protocol
files/docs/decisions.md                      append-only process log, seeded with inherited lessons
files/claude-md-section.md                   section for the repo's CLAUDE.md
```

## Steps

1. **Preflight.** Repo root, GitHub remote, base branch name, the check command, and whether the environment's setup script runs the install the check command needs (ask the owner; a leaf cannot install anything).
   Stop and ask if `.claude/hooks/run-guard.mjs` or `docs/run/` already exist.
   If `.claude/settings.json` already has hooks, merge the entries from `files/settings-hooks.json` by hand, do not overwrite.
2. **Copy.** `files/prompts/*` to `docs/run/prompts/`; `files/hooks/run-guard.mjs` and `files/hooks/run-guard.test.mjs` to `.claude/hooks/`; `files/run-config.json` to `.claude/run-config.json` with `base` and `check` filled in; `files/docs/*` to `docs/run/` replacing `TODAY` with today's UTC date; the hooks block into `.claude/settings.json`.
3. **Permissions.** Add to `.claude/settings.json` `permissions.allow` every command a session needs without a prompt: the check command, `git status|diff|log|show|fetch|checkout|add|commit|merge|worktree`, `git push -u origin claude/*`, the GitHub MCP tools `issue_read`, `issue_write`, `sub_issue_write`, `search_issues`, `search_pull_requests`, `pull_request_read`, `create_pull_request`, `update_pull_request`, `add_issue_comment`, `merge_pull_request`, `create_branch`, `create_or_update_file`, and the claude-code-remote tools `create_session`, `get_session`, `archive_session`, `send_message`, `list_events`, `send_later`, `delete_trigger`.
   A tool missing here is a denied prompt and a `blocked` leaf.
4. **CLAUDE.md.** Append `files/claude-md-section.md`; add `docs/run/run-process.md` and `docs/run/decisions.md` to the knowledge-base list if the repo has one.
   If the repo has a doc map (`docs/doc-map.tsv`), map `.claude/**` and `docs/run/**` to `docs/run/run-process.md`.
5. **Verify the hooks.** `node .claude/hooks/run-guard.test.mjs` walks every role's permitted and forbidden calls, a quoted mark, a subagent, and the permission prompt; it must print `ok`.
   When a skill or prompt gains a tool call, add its row to the test first.
   Then push a commit to a throwaway branch with the check command made to fail (a lint error): expect the push denied with the output tail; fix, push, delete the branch.
6. **Deliver.** Commit on a feature branch and open a PR.
   It is a `process` PR: the owner approves it on GitHub.
   The PR body lists the labels `run-plan` will create and the manager's start prompt from the `manager` skill.

Done when: the hook checks in step 5 behave as stated, `node --check .claude/hooks/run-guard.mjs` passes, and the PR is open.
