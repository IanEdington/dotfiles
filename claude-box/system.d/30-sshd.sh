#!/usr/bin/env bash
set -euo pipefail

# Key-only SSH. sshd takes the first value it reads for each option, and
# cloud-init's 50-cloud-init.conf sets PasswordAuthentication yes, which
# silently overrode the `no` in sshd_config. A 00- drop-in sorts first and wins.
cat > /etc/ssh/sshd_config.d/00-claude-box.conf <<'CONF'
# Managed by dotfiles/claude-box/system.d/30-sshd.sh
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
CONF

sshd -t
systemctl reload ssh

sshd -T | grep -x 'passwordauthentication no' > /dev/null || {
    echo "sshd still allows passwords; check /etc/ssh/sshd_config.d" >&2
    exit 1
}
