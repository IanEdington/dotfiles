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
