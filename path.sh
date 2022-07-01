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

prepend_path "$HOME/.local/bin"
prepend_path "$HOME/.dotfiles/bin"

append_path "/usr/local/opt/coreutils/libexec/gnubin"
append_path "/usr/local/opt/python/libexec/bin"
append_path "/usr/local/bin"
append_path "/usr/local/sbin"
append_path "$HOME/.yarn/bin"
append_path "$HOME/.config/yarn/global/node_modules/.bin"
append_path "/usr/bin"
append_path "/usr/sbin"
append_path "/bin"
append_path "/sbin"
append_path "/opt/X11/bin"
append_path "/usr/local/opt/mysql@5.7/bin"
append_path "$HOME/opt/miniconda3/bin"
append_path "${ZDOTDIR:-$HOME}/dev-env"

if [[ -s "$HOME/.local/path.sh" ]]; then
    source "$HOME/.local/path.sh"
fi

unset -f append_path
unset -f prepend_path

export PATH

