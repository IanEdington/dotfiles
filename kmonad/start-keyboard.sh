#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

kill-keyboard

~/.local/bin/kmonad ~/.dotfiles/kmonad/framework-builtin.kbd \
    &> /dev/null || true \
    & disown
# ~/.local/bin/kmonad ~/.dotfiles/kmonad/moonlander.kbd \
#    &> /dev/null || true \
#    & disown
