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

# Web Dev
# find . -type f -exec chmod 644 {} \;
# find . -type d -exec chmod 755 {} \;
chmodweb () {
    find $@ -type d -exec chmod 755 {} \;
    find $@ -type f -exec chmod 644 {} \;
}

export HAXE_STD_PATH="/usr/local/lib/haxe/std"
