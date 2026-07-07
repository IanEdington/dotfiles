#!/usr/bin/env bash
# cloud-setup.sh — Bootstrap ~/.claude from the dotfiles repo for a Claude Code
# cloud session.  Cloud sessions start with an empty home directory, so this
# script populates ~/.claude before the session begins.
#
# Usage: paste the bootstrap snippet from claude/readme.md (a `curl | bash`
# one-liner pointing here) into the "Environment setup script" field in the
# Claude Code web UI.
#
# Requirements:
#   - The environment's network policy must allow outbound HTTPS to github.com
#     (and objects.githubusercontent.com, for rtk release binaries below).
#   - No authentication needed; the dotfiles repo is public.
#
# Design notes:
#   - set -euo pipefail: abort on unexpected errors so problems surface early.
#   - Idempotent: safe to run multiple times; later runs overwrite earlier ones.
#   - Graceful failure: if the clone fails (no network, etc.) we warn and exit 0
#     so the session still starts — just without the custom config.
#   - Uses curl+tar instead of git clone: Claude Code remote sessions inject a
#     git insteadOf rule routing all github.com traffic through a session-scoped
#     proxy. The dotfiles repo is not in the session's authorized list, so
#     git clone returns 403. curl is unaffected by git config.

set -euo pipefail

# DOTFILES_REF accepts a branch, tag, or commit SHA. Defaults to main so new
# sessions always get the latest config; export a tag/SHA in the environment
# setup script to pin instead (e.g. after a bad push to main).
DOTFILES_REF="${DOTFILES_REF:-main}"
DOTFILES_TARBALL="https://github.com/IanEdington/dotfiles/archive/${DOTFILES_REF}.tar.gz"
CLONE_DIR="$(mktemp -d)"
CLAUDE_SOURCE_DIR="${CLONE_DIR}/claude"
CLAUDE_TARGET_DIR="${HOME}/.claude"

# Best-effort steps (like rtk below) log here instead of just stderr, because
# nothing reads this script's console output once the cached environment is
# built — CLAUDE.md tells Claude to check this file and report failures.
ERRORS_LOG="${CLAUDE_TARGET_DIR}/cloud-setup-errors.log"

# Ensure cleanup of the temp dir no matter how the script exits.
trap 'rm -rf "${CLONE_DIR}"' EXIT

# Write a failure notice into ~/.claude/CLAUDE.md BEFORE attempting the clone.
# If the clone succeeds this gets overwritten with the real config.
# If it fails, Claude reads this message and can inform the user at session start.
mkdir -p "${CLAUDE_TARGET_DIR}"
: > "${ERRORS_LOG}"

# Appends to ERRORS_LOG (in addition to stderr) so failures in best-effort
# steps reach the user even though nobody watches this script run live.
log_warning() {
  echo "[cloud-setup] WARNING: $*" >&2
  echo "$*" >> "${ERRORS_LOG}"
}

cat > "${CLAUDE_TARGET_DIR}/CLAUDE.md" <<'FAILURE_NOTICE'
## IMPORTANT — action required before responding to anything else

The cloud-setup script could not clone the dotfiles repo, so your personal
CLAUDE.md did not load and your preferences are unavailable for this session.

**Notify the user immediately with this message (before doing anything else):**

> ⚠️ Your personal Claude config (CLAUDE.md from your dotfiles) did not load —
> the setup script couldn't reach GitHub. I'm working with defaults for this
> session. Check that your environment's network policy allows outbound HTTPS
> to github.com, then restart the session to pick up your config.
FAILURE_NOTICE

echo "[cloud-setup] Downloading dotfiles from ${DOTFILES_TARBALL} ..."

if ! curl -fsSL "${DOTFILES_TARBALL}" | tar -xz -C "${CLONE_DIR}" --strip-components=1; then
  echo "[cloud-setup] WARNING: download failed. Failure notice written to ~/.claude/CLAUDE.md." >&2
  exit 0
fi

if [ ! -d "${CLAUDE_SOURCE_DIR}" ]; then
  echo "[cloud-setup] WARNING: no claude/ directory found in repo. Failure notice left in place." >&2
  exit 0
fi

echo "[cloud-setup] Copying claude/ contents into ${CLAUDE_TARGET_DIR} ..."

# Overwrite the failure notice (and any other files) with real config.
cp -r "${CLAUDE_SOURCE_DIR}/." "${CLAUDE_TARGET_DIR}/"

echo "[cloud-setup] Done. ${CLAUDE_TARGET_DIR} contents:"
ls "${CLAUDE_TARGET_DIR}"

# --- rtk: compress verbose CLI output before it reaches the model --------
# rtk (https://github.com/rtk-ai/rtk) proxies commands like git/test-runners/
# package managers and returns filtered output, cutting token usage on long
# cloud sessions. `rtk init -g --auto-patch` registers a PreToolUse hook in
# the settings.json we just copied above, so it must run after that copy.
# Best-effort: install/hook failures must not fail session startup.
echo "[cloud-setup] Installing rtk ..."

if curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh; then
  export PATH="${HOME}/.local/bin:${PATH}"
  if command -v rtk >/dev/null 2>&1; then
    if rtk init -g --auto-patch; then
      echo "[cloud-setup] rtk installed and hooked into settings.json."
    else
      log_warning "rtk installed but 'rtk init -g --auto-patch' failed; hook not registered."
    fi
  else
    log_warning "rtk install script ran but 'rtk' is not on PATH."
  fi
else
  log_warning "rtk install failed (network?). rtk is unavailable this session."
fi
