#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

pid=$(pidof kmonad || echo "")

if [[ ! -z "$pid" ]]
then
    kill $pid
fi

kmonad ~/.dotfiles/kmonad/framework-builtin.kbd & disown
