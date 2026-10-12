#!/usr/bin/env bash
set -euo pipefail

# Link the shared dotfiles pieces that make sense on a headless server. The
# root install is laptop-oriented (desktop apps, keyboards, window managers),
# so run selected per-folder installers instead of all of them.
DOTFILES_ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/../.." && pwd -P )"

# The per-folder installers expect ~/.dotfiles and these helpers.
source "$DOTFILES_ROOT/shells/bash_utils.sh"
dotfiles::symlink_files "$DOTFILES_ROOT" ~/.dotfiles

mkdir -p ~/.local/bin ~/.config/git

for dir in git tmux; do
    (cd ~/.dotfiles/$dir && source ./install)
done

# git/config pages through diff-so-fancy; packages/install would also link
# kmonad, which is desktop-only.
dotfiles::symlink_files ~/.dotfiles/packages/diff-so-fancy/diff-so-fancy ~/.local/bin/diff-so-fancy
