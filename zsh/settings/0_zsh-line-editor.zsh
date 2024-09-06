# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

bindkey -v

# set -o vi
export EDITOR=vim
export VISUAL=vim
export IDE=idea

# Kill The Lag [http://dougblack.io/words/zsh-vi-mode.html]
# note: This can result in issues with other terminal commands that depended on this delay. If you have issues try raising the delay.
export KEYTIMEOUT=1

# ctrl-d does not exit the terminal session
set -o ignoreeof

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^r' history-incremental-search-backward

# mimic vim functions
alias :q='exit'
alias :e='vim'
