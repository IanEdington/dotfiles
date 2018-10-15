# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Zle-Builtins
# http://zsh.sourceforge.net/Doc/Release/Zsh-Line-Editor.html#Standard-Widgets

bindkey -v

# set -o vi
export EDITOR=vim
export VISUAL=vim
export IDE=idea

# TODO change to cmd-< cmd->
# bindkey '^a' beginning-of-line
# bindkey '^e' end-of-line

# Make numpad enter work
# bindkey -s "^[Op" "0"
# bindkey -s "^[Ol" "."
# bindkey -s "^[OM" "^M"

# Kill The Lag [http://dougblack.io/words/zsh-vi-mode.html]
# note: This can result in issues with other terminal commands that depended on this delay. If you have issues try raising the delay.
export KEYTIMEOUT=1

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
# bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward

# function zle-line-init zle-keymap-select {
#     VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
#     RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$(git_custom_status) $EPS1"
#     zle reset-prompt
# }
# zle -N zle-line-init
# zle -N zle-keymap-select

# mimic vim functions
alias :q='exit'
alias :e='vim'
