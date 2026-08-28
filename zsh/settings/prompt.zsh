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
  if [[ "$DOTFILES_THEME_MODE" == "light" ]]; then
    host_bg=white
    host_fg=black
    path_bg=cyan
    path_fg=black
    git_bg=yellow
    git_fg=black
  fi

  prompt_paradox_start_segment $host_bg $host_fg '%(?::%F{red}✘ )%(!:%F{yellow}⚡ :)%(1j:%F{cyan}⚙ :)%F{blue}%n%F{red}@%F{green}%m%f'
  prompt_paradox_start_segment $path_bg $path_fg '$_prompt_paradox_pwd'

  if [[ -n "$git_info" ]]; then
    prompt_paradox_start_segment $git_bg $git_fg '${(e)git_info[ref]}${(e)git_info[status]}'
  fi

  if [[ -n "$python_info" ]]; then
    prompt_paradox_start_segment $python_bg $python_fg '${(e)python_info[virtualenv]}'
  fi

  prompt_paradox_end_segment
}
