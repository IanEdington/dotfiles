#!/usr/bin/env bash
set -euo pipefail

# Per-owner fine-grained PATs for git and gh. See claude-box/README.md.
BOX_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd -P )"

mkdir -p ~/.local/bin
ln -sfn "$BOX_DIR/bin/git-credential-github-owner" ~/.local/bin/git-credential-github-owner
ln -sfn "$BOX_DIR/bin/gh" ~/.local/bin/gh

install -d -m 700 ~/.config/github-tokens

# ~/.local/git/config is machine-local and included by the shared git/config.
mkdir -p ~/.local/git
touch ~/.local/git/config
git config --file ~/.local/git/config --get-all include.path | grep -qxF "$BOX_DIR/git/config" \
    || git config --file ~/.local/git/config --add include.path "$BOX_DIR/git/config"

if [ -z "$(ls -A ~/.config/github-tokens)" ]; then
    echo "No GitHub tokens yet. Add one per owner:  claude-box/bin/add-github-token <owner>"
fi
