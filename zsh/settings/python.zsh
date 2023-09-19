# conda initialize (CUSTOM)
__conda_setup="$("${CONDA_INSTALL_DIR:-"$HOME/conda"}/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
elif [[ "$no_conda" != true  ]]; then
    echo '`conda` is not in your path. set $no_conda=true to ignore'
fi
unset __conda_setup
# conda initialize

