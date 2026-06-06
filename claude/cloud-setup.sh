#!/usr/bin/env bash
# cloud-setup.sh — Bootstrap ~/.claude from the dotfiles repo for a Claude Code
# cloud session.  Cloud sessions start with an empty home directory, so this
# script populates ~/.claude before the session begins.
#
# Usage: paste this script (or a `curl | bash` one-liner pointing here) into the
# "Environment setup script" field in the Claude Code web UI.
#
# Requirements:
#   - The environment's network policy must allow outbound HTTPS to github.com.
#   - No authentication needed; the dotfiles repo is public.
#
# Design notes:
#   - set -euo pipefail: abort on unexpected errors so problems surface early.
#   - Idempotent: safe to run multiple times; later runs overwrite earlier ones.
#   - Graceful failure: if the clone fails (no network, etc.) we warn and exit 0
#     so the session still starts — just without the custom config.

set -euo pipefail

DOTFILES_REPO="https://github.com/IanEdington/dotfiles.git"
CLONE_DIR="$(mktemp -d)"
CLAUDE_SOURCE_DIR="${CLONE_DIR}/claude"
CLAUDE_TARGET_DIR="${HOME}/.claude"

# Ensure cleanup of the temp dir no matter how the script exits.
trap 'rm -rf "${CLONE_DIR}"' EXIT

# Write a failure notice into ~/.claude/CLAUDE.md BEFORE attempting the clone.
# If the clone succeeds this gets overwritten with the real config.
# If it fails, Claude reads this message and can inform the user at session start.
mkdir -p "${CLAUDE_TARGET_DIR}"
cat > "${CLAUDE_TARGET_DIR}/CLAUDE.md" <<'FAILURE_NOTICE'
> **Setup notice — read this first.**
> The cloud-setup script failed to clone the dotfiles repo, so your personal
> CLAUDE.md did not load. Please let the user know at the start of this session:
> "Your personal Claude config (CLAUDE.md from dotfiles) did not load — the
> setup script couldn't reach GitHub. Working with defaults for this session."
FAILURE_NOTICE

echo "[cloud-setup] Cloning dotfiles from ${DOTFILES_REPO} ..."

# Shallow clone — we only need the latest snapshot, not the full history.
if ! git clone --depth 1 --quiet "${DOTFILES_REPO}" "${CLONE_DIR}" 2>&1; then
  echo "[cloud-setup] WARNING: clone failed. Failure notice written to ~/.claude/CLAUDE.md." >&2
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
