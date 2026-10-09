#!/usr/bin/env bash
set -euo pipefail

# 4G swap file so a burst of Chromium + test runs degrades instead of OOM-killing.
SWAPFILE=/swapfile
SWAP_SIZE=4G

if ! swapon --show=NAME --noheadings | grep -qx "$SWAPFILE"; then
    [ -f "$SWAPFILE" ] || fallocate -l "$SWAP_SIZE" "$SWAPFILE"
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE" > /dev/null
    swapon "$SWAPFILE"
fi
grep -q "^$SWAPFILE " /etc/fstab || echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab

echo 'vm.swappiness=10' > /etc/sysctl.d/99-swap.conf
sysctl -q -p /etc/sysctl.d/99-swap.conf
