# Follow the system light/dark setting.
#
# macOS/theme/ runs `dark-notify` as a LaunchAgent that writes the current
# mode to this state file (via bin/theme-sync) whenever Appearance changes.
# precmd re-reads it before every prompt, so an already-open shell picks up
# a change without needing a restart.
typeset -g DOTFILES_THEME_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/theme-mode"

_dotfiles_sync_theme_mode() {
    [[ -r "$DOTFILES_THEME_STATE_FILE" ]] || return
    local mode="$(<$DOTFILES_THEME_STATE_FILE)"
    [[ "$mode" == "light" || "$mode" == "dark" ]] || return
    [[ "$mode" == "$DOTFILES_THEME_MODE" ]] && return
    export DOTFILES_THEME_MODE="$mode"

    # zsh-syntax-highlighting's default comment colour (grey, ANSI 8) is
    # unreadable on a light background; swap it for a darker grey there.
    if (( ${+ZSH_HIGHLIGHT_STYLES} )); then
        if [[ "$mode" == "light" ]]; then
            ZSH_HIGHLIGHT_STYLES[comment]='fg=242'
        else
            ZSH_HIGHLIGHT_STYLES[comment]='fg=8'
        fi
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_sync_theme_mode
