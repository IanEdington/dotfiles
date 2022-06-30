dotfiles::symlink_files () {
    local symlink_src symlink_dst
    symlink_src=$1
    symlink_dst=$2

    # TODO check if link already exists

    echo "linking:" "$symlink_dst" "->" "$symlink_src"

    mkdir -p "$(dirname "$symlink_src")"
    touch $symlink_src

    if [ -h "$symlink_dst" ]; then
        rm "$symlink_dst"
    elif [ -e "$symlink_dst" ]; then
        echo "$symlink_dst" " exists and is not a symlink! aboart aboart!"
        echo "we aren't ready to handle this"
        return
        # TODO use the backup_func
    elif [[ ! -e "$(dirname "$symlink_dst")" ]]; then
        mkdir -p "$(dirname "$symlink_dst")"
    fi

    ln -s "$symlink_src" "$symlink_dst"
}

log() {
    if [[ LOG_LEVEL > 0 ]] ; then
        echo $@
    fi
}

command_exists() {
  command -v "$1" &> /dev/null
  [[ $? == 0 ]]
}

echo_red() {
    local Yellow ColorOff
    Red='\033[0;31m'
    ColorOff='\033[0m'
    echo -e "$Red$@$ColorOff"
}
echo_yellow() {
    local Yellow ColorOff
    Yellow='\033[0;33m'
    ColorOff='\033[0m'
    echo -e "$Yellow$@$ColorOff"
}

is_darwin() {
    [[ "$(uname -s)" == "Darwin" ]]
}
