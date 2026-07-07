# Claude Code config

Personal, cross-workspace Claude Code configuration. One source of truth, two
delivery mechanisms:

- **macOS (local)**: `./install` symlinks `~/.claude` to this directory.
  Edits here are live immediately, and anything Claude Code writes at runtime
  (sessions, caches, `policy-limits.json`, `stats-cache.json`) lands in this
  directory but is kept out of git by the whitelist `.gitignore`. Any new
  config file must be re-included there explicitly.
- **Cloud**: `cloud-setup.sh` is pasted into the environment setup script in
  the Claude Code web UI. It downloads the repo tarball (tracked files only)
  and copies `claude/` over `~/.claude`, coexisting with the runtime-managed
  files already there. It defaults to `main`; export `DOTFILES_REF` in the
  setup script to pin a tag or SHA.

## What lives where

| Concern | Where | Why |
| --- | --- | --- |
| Preferences, instructions | `CLAUDE.md` | Read on every session start |
| Permissions, hooks, attribution | `settings.json` | Enforced by the harness, not the model |
| Keybindings | `keybindings.json` | |
| MCP servers | `~/.claude.json` via `claude mcp add` (macOS), per-repo `.mcp.json` (cloud) | settings.json does not load MCP servers |
| Vim mode | `/vim` once per machine; persists in `~/.claude.json` | Not a settings.json key |

## settings.json notes

- `attribution: { commit: "", pr: "" }` suppresses the Claude byline;
  `includeCoAuthoredBy: false` is the deprecated spelling kept for older CLI
  versions.
- Pushes to main/master prompt for confirmation (`permissions.ask`); force
  pushes to main/master are denied. This is the enforceable version of the
  Git rule in CLAUDE.md.
- The rtk PreToolUse hook is guarded with `command -v rtk`, so it is a no-op
  on machines without rtk. In cloud, `cloud-setup.sh` installs rtk and runs
  `rtk init -g --auto-patch`; if that ever produces a duplicate hook entry,
  drop `--auto-patch` from the script. To get the same token savings locally,
  install rtk on the Mac (https://github.com/rtk-ai/rtk).
- The macOS notification hook is guarded by `uname`, so it is a no-op on
  Linux cloud sessions.

## Failure reporting in cloud

`cloud-setup.sh` writes a failure notice into `~/.claude/CLAUDE.md` before
downloading (overwritten on success), and best-effort steps append to
`~/.claude/cloud-setup-errors.log`. CLAUDE.md instructs Claude to report that
log at session start.
