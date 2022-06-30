source $HOME/.dotfiles/path.sh

fpath=(
        /usr/local/share/zsh-completions
        ${ZDOTDIR:-$HOME}/prezto-themes
        ${ZDOTDIR:-$HOME}/completions
        ${ZDOTDIR:-$HOME}/.zsh.prompts
        $fpath
    )

manpath=(
        /usr/local/share/man
        $manpath
    )
