# homebrew
if [[ -f /opt/homebrew/bin/brew ]] ; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if [[ -f /usr/local/Homebrew/bin/brew ]] ; then
    eval "$(/usr/local/Homebrew/bin/brew shellenv)"
fi

# Append "$1" to $PATH when not already in.
# Copied from Arch Linux, see #12803 for details.
append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
            ;;
    esac
}
prepend_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="$1:${PATH:+$PATH}"
            ;;
    esac
}

prepend_path "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
prepend_path "$HOMEBREW_PREFIX/opt/python/libexec/bin"
prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.dotfiles/bin"

if [[ -s "$HOME/.local/env.sh" ]]; then
    source "$HOME/.local/env.sh"
fi

append_path "$HOME/.yarn/bin"
append_path "$HOME/.config/yarn/global/node_modules/.bin"
append_path "/usr/bin"
append_path "/usr/sbin"
append_path "/bin"
append_path "/sbin"
append_path "/opt/X11/bin"
append_path "/usr/local/opt/mysql@5.7/bin"
append_path "${CONDA_INSTALL_DIR:-"$HOME/miniconda"}/bin"
append_path "${ZDOTDIR:-$HOME}/dev-env"

unset -f append_path
unset -f prepend_path

export PATH

if [[ "$(uname -s)" == "Darwin" ]]; then
    TERMINFO_DIRS=${TERMINFO_DIRS:-''}:$HOME/.local/share/terminfo
fi

export TERMINFO_DIRS

# path config folder
export XDG_CONFIG_HOME="$HOME/.config"