dotfiles::symlink_files () {
    local symlink_src symlink_dst
    symlink_src=$1
    symlink_dst=$2

    # A missing source is a typo in the caller, not something to paper over:
    # creating it silently produces an empty file in the repo and a link that
    # looks healthy while pointing at nothing.
    if [ ! -e "$symlink_src" ]; then
        echo_red "Error linking $symlink_dst->$symlink_src: source does not exist!"
        return
    fi

    if [ -h "$symlink_dst" ]; then
        rm "$symlink_dst"
    elif [ -e "$symlink_dst" ]; then
        # A real file here is usually the app having rewritten its own config.
        # Keep it rather than clobbering it, but do not block the install.
        local backup_dst="$symlink_dst.backup"
        local n=1
        while [ -e "$backup_dst" ]; do
            backup_dst="$symlink_dst.backup.$n"
            n=$((n + 1))
        done
        mv "$symlink_dst" "$backup_dst"
        echo_yellow "$symlink_dst was a real file; moved it to $backup_dst"
    fi

    mkdir -p "$(dirname "$symlink_dst")"

    ln -s "$symlink_src" "$symlink_dst"
}

log() {
    if [[ ${LOG_LEVEL:-0} > 0 ]] ; then
        echo $@
    fi
}

command_exists() {
  command -v "$1" &> /dev/null
  [[ $? == 0 ]]
}

if_command_failed() {
    set +e
    eval $@ &> /dev/null
    test=$?
    set -e
    [[ $test > 0 ]]
}

echo_red() {
    local Red ColorOff
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
echo_green() {
    local LIGHT_GREEN ColorOff
    LIGHT_GREEN='\033[1;32m'
    ColorOff='\033[0m'
    echo -e "$LIGHT_GREEN$@$ColorOff"
}

is_linux() {
    [[ "$(uname -s)" == "Linux" ]]
}

is_darwin() {
    [[ "$(uname -s)" == "Darwin" ]]
}
