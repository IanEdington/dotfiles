# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew
alias brewu='brew update; brew upgrade --all; brew cleanup; brew cask cleanup; brew prune; brew doctor'
