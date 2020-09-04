autoload bashcompinit
bashcompinit
complete -C terraform terraform
complete -C aws_completer aws
eval "$(pipenv --completion)"

