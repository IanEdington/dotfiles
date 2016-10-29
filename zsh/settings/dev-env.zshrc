# Development Environments

## Autoenv 
AUTOENV_AUTH_FILE="~/.local/autoenv_authorized"

# Docker
## Docker-Quickstar
alias docker.quickstart="/bin/bash --login ~/.dotfiles/docker/start.sh"

## short commands
alias d="docker"
alias dq="docker.quickstart"
alias dk="docker"
alias dp="docker ps"
alias dm="docker-machine"
alias dl="docker-machine ls"
alias dc="docker-compose"


# Google Cloud Console SDK
## The next line updates PATH for the Google Cloud SDK.
source '/Users/ian/.gcloud/path.zsh.inc'

## The next line enables shell command completion for gcloud.
source '/Users/ian/.gcloud/completion.zsh.inc'


# MongoDB
alias mongodev='mongod --dbpath ~/.env/mongodb/data/'

# Python Dev Environment #
## Activate Python virtual environment at .env/ (for project folders)
alias .env='source .env/bin/activate'

## Activate Anaconda environments (3, 2, and r)
alias anaconda='anaconda3'
alias anaconda3='source ~/.env/anaconda3/bin/activate py3'
alias anaconda2='source ~/.env/anaconda3/bin/activate py2'
alias anacondar='source ~/.env/anaconda3/bin/activate r'

## Preferred 'ipython' implementations
alias jupyterm='jupyter qtconsole &'
alias jupynote='jupyter notebook'

# Ruby
alias rvm-activate='source "$HOME/.rvm/scripts/rvm"'

# GO
# export GOPATH=~/dev/go
