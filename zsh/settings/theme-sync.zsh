# Follow the system light/dark setting.
#
# macOS/theme/ runs `dark-notify` as a LaunchAgent that writes the current
# mode to this state file (via bin/theme-sync) whenever Appearance changes.
# precmd re-reads it before every prompt, so an already-open terminal picks
# up a change without needing a restart -- except while vim is in the
# foreground, since precmd doesn't run until you're back at a prompt; vim
# calls bin/theme-apply-terminal-colors itself to cover that gap.
#
# The colour scheme itself is terminal-wide, not zsh's: that script repaints
# the current session via iTerm2's `it2setcolor` utility.
typeset -g DOTFILES_THEME_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/theme-mode"

_dotfiles_sync_theme_mode() {
    [[ -r "$DOTFILES_THEME_STATE_FILE" ]] || return
    local mode="$(<$DOTFILES_THEME_STATE_FILE)"
    [[ "$mode" == "light" || "$mode" == "dark" ]] || return
    [[ "$mode" == "$DOTFILES_THEME_MODE" ]] && return
    export DOTFILES_THEME_MODE="$mode"

    ~/.dotfiles/bin/theme-apply-terminal-colors "$mode"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_sync_theme_mode
