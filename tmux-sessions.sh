#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'
# Bash Strict Mode

function create-new-session() {
    tmux new-session -d -s $1 -c "$2/$1" || true
}

create-new-session dotfiles ~/code
create-new-session backend ~/code/faire
create-new-session datagrip ~/code/faire
create-new-session backend2 ~/code/faire
create-new-session mjml-react ~/code/faire
create-new-session web-email-server ~/code/faire
create-new-session platform-configs ~/code/faire

if [ -z ${TMUX+x}  ]; then
    echo "attach to session";
    tmux attach -t backend
fi
