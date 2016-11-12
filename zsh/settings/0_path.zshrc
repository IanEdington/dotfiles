# path, the 0 in the filename causes this to load first
path=(
        $HOME/.dotfiles/bin
        /usr/local/opt/coreutils/libexec/gnubin
        /usr/local/bin
        /usr/local/sbin
        $path
     )

fpath=(/usr/local/share/zsh-completions $HOME/.zsh/prezto-themes $HOME/.zsh/.zsh.prompts $fpath)

MANPATH="$(brew --prefix coreutils)/libexec/gnuman:$MANPATH"

cdpath=($HOME/dev $HOME/drive $HOME/dropbox $HOME)
