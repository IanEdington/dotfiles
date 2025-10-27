#!/bin/sh
set -eu
umask 022

# Minimal, explicit PATH; do not rely on user environment
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export PATH

log() {
  echo "[yabai-sa] $(date '+%F %T') $*"
}

# Loop forever; when a console user is present and Dock is running, (re)load SA
last_pid=""
while :; do
  CONSOLE_USER=$(stat -f%Su /dev/console 2>/dev/null || echo root)
  if [ "$CONSOLE_USER" = "root" ] || [ -z "$CONSOLE_USER" ]; then
    sleep 5
    continue
  fi

  pid=$(pgrep -u "$CONSOLE_USER" -x Dock || true)
  if [ -n "$pid" ] && [ "$pid" != "$last_pid" ]; then
    log "Dock pid=$pid detected; loading SA"
    /opt/homebrew/bin/yabai --load-sa || log "load-sa failed"
    last_pid="$pid"
  fi

  sleep 5
done


