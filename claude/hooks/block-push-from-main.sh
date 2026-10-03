#!/bin/bash
# Deny rules in settings.json only see the command text, so they miss a bare `git push` run while on main.
# This blocks any push while the checked-out branch is main or master.
input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
grep -qE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+push([[:space:]]|$)' <<<"$command" || exit 0

dir=$(jq -r '.cwd // empty' <<<"$input")
# A leading `cd path &&` or `git -C path` changes which repo is pushed.
target=$(sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+).*/\1/p' <<<"$command")
[ -n "$target" ] || target=$(sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+)[[:space:]]+push.*/\1/p' <<<"$command")
if [ -n "$target" ]; then
  target=${target/#\~/$HOME}
  case "$target" in /*) dir=$target ;; *) dir=$dir/$target ;; esac
fi

branch=$(git -C "${dir:-.}" symbolic-ref --quiet --short HEAD 2>/dev/null) || exit 0
case "$branch" in
  main|master)
    jq -n --arg branch "$branch" '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "deny",
        permissionDecisionReason: "git push is blocked while \($branch) is checked out. Create a feature branch (git switch -c <name>), push that, and open a PR."
      }
    }'
    ;;
esac
