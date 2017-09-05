# path, the 0 in the filename causes this to load first
path=(
        node_modules/.bin
        /usr/local/opt/coreutils/libexec/gnubin
        $HOME/.dotfiles/bin
        /usr/local/{bin,sbin}
        $HOME/.config/yarn/global/node_modules/.bin
        /usr/{bin,sbin}
        /{bin,sbin}
        /opt/X11/bin
    )

fpath=(
        /usr/local/share/zsh-completions
        ${ZDOTDIR:-$HOME}/prezto-themes
        ${ZDOTDIR:-$HOME}/.zsh.prompts
        $fpath
    )

manpath=(
    /usr/local/share/man
    $manpath
)
