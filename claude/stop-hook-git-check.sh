#!/bin/bash
# Ian's replacement for the CCR-provisioned stop hook of the same name.
# Keeps the uncommitted/untracked/unpushed reminders; drops the platform's
# commit-identity check — commits are authored as Ian and Unverified is
# accepted (see claude/CLAUDE.md). Installed over the platform copy by
# cloud-setup.sh.

input=$(cat)

stop_hook_active=$(echo "$input" | jq -r '.stop_hook_active')
if [[ "$stop_hook_active" = "true" ]]; then
  exit 0
fi

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

if [[ -z "$(git remote)" ]]; then
  exit 0
fi

if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "There are uncommitted changes in the repository. Please commit and push these changes to the remote branch." >&2
  exit 2
fi

untracked_files=$(git ls-files --others --exclude-standard)
if [[ -n "$untracked_files" ]]; then
  echo "There are untracked files in the repository. Please commit and push these changes to the remote branch." >&2
  exit 2
fi

current_branch=$(git branch --show-current)
if [[ -n "$current_branch" ]]; then
  if git rev-parse "origin/$current_branch" >/dev/null 2>&1; then
    upstream="origin/$current_branch"
  else
    upstream="origin/HEAD"
  fi

  unpushed=$(git rev-list "$upstream..HEAD" --count 2>/dev/null) || unpushed=0
  if [[ "$unpushed" -gt 0 ]]; then
    if [[ "$upstream" == "origin/$current_branch" ]]; then
      echo "There are $unpushed unpushed commit(s) on branch '$current_branch'. Please push these changes to the remote repository." >&2
    else
      echo "Branch '$current_branch' has $unpushed unpushed commit(s) and no remote branch. Please push these changes to the remote repository." >&2
    fi
    exit 2
  fi
fi

exit 0
