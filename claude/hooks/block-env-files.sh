#!/bin/bash
# Keeps .env and .envrc values out of local sessions. Cloud sessions (Linux) are unaffected.
# Use ~/.claude/bin/env-keys and ~/.claude/bin/env-value instead.
[ "$(uname)" = Darwin ] || exit 0

input=$(cat)
tool=$(jq -r '.tool_name' <<<"$input")

deny() {
  jq -n --arg reason "$1" '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      permissionDecision: "deny",
      permissionDecisionReason: $reason
    }
  }'
  exit 0
}

hint="List keys with ~/.claude/bin/env-keys; pipe a value into a command with ~/.claude/bin/env-value KEY <command>."

case "$tool" in
  Bash)
    command=$(jq -r '.tool_input.command // ""' <<<"$input")
    # Matches .env and .envrc as path components only: .env.example stays allowed, and so do code
    # identifiers like process.env and import.meta.env.
    if grep -qE '(^|[[:space:]/<>=:"'"'"'])\.env(rc)?([[:space:]"'"'"';&|)<>]|$)' <<<"$command"; then
      deny "Commands that touch .env or .envrc are blocked in local sessions. $hint"
    fi
    ;;
  *)
    paths=$(jq -r '[.tool_input.file_path, .tool_input.notebook_path, .tool_input.path, .tool_input.glob, .tool_input.pattern] | map(select(. != null)) | .[]' <<<"$input")
    if grep -qE '(^|/)\.envrc$|(^|/)\.env$|^\*?\.envrc?$' <<<"$paths"; then
      deny "Reading or writing .env or .envrc is blocked in local sessions. $hint"
    fi
    ;;
esac
