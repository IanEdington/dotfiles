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
# Claude dotfiles bootstrap, always tracking main. Bump DOTFILES_VERSION and
# re-paste to rebuild this environment's cached image now; otherwise it
# refreshes on its own within ~7 days. The version rides on the URL as a
# query param, which also skips any stale CDN copy of the raw file.
# Download-then-run (not curl|bash) so a failed fetch reaches the else branch.
DOTFILES_VERSION=1
if curl -fsSL "https://raw.githubusercontent.com/IanEdington/dotfiles/main/claude/cloud-setup.sh?v=${DOTFILES_VERSION}" -o /tmp/dotfiles-cloud-setup.sh; then
  bash /tmp/dotfiles-cloud-setup.sh
else
  mkdir -p ~/.claude
  printf 'Tell the user: dotfiles cloud-setup.sh could not be fetched (version %s); this session runs with default config.\n' "${DOTFILES_VERSION}" > ~/.claude/CLAUDE.md
fi
```

### Updating environments

The setup script runs once per environment, then the filesystem snapshot is
cached. The cache rebuilds only when the setup script text (or allowed
network hosts) changes, or after roughly seven days. Since the snippet
tracks main, every rebuild picks up the latest config, so pushed changes
propagate everywhere within a week with no action.

To update an environment immediately: push to main, bump `DOTFILES_VERSION`
in the environment's setup script, and start a session. To pin an exact
version instead, `export DOTFILES_REF=<tag or SHA>` before the curl line and
use the ref in the URL; cloud-setup.sh downloads the tarball at
`DOTFILES_REF` (default main).

## What lives where

| Concern | Where | Why |
| --- | --- | --- |
| Preferences, instructions | `CLAUDE.md` | Read on every session start |
| Git author identity (cloud) | `SessionStart` hook in `settings.json` | The harness writes `~/.gitconfig` after the setup script runs |
| Permissions, hooks, attribution | `settings.json` | Enforced by the harness, not the model |
| Keybindings | `keybindings.json` | |
| MCP servers | `~/.claude.json` via `claude mcp add` (macOS), per-repo `.mcp.json` (cloud) | settings.json does not load MCP servers |
| Vim mode | `editorMode` in `settings.json` | |
| Context usage warnings | `UserPromptSubmit` hook in `settings.json` | Cloud sessions have no status line |

`~/.claude.json` also holds OAuth state and per-project trust; it is managed
by Claude Code and not safe to edit directly. Go through `claude mcp add` /
`/config` instead.

## settings.json notes

- `attribution: { commit: "", pr: "" }` suppresses the Claude byline;
  `includeCoAuthoredBy: false` is the deprecated spelling kept for older CLI
  versions.
- Pushes to origin main/master, including force pushes, are denied outright
  (`permissions.deny`). This is the enforceable version of the Git rule in
  CLAUDE.md.
- The macOS notification hook is guarded by `uname`, so it is a no-op on
  Linux cloud sessions.
- The `SessionStart` hook points the harness gitconfig at
  `git-identity.config`, which owns the cloud git author identity and
  documents how to add per-repo overrides. It fires only when the identity is
  the Anthropic cloud default, so it is a no-op on macOS — necessary, because
  a `git config --global` write there creates `~/.gitconfig`, which git
  prefers over `~/.config/git/config` and would shadow the symlinked config.
  It has to be a hook rather than a line in `cloud-setup.sh`: the harness
  writes `~/.gitconfig` after the setup script finishes.
- The `UserPromptSubmit` hook runs `hooks/context-usage-warning.py`, which
  warns once at 50% and once at 80% of the context window. Cloud sessions
  render no status line, so this is the only ambient signal that context is
  filling. Hook input carries no token counts, so the script derives usage
  from the last assistant message in the transcript (input + cache read +
  cache creation) and divides by a per-model window, overridable with
  `CLAUDE_CODE_AUTO_COMPACT_WINDOW`. That reads slightly low, because the
  transcript lags the live conversation by up to a turn; `/context` is
  authoritative. The warning goes out on two channels because `systemMessage`
  alone renders as a collapsed "Claude Code notices" row in the web UI, which
  is easy to miss: `additionalContext` asks Claude to lead its next reply with
  the same line, putting it in the main message flow. The other two hook
  output channels were tested in a cloud session and rejected: `exit 2` is
  unmissable but erases the prompt it interrupts, and `terminalSequence` is
  discarded entirely, escape codes and plain text alike.
- Cloud commits are signed with an Anthropic SSH key not registered to this
  account, so they show as **Unverified** on GitHub. Dropping the
  `SessionStart` hook trades the identity back for a verified badge.

## Failure reporting in cloud

`cloud-setup.sh` writes a failure notice into `~/.claude/CLAUDE.md` before
downloading (overwritten on success), and best-effort steps append to
`~/.cloud-setup-errors.log`. CLAUDE.md instructs Claude to report that
log at session start.
