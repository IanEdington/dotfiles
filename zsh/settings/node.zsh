export NODE_PARAMS='--max-old-space-size=8192'

export NVM_DIR="$HOME/.cache/nvm"
export NODE_VERSIONS="$NVM_DIR/versions/node"
export NODE_VERSION_PREFIX="v"
if [[ -s "/usr/local/opt/nvm/nvm.sh" ]]; then
    source "/usr/local/opt/nvm/nvm.sh"
fi