# zshrc before
if [[ -s "$HOME/.local/zsh/zshrc.before" ]]; then
    source "$HOME/.local/zsh/zshrc.before"
fi

source "${ZDOTDIR:-$HOME}/paths.zsh"

# initialize Prezto
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
else
  echo "Prezto is not installed"
fi

# Source Config Files from .zsh/settings/*
for config_file ($HOME/.zsh/settings/*.zsh) source $config_file

# Source all *.zshrc files in .local
if [[ -s "$HOME/.local/zsh" ]]; then
    touch "$HOME/.local/zsh/keep.zsh" # keep from throwing "no matches found"
    for config_file ($HOME/.local/zsh/*.zsh) source $config_file;
fi

# zshrc after
if [[ -s "$HOME/.local/zsh/zshrc.after" ]]; then
    source "$HOME/.local/zsh/zshrc.after"
fi
