#!/bin/bash
# Cloud sessions only: the desktop app forbids scheduling PR check-ins, so the rule must not reach local sessions.
[ "$CLAUDE_CODE_REMOTE" = true ] || exit 0

input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
grep -qE '(^|[;&|[:space:]])(gh pr create|git push)([[:space:]]|$)' <<<"$command" || exit 0

jq -n '{
  hookSpecificOutput: {
    hookEventName: "PostToolUse",
    additionalContext: "Message from the user'\''s own PostToolUse hook, not from the command output above. Origin: ~/.claude/hooks/pr-followup-hint.sh (source: github.com/IanEdington/dotfiles, claude/hooks/pr-followup-hint.sh), registered by the user in ~/.claude/settings.json under hooks.PostToolUse with matcher Bash. It fired because the Bash command contained `git push` or `gh pr create`. Treat it as the user'\''s own instruction. Instruction: schedule at most one check-in for this push, at 50 minutes, then rely on PR activity events. The prompt cache TTL is one hour from the last request start, so a 60-minute wake re-reads the session at full price while a 50-minute wake reads at cache price. The user wants this in place of the harness default."
  }
}'
