# Modify the Paradox prompt

zstyle ':prezto:module:editor:info:keymap:primary' format '%B%F{blue}$%f%b'

RPROMPT=""

function prompt_paradox_print_elapsed_time() {
  local elapsed_time=$(( SECONDS - _prompt_paradox_start_time ))
  local hours minutes seconds remainder

  print -Pn "\n"
  print -Pn "%B%F{blue}>>> elapsed time%b "
  if (( elapsed_time >= 3600 )); then
    hours=$(( elapsed_time / 3600 ))
    remainder=$(( elapsed_time % 3600 ))
    minutes=$(( remainder / 60 ))
    seconds=$(( remainder % 60 ))
    print -Pn "%B%F{red}${hours}h${minutes}m${seconds}s%b"
  elif (( elapsed_time >= 60 )); then
    minutes=$(( elapsed_time / 60 ))
    seconds=$(( elapsed_time % 60 ))
    print -Pn "%B%F{yellow}${minutes}m${seconds}s%b"
  elif (( elapsed_time > 0 )); then
    print -Pn "%B%F{green}${elapsed_time}s%b"
  else
    print -Pn "%B%F{green}<1s%b"
  fi
  print -P " %F{blue}finished at: %F{green}%D{%H:%M:%S}%F{blue}%f"
}

# Populate dev-tooling info for the prompt, mirroring how prezto's python
# module feeds $python_info. Everything here is derived from cheap file reads
# except the DDEV running check, which asks docker (only when a .ddev project
# is present in the current directory).
#
# node_info[label]: "<package manager> <package name>" when the directory is a
#   Node project, e.g. "pnpm my-app". The manager is inferred from the lockfile
#   (or package.json's packageManager field), defaulting to npm.
# ddev_info[name]/[status]: the DDEV project name and a running/stopped glyph.
function prompt_paradox_dev_info {
  typeset -gA node_info ddev_info
  node_info=() ddev_info=()
  local line pm pkg

  if [[ -f package.json ]]; then
    if [[ -f pnpm-lock.yaml ]]; then pm=pnpm
    elif [[ -f yarn.lock ]]; then pm=yarn
    elif [[ -f bun.lockb || -f bun.lock ]]; then pm=bun
    elif [[ -f package-lock.json ]]; then pm=npm
    fi
    for line in "${(@f)$(<package.json)}"; do
      if [[ -z $pm && $line == *'"packageManager"'* ]]; then
        pm=${${${line#*:}//[[:space:]\",]/}%%@*}
      fi
      if [[ -z $pkg && $line == *'"name"'* ]]; then
        pkg=${${line#*:}//[[:space:]\",]/}
      fi
    done
    node_info[label]="${pm:-npm}${pkg:+ $pkg}"
  fi

  if [[ -f .ddev/config.yaml ]]; then
    ddev_info[name]=${PWD:t}
    for line in "${(@f)$(<.ddev/config.yaml)}"; do
      case $line in
        (name:*) ddev_info[name]=${${line#*:}//[[:space:]\"]/} ;;
      esac
    done
    if (( $+commands[docker] )) && [[ -n \
      "$(docker ps --filter label=com.ddev.site-name=${ddev_info[name]} --format '{{.ID}}' 2>/dev/null)" ]]; then
      ddev_info[status]='%F{green}●%f'
    else
      ddev_info[status]='%F{red}○%f'
    fi
  fi
}
# Populate in precmd (like prezto's git-info/python-info) so the arrays live in
# the interactive shell. build_prompt runs inside $(...) command substitution
# (a subshell) at prompt-render time, so anything it sets would be discarded
# before the outer ${(e)...} evaluates the segments in the parent.
autoload -Uz add-zsh-hook
add-zsh-hook precmd prompt_paradox_dev_info

# Paradox's segments are hardcoded solid colors -- see the locally installed
# .zprezto/modules/prompt/functions/prompt_paradox_setup (NOT prezto's
# current GitHub master, which has since added an escape-eval wrapper this
# install predates -- copy from the installed file, not upstream, if this
# ever needs re-syncing) -- so none of them adapted to the system light/dark
# switch in theme-sync.zsh. In light mode, swap each segment's solid
# background for a different light-family color per segment (not all the
# same white -- prompt_paradox_start_segment only draws a chevron separator
# between segments whose backgrounds differ, so same-colored neighbors
# collapse into one flat, washed-out bar instead of distinct chips).
# $DOTFILES_THEME_MODE is set there.
function prompt_paradox_build_prompt {
  local host_bg=black host_fg=default
  local path_bg=blue path_fg=black
  local git_bg=green git_fg=black
  local python_bg=white python_fg=black
  local node_bg=magenta node_fg=white
  local ddev_bg=cyan ddev_fg=black
  if [[ "$DOTFILES_THEME_MODE" == "light" ]]; then
    host_bg=white
    host_fg=black
    path_bg=cyan
    path_fg=black
    git_bg=yellow
    git_fg=black
    node_fg=black
  fi

  prompt_paradox_start_segment $host_bg $host_fg '%(?::%F{red}✘ )%(!:%F{yellow}⚡ :)%(1j:%F{cyan}⚙ :)%F{blue}%n%F{red}@%F{green}%m%f'
  prompt_paradox_start_segment $path_bg $path_fg '$_prompt_paradox_pwd'

  if [[ -n "$git_info" ]]; then
    prompt_paradox_start_segment $git_bg $git_fg '${(e)git_info[ref]}${(e)git_info[status]}'
  fi

  if [[ -n "$python_info" ]]; then
    prompt_paradox_start_segment $python_bg $python_fg '${(e)python_info[virtualenv]}'
  fi

  if [[ -n "$node_info[label]" ]]; then
    prompt_paradox_start_segment $node_bg $node_fg ' ${(e)node_info[label]} '
  fi

  if [[ -n "$ddev_info[name]" ]]; then
    prompt_paradox_start_segment $ddev_bg $ddev_fg ' ddev ${(e)ddev_info[name]} ${(e)ddev_info[status]} '
  fi

  prompt_paradox_end_segment
}
