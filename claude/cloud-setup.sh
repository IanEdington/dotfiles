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

echo "[cloud-setup] Cloning dotfiles from ${DOTFILES_REPO} ..."

# Shallow clone — we only need the latest snapshot, not the full history.
if ! git clone --depth 1 --quiet "${DOTFILES_REPO}" "${CLONE_DIR}" 2>&1; then
  echo "[cloud-setup] WARNING: clone failed. Skipping ~/.claude setup." >&2
  exit 0
fi

if [ ! -d "${CLAUDE_SOURCE_DIR}" ]; then
  echo "[cloud-setup] WARNING: no claude/ directory found in repo. Skipping." >&2
  exit 0
fi

echo "[cloud-setup] Copying claude/ contents into ${CLAUDE_TARGET_DIR} ..."
mkdir -p "${CLAUDE_TARGET_DIR}"

# Copy everything under claude/ — Claude Code only reads files it knows about
# (e.g. CLAUDE.md), so extra files like README.md are harmless.
cp -r "${CLAUDE_SOURCE_DIR}/." "${CLAUDE_TARGET_DIR}/"

echo "[cloud-setup] Done. ${CLAUDE_TARGET_DIR} contents:"
ls "${CLAUDE_TARGET_DIR}"
