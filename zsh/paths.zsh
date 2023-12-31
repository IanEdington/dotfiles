source $HOME/.dotfiles/shells/env.sh

fpath=(
        $HOMEBREW_PREFIX/share/zsh-completions
        ${ZDOTDIR:-$HOME}/prezto-themes
        ${ZDOTDIR:-$HOME}/completions
        ${ZDOTDIR:-$HOME}/.zsh.prompts
        $fpath
    )

manpath=(
        /usr/share/man
        $HOMEBREW_PREFIX/share/man
        $manpath
    )
