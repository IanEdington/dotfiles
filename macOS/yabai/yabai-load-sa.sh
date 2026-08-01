#!/bin/sh
set -eu
umask 022

# Minimal, explicit PATH; do not rely on user environment
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin
export PATH

YABAI=/opt/homebrew/bin/yabai

log() {
  echo "[yabai-sa] $(date '+%F %T') $*"
}

load_sa() {
  # Capture yabai's own diagnostics; without them "load-sa failed" is unactionable.
  rc=0
  out=$("$YABAI" --load-sa 2>&1) || rc=$?
  if [ -n "$out" ]; then
    log "yabai --load-sa (rc=$rc): $out"
  fi
  return $rc
}

# Loop forever; when a console user is present and Dock is running, (re)load SA
last_pid=""
while :; do
  CONSOLE_USER=$(stat -f%Su /dev/console 2>/dev/null || echo root)
  if [ "$CONSOLE_USER" = "root" ] || [ -z "$CONSOLE_USER" ]; then
    sleep 5
    continue
  fi

  if [ ! -x "$YABAI" ]; then
    log "yabai not found at $YABAI; is it installed via Homebrew?"
    sleep 30
    continue
  fi

  pid=$(pgrep -u "$CONSOLE_USER" -x Dock || true)
  if [ -n "$pid" ] && [ "$pid" != "$last_pid" ]; then
    log "Dock pid=$pid detected; loading SA"
    if load_sa; then
      log "SA loaded for Dock pid=$pid"
      # Only mark this Dock as handled on success, so a transient failure retries.
      last_pid="$pid"
    else
      log "load-sa failed; will retry. If this persists see macOS/readme.md: check SIP (csrutil status), the arm64e boot-arg (nvram boot-args), and whether yabai supports the running macOS version."
      sleep 10
    fi
  fi

  sleep 5
done
