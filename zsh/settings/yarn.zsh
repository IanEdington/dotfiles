YARN_CACHE_FOLDER=~/.cache/yarn
YARN_CONFIG_FOLDER=~/.config/yarn
#
# yarn list all linked packages for project
yllc() {
  find node_modules -type l -maxdepth 3 | grep -v .bin
}

# yarn list all links
yll() {
  linkDir="$YARN_CONFIG_FOLDER/link"
  find $linkDir -maxdepth 2 -type l | xargs realpath -s --relative-to $linkDir
}

