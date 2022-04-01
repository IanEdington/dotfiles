# path, the 0 in the filename causes this to load first
path=(
        /usr/local/opt/coreutils/libexec/gnubin
        $HOME/.dotfiles/bin
        /usr/local/opt/python/libexec/bin
        /usr/local/{bin,sbin}
        $HOME/.yarn/bin
        $HOME/.config/yarn/global/node_modules/.bin
        /usr/{bin,sbin}
        /{bin,sbin}
        /opt/X11/bin
        /usr/local/opt/mysql@5.7/bin
        $HOME/opt/miniconda3/bin
        ${ZDOTDIR:-$HOME}/dev-env
    )

fpath=(
        /usr/local/share/zsh-completions
        ${ZDOTDIR:-$HOME}/prezto-themes
        ${ZDOTDIR:-$HOME}/completions
        ${ZDOTDIR:-$HOME}/.zsh.prompts
        $fpath
    )

manpath=(
        $manpath
        /usr/local/share/man
    )
