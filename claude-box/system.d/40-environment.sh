#!/usr/bin/env bash
set -euo pipefail

# CLAUDE_BOX=true marks every shell and Claude session on this server, so
# scripts, hooks and prompts can tell they are running on the claude-box.
BOX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd -P )"

# /etc/environment is read by pam_env for SSH/mosh logins, su, sudo and cron,
# and by systemd user services via /usr/lib/environment.d/99-environment.conf.
grep -qx 'CLAUDE_BOX=true' /etc/environment || echo 'CLAUDE_BOX=true' >> /etc/environment

# Managed settings reach every Claude Code session however it was started.
# Root-owned, so the agent user can't edit them.
install -d -m 755 /etc/claude-code/managed-settings.d
install -m 644 "$BOX_DIR"/managed-settings.d/*.json /etc/claude-code/managed-settings.d/
