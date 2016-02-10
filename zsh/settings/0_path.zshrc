# path, the 0 in the filename causes this to load first
path=(
  $HOME/.dotfiles/bin
  $(brew --prefix coreutils)/libexec/gnubin
  /usr/local/bin
  /usr/local/sbin
  /usr/local/mysql/bin
  /usr/local/opt/go/libexec/bin
  $path
  $HOME/.rvm/bin
)

fpath=(/usr/local/share/zsh-completions $fpath)

MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

