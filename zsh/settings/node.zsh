# nvm - cross-platform configuration
export NVM_DIR="$HOME/.nvm"
# Create nvm directory if it doesn't exist
[ ! -d "$NVM_DIR" ] && mkdir -p "$NVM_DIR"

# pnpm
echo $PNPM_HOME
export PNPM_HOME="$HOME/.local/share/pnpm"
[ ! -d "$PNPM_HOME" ] && mkdir -p "$PNPM_HOME"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;
  *) export PATH="$PNPM_HOME:$PATH" ;
esac

# Load nvm (prioritize Homebrew on macOS, fallback to standard installation)
if [[ -s "$HOMEBREW_PREFIX/opt/nvm/nvm.sh" ]]; then
    # Load from Homebrew (macOS)
    source "$HOMEBREW_PREFIX/opt/nvm/nvm.sh"
    [ -s "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] && source "$HOMEBREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
elif [[ -s "$NVM_DIR/nvm.sh" ]]; then
    # Load from standard installation (Linux or macOS with official installer)
    source "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi
