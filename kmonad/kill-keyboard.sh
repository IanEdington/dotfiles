#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo -v

pids=$(pidof kmonad || echo "")

if [[ ! -z "$pids" ]]
then
    IFS=$'\n\t '
    for pid in "$pids"; do
        sudo kill $pid
    done
fi
