#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
# Bash Strict Mode

function create-new-session() {
    tmux new-session -d -s $1 -c "$2/$1" || true
}

tmux new-session -d -s anything -c ~ || true
create-new-session dotfiles ~/code
create-new-session secure-gpo-ca ~/code/gpo
create-new-session gpo-ca ~/code/gpo
create-new-session gpo ~/code/gpo
create-new-session data ~/code/gpo
create-new-session gppackagist ~/code
create-new-session platform-configs ~/code/gpo

# servers
tmux new-session -d -s gpo-servers -n 'prod1' 'mosh prod1'
tmux new-window -t gpo-servers:2 -n 'prod2' 'mosh prod2'
tmux new-window -t gpo-servers:3 -n 'data1' 'mosh data1'
tmux new-window -t gpo-servers:4 -n 'non-prod' 'mosh non-prod'

if [ -z ${TMUX+x}  ]; then
    echo "attach to session";
    tmux attach -t dotfiles
fi
