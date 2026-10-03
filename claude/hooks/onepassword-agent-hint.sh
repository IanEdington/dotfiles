#!/bin/bash
input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
grep -qE '(^|[;&|[:space:]])git[[:space:]]' <<<"$command" || exit 0
# Agent failures land on stderr (PostToolUse) or in .error (PostToolUseFailure); stdout is skipped so
# printing a file that contains these strings doesn't trigger it.
output=$(jq -r '[.tool_response.stderr?, .error?] | map(select(. != null)) | join("\n")' <<<"$input")

if grep -qE '1Password: agent returned an error|signing failed for .* from agent|communication with agent failed' <<<"$output"; then
  jq -n --arg event "$(jq -r '.hook_event_name // "PostToolUse"' <<<"$input")" '{
    hookSpecificOutput: {
      hookEventName: $event,
      additionalContext: "Git failed because the 1Password SSH agent did not answer (1Password is likely locked). Run `open -a 1Password` to bring up the unlock prompt, ask the user to unlock it, then retry the same command. Never disable commit signing or switch identities to work around this."
    }
  }'
fi
