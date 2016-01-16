# path, the 0 in the filename causes this to load first
path=(
  $HOME/.dotfiles/bin
  $(brew --prefix coreutils)/libexec/gnubin
  /usr/local/sbin
  /usr/local/bin
  /usr/local/mysql/bin
  $path
  $HOME/.rvm/bin
)

