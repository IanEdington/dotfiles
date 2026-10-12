#!/usr/bin/env bash
set -euo pipefail

# Point ~/.claude at dotfiles/claude, as on the laptop, so config changes made
# on the box land in the repo. Runtime state stays out of git via
# claude/.gitignore.
DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd -P )"
source "$DOTFILES_ROOT/shells/bash_utils.sh"

# A box provisioned before this step has a real ~/.claude holding the login
# and session history. Carry that state over without overwriting tracked
# files, keep the old directory as a backup, then let claude/install link it.
if [ -d ~/.claude ] && [ ! -L ~/.claude ]; then
    rsync -a --ignore-existing ~/.claude/ "$DOTFILES_ROOT/claude/"
    backup=~/.claude.pre-dotfiles-$(date +%Y%m%d%H%M%S)
    mv ~/.claude "$backup"
    echo "Moved the old ~/.claude to $backup"
fi

(cd ~/.dotfiles/claude && source ./install)
