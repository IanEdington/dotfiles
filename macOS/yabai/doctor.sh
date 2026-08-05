#!/bin/bash
# Checks every layer the yabai + skhd setup depends on, in the order a failure
# propagates. Each of these has silently broken at least once.
set -uo pipefail

fail=0
ok()   { printf '  \033[32mok\033[0m   %s\n' "$*"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$*"; fail=$((fail + 1)); }
warn() { printf '  \033[33mwarn\033[0m %s\n' "$*"; }

echo "SIP and boot-args"
sip=$(csrutil status 2>/dev/null)
for prot in "Filesystem Protections" "Debugging Restrictions" "NVRAM Protections"; do
  if printf '%s' "$sip" | grep -q "$prot: disabled"; then
    ok "$prot disabled"
  else
    bad "$prot must be disabled (csrutil enable --without fs --without debug --without nvram, from recoveryOS)"
  fi
done

if [ "$(uname -m)" = "arm64" ]; then
  if nvram boot-args 2>/dev/null | grep -q -- -arm64e_preview_abi; then
    ok "boot-args has -arm64e_preview_abi"
  else
    bad "Apple Silicon needs: sudo nvram boot-args=-arm64e_preview_abi (then reboot)"
  fi
fi

echo "yabai"
if command -v yabai >/dev/null; then
  ok "yabai $(yabai --version)"
else
  bad "yabai not on PATH"
fi

if pgrep -x yabai >/dev/null; then
  ok "yabai service running"
else
  bad "yabai not running (yabai --start-service)"
fi

# The scripting addition is what makes space switching work; querying spaces
# fails without it, which is the cheapest end-to-end proof it is loaded.
if yabai -m query --spaces >/dev/null 2>&1; then
  ok "scripting addition responding"
else
  bad "yabai cannot query spaces; SA likely not loaded (see /var/log/com.ianedington.yabai.out)"
fi

if sudo -n launchctl print system/com.ianedington.yabai >/dev/null 2>&1; then
  ok "SA loader daemon bootstrapped"
else
  warn "could not check SA loader daemon (needs sudo); run: sudo launchctl print system/com.ianedington.yabai"
fi

# The installed copy drifts from the repo silently; compare them.
if [ -x /usr/local/libexec/yabai-load-sa ]; then
  if cmp -s ~/.dotfiles/macOS/yabai/yabai-load-sa.sh /usr/local/libexec/yabai-load-sa; then
    ok "installed SA loader matches the repo"
  else
    bad "installed SA loader is stale; re-run macOS/install"
  fi
else
  bad "/usr/local/libexec/yabai-load-sa missing; re-run macOS/install"
fi

# The sudoers entry pins a hash of the yabai binary, so it breaks on upgrade.
# Needs sudo to read; distinguish "cannot check" from "actually stale" so a
# missing sudo timestamp does not masquerade as a real finding.
if ! sudo -n true 2>/dev/null; then
  warn "skipped sudoers and daemon checks (no cached sudo); run: sudo -v && $0"
elif [ -f /private/etc/sudoers.d/yabai ]; then
  want=$(shasum -a 256 "$(command -v yabai)" | cut -d' ' -f1)
  if sudo grep -q "$want" /private/etc/sudoers.d/yabai; then
    ok "sudoers hash matches the yabai binary"
  else
    bad "sudoers hash is stale after a yabai upgrade; re-run macOS/install"
  fi
fi

echo "skhd"
# skhd aborts at startup without Accessibility, so a running process is itself
# proof the grant is intact. Only consult the log to explain why it is not
# running; the log is append-only and keeps stale errors from earlier failures.
if pgrep -x skhd >/dev/null; then
  ok "skhd running (implies Accessibility granted)"
elif [ -f "/tmp/skhd_$USER.err.log" ] && grep -q "accessibility access" "/tmp/skhd_$USER.err.log"; then
  bad "skhd aborted: no Accessibility. System Settings > Privacy & Security > Accessibility: remove the skhd entry, re-add $(command -v skhd), then skhd --restart-service"
else
  bad "skhd not running (skhd --start-service); see /tmp/skhd_$USER.err.log"
fi

if skhd --parse "$HOME/.config/skhd/skhdrc" >/dev/null 2>&1; then
  ok "skhdrc parses"
else
  warn "skhd --parse reported problems (or this skhd predates --parse)"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "all checks passed"
else
  echo "$fail check(s) failed"
fi
exit "$fail"
