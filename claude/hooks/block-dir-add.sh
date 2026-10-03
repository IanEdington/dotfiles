#!/bin/bash
# Local sessions can share a checkout, so `git add <dir>`, `git add .`, or `git add -A` can stage a file
# another session just created. Deny those when they would pick up untracked files that weren't named
# explicitly. Cloud sessions (Linux) each get their own checkout and are unaffected.
[ "$(uname)" = Darwin ] || exit 0

input=$(cat)
command=$(jq -r '.tool_input.command // ""' <<<"$input")
segment=$(grep -oE '(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+add([[:space:]][^;&|]*)?' <<<"$command" | head -1)
[ -n "$segment" ] || exit 0

dir=$(jq -r '.cwd // empty' <<<"$input")
# A leading `cd path &&` or `git -C path` changes which repo is staged.
target=$(sed -nE 's/^[[:space:]]*cd[[:space:]]+([^;&|[:space:]]+).*/\1/p' <<<"$command")
[ -n "$target" ] || target=$(sed -nE 's/.*git[[:space:]]+-C[[:space:]]+([^[:space:]]+)[[:space:]]+add.*/\1/p' <<<"$segment")
if [ -n "$target" ]; then
  target=${target/#\~/$HOME}
  case "$target" in /*) dir=$target ;; *) dir=$dir/$target ;; esac
fi
dir=${dir:-.}
git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

read -ra words <<<"${segment#*add}"
pathspecs=()
all=false
after_dashdash=false
for word in "${words[@]}"; do
  if ! $after_dashdash; then
    case "$word" in
      --) after_dashdash=true; continue ;;
      -A|--all|--no-ignore-removal) all=true; continue ;;
      -u|--update) exit 0 ;;
      -*) continue ;;
    esac
  fi
  word=${word#\"}; word=${word%\"}; word=${word#\'}; word=${word%\'}
  pathspecs+=("${word#./}")
done
$all && [ ${#pathspecs[@]} -eq 0 ] && pathspecs=(.)
[ ${#pathspecs[@]} -gt 0 ] || exit 0

untracked=$(git -C "$dir" ls-files --others --exclude-standard -- "${pathspecs[@]}" 2>/dev/null)
swept=$(grep -vxF -f <(printf '%s\n' "${pathspecs[@]}") <<<"$untracked")
[ -n "$swept" ] || exit 0

jq -n --arg files "$swept" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: "This git add would also stage untracked files that were not named:\n\($files)\nAnother session may have created them. Run git status, read any file you did not write, then stage files by name."
  }
}'
