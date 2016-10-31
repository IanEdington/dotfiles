# Specify your defaults in this environment variable
export HOMEBREW_CASK_OPTS="--appdir=/Applications"

# Homebrew
alias brewu='brew update; brew upgrade --all; brew cleanup; brew cask cleanup; brew prune; brew doctor'

# Disable Homebrew Analytics
export HOMEBREW_NO_ANALYTICS=1
