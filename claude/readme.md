# Claude Code config

Personal, cross-workspace Claude Code configuration. One source of truth, two
delivery mechanisms:

- **macOS (local)**: `./install` symlinks `~/.claude` to this directory.
  Edits here are live immediately, and anything Claude Code writes at runtime
  (sessions, caches, `policy-limits.json`, `stats-cache.json`) lands in this
  directory but is kept out of git by the `.gitignore` blocklist. A new
  untracked file in `git status` means Claude Code grew a new runtime file:
  decide to track it or add it to the blocklist. Never track
  `.credentials.json`.
- **Cloud**: each cloud environment's setup script (web UI) runs the
  [snippet below](#cloud-environment-setup-script), which fetches
  `cloud-setup.sh`. That script downloads the repo tarball (tracked files
  only) and copies `claude/` over `~/.claude`, coexisting with the
  runtime-managed files already there.

## Cloud environment setup script

Paste this into the environment's setup script field in the Claude Code web
UI:

```bash
# Claude dotfiles bootstrap. DOTFILES_REF is a branch, tag, or SHA and is
# part of this script's text, so pasting a new ref forces the environment
# cache to rebuild with exactly that version.
# Download-then-run (not curl|bash) so a failed fetch reaches the else branch.
export DOTFILES_REF="main"
if curl -fsSL "https://raw.githubusercontent.com/IanEdington/dotfiles/${DOTFILES_REF}/claude/cloud-setup.sh" -o /tmp/dotfiles-cloud-setup.sh; then
  bash /tmp/dotfiles-cloud-setup.sh
else
  mkdir -p ~/.claude
  printf 'Tell the user: dotfiles cloud-setup.sh could not be fetched (ref %s); this session runs with default config.\n' "${DOTFILES_REF}" > ~/.claude/CLAUDE.md
fi
```

### Updating environments

The setup script runs once per environment, then the filesystem snapshot is
cached. The cache rebuilds only when the setup script text (or allowed
network hosts) changes, or after roughly seven days. Two strategies:

- **`DOTFILES_REF="main"`** (default above): every rebuild picks up latest
  main, so changes propagate everywhere within a week with no action. To
  force one environment to update now, change any character of its setup
  script (bump a comment) and start a session.
- **Pin a SHA or tag** (`DOTFILES_REF="v2026.07.07"`): publish flow is push
  to main, tag it, update the ref here and in each environment. Pasting the
  new ref rebuilds immediately. Trade-off: a pinned environment never drifts,
  which also means it never auto-updates; the seven-day rebuild refetches the
  same pinned ref forever.

## What lives where

| Concern | Where | Why |
| --- | --- | --- |
| Preferences, instructions | `CLAUDE.md` | Read on every session start |
| Permissions, hooks, attribution | `settings.json` | Enforced by the harness, not the model |
| Keybindings | `keybindings.json` | |
| MCP servers | `~/.claude.json` via `claude mcp add` (macOS), per-repo `.mcp.json` (cloud) | settings.json does not load MCP servers |
| Vim mode | `editorMode` in `settings.json` | |

`~/.claude.json` also holds OAuth state and per-project trust; it is managed
by Claude Code and not safe to edit directly. Go through `claude mcp add` /
`/config` instead.

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
