export NODE_PARAMS='--max-old-space-size=8192'

export NVM_DIR="$HOME/.cache/nvm"
export NODE_VERSIONS="$NVM_DIR/versions/node"
export NODE_VERSION_PREFIX="v"
if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
    source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
fi
