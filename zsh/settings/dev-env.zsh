# Development Environments
fpath=(
        ${ZDOTDIR:-$HOME}/dev-env
        $fpath
    )

autoload -Uz dev-android
autoload -Uz dev-php
autoload -Uz dev-docker
autoload -Uz dev-python
autoload -Uz dev-ruby
autoload -Uz dev-gcp
autoload -Uz dev-vagrant

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
