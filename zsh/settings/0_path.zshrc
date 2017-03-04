# path, the 0 in the filename causes this to load first
path=(
        $HOME/.dotfiles/bin
        /usr/local/opt/coreutils/libexec/gnubin
        /usr/local/{bin,sbin}
        $path
        ~/.config/yarn/global/node_modules/.bin
     )

fpath=(/usr/local/share/zsh-completions $HOME/.zsh/prezto-themes $HOME/.zsh/.zsh.prompts $fpath)
