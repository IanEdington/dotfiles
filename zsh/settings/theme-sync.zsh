# Follow the system light/dark setting.
#
# macOS/theme/ runs `dark-notify` as a LaunchAgent that writes the current
# mode to this state file (via bin/theme-sync) whenever Appearance changes.
# precmd re-reads it before every prompt, so an already-open terminal picks
# up a change without needing a restart.
#
# The colour scheme itself is terminal-wide, not zsh's -- iTerm2's Utilities
# Package (installed alongside shell integration, see iterm2.zsh) provides
# `it2setcolor`, which repaints the current session from a named color
# preset. "Solarized Dark Higher Contrast" is the custom preset in
# iterm2/com.googlecode.iterm2.plist; "Solarized Light" is iTerm2's stock
# preset, matching vim's solarized8_high/solarized8_flat pairing.
typeset -g DOTFILES_THEME_STATE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles/theme-mode"

_dotfiles_sync_theme_mode() {
    [[ -r "$DOTFILES_THEME_STATE_FILE" ]] || return
    local mode="$(<$DOTFILES_THEME_STATE_FILE)"
    [[ "$mode" == "light" || "$mode" == "dark" ]] || return
    [[ "$mode" == "$DOTFILES_THEME_MODE" ]] && return
    export DOTFILES_THEME_MODE="$mode"

    command -v it2setcolor > /dev/null || return
    if [[ "$mode" == "light" ]]; then
        it2setcolor preset 'Solarized Light'
    else
        it2setcolor preset 'Solarized Dark Higher Contrast'
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_sync_theme_mode
