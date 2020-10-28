# Development Environments
fpath=(
        ${ZDOTDIR:-$HOME}/dev-env
        $fpath
    )

for dev_file ($HOME/.zsh/dev-env/*) autoload -Uz $(basename $dev_file)

# MongoDB
#alias mongodev='mongod --dbpath ~/.env/mongodb/data/'

# GO
# export GOPATH=~/dev/go

export HAXE_STD_PATH="/usr/local/lib/haxe/std"
