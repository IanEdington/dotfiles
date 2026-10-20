#!/bin/bash
# Silent unless cloud setup logged a failure. systemMessage shows in the UI but renders as a collapsed notice on web, so additionalContext also makes Claude lead its first reply with the same text.
log="$HOME/.cloud-setup-errors.log"
[ -s "$log" ] || exit 0

jq --raw-input --slurp '
  ("⚠️🚨 CLOUD SETUP FAILED 🚨⚠️\n\n" + . + "\n⚠️ Fix the environment setup before relying on this session. ⚠️") as $banner
  | {
      systemMessage: $banner,
      hookSpecificOutput: {
        hookEventName: "SessionStart",
        additionalContext: ("Begin your first reply with this notice, verbatim, before anything else. Say it once per session.\n\n" + $banner)
      }
    }' "$log"
