#!/bin/bash
# Cloud sessions only: the desktop app forbids scheduling PR check-ins, so the rule must not reach local sessions.
[ "$CLAUDE_CODE_REMOTE" = true ] || exit 0

input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
grep -qE '(^|[;&|[:space:]])(gh pr create|git push)([[:space:]]|$)' <<<"$command" || exit 0

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "PR follow-up: schedule at most one check-in for this push, at 50 minutes, then rely on PR activity events. The prompt cache TTL is one hour from the last request start, so a 60-minute wake re-reads the session at full price while a 50-minute wake reads at cache price. This overrides the harness rule."
  }
}'
