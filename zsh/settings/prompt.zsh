# Modify the Paradox prompt

RPROMPT=""

function prompt_paradox_print_elapsed_time() {
  local end_time=$(( SECONDS - _prompt_paradox_start_time ))
  local hours minutes seconds remainder

  if (( end_time >= 3600 )); then
    hours=$(( end_time / 3600 ))
    remainder=$(( end_time % 3600 ))
    minutes=$(( remainder / 60 ))
    seconds=$(( remainder % 60 ))
    print -Pn "%B%F{red}>>> elapsed time ${hours}h${minutes}m${seconds}s%b"
  elif (( end_time >= 60 )); then
    minutes=$(( end_time / 60 ))
    seconds=$(( end_time % 60 ))
    print -Pn "%B%F{yellow}>>> elapsed time ${minutes}m${seconds}s%b"
  elif (( end_time > 10 )); then
    print -Pn "%B%F{green}>>> elapsed time ${end_time}s%b"
  else
    print -Pn "%B%F{green}>>>"
  fi
  print -P " %F{blue}finished at: [%F{green}%D{%H:%M:%S}%F{blue}]%f"
}
