source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters

autoload promptinit
promptinit
prompt agnoster
export DEFAULT_USER=ian

#function _prompt_paradox_pwd {
  #local pwd="${PWD/#$HOME/~}"

  #if [[ "$pwd" == (#m)[/~] ]]; then
    #_prompt_paradox_pwd="$MATCH"
    #unset MATCH
  #else
    #_prompt_paradox_pwd="${${${${(@j:/:M)${(@s:/:)pwd}##.#?}:h}%/}//\%/%%}/${${pwd:t}//\%/%%}"
  #fi
#}

function prompt_paradox_build_prompt {
  prompt_paradox_start_segment black default '%(?::%F{red}✘ )%(!:%F{yellow}⚡ :)%(1j:%F{cyan}⚙ :)%F{blue}%n%F{red}@%F{green}%m%f'
  prompt_paradox_start_segment blue black '$_prompt_paradox_pwd'

  if [[ -n "$git_info" ]]; then
    prompt_paradox_start_segment green black '${(e)git_info[ref]}${(e)git_info[status]}'
  fi

  if [[ -n "$python_info" ]]; then
    prompt_paradox_start_segment white black '${(e)python_info[virtualenv]}'
  fi

  prompt_paradox_end_segment
}
