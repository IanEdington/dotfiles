# 4.1 Docker
# Docker-Quickstar
alias docker.quickstart="/bin/bash --login ~/.dotfiles/docker/start.sh"

# short commands
alias d="docker"
alias dq="docker.quickstart"
alias dk="docker"
alias dp="docker ps"
alias dm="docker-machine"
alias dl="docker-machine ls"
alias dc="docker-compose"


# Google Cloud Console SDK
# The next line updates PATH for the Google Cloud SDK.
source '/Users/ian/.gcloud/path.zsh.inc'

# The next line enables shell command completion for gcloud.
source '/Users/ian/.gcloud/completion.zsh.inc'


# MongoDB
alias mongodev='mongod --dbpath ~/.env/mongodb/data/'

# 1.1 Python Dev Environment #
# Activate Python virtual environment at .env/ (for project folders)
alias .env='source .env/bin/activate'

# Activate Anaconda environments (3.4 & 2.7)
alias anaconda='anaconda3'
alias anaconda3='source ~/.env/anaconda3/bin/activate conda3.4'
alias anaconda2='source ~/.env/anaconda3/bin/activate conda2.7'

# Preferred 'ipython' implementations
alias ipyterm='ipython qtconsole &'
alias ipynote='ipython notebook'
alias ipyserv='ipython notebook --profile=nbserver'

# Ruby
if [[ -s "$HOME/.rvm/scripts/rvm" ]]; then
   source "$HOME/.rvm/scripts/rvm"
   # Load RVM into a shell session *as a function*
fi


# GO
export GOPATH=~/dev/go
