# `gh copilot alias` came from the deprecated gh-copilot extension; the built-in
# `gh copilot` does not provide it. Stay quiet rather than eval'ing an error into
# every new shell.
if _gh_copilot_alias=$(gh copilot alias -- zsh 2>/dev/null); then
  eval "$_gh_copilot_alias"
fi
unset _gh_copilot_alias
