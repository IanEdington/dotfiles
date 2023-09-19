#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

kill-keyboard

kmonad ~/.dotfiles/kmonad/framework-builtin.kbd & disown
kmonad ~/.dotfiles/kmonad/moonlander.kbd & disown
