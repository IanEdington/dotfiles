autoload promptinit
promptinit
prompt agnoster
export DEFAULT_USER=ian

# agnoster by default uses the untire path "~/path/to/directory"
# This instead uses a condensed path "~/p/t/directory"
prompt_dir() {
  prompt_segment blue $PRIMARY_FG " $(prompt-pwd) "
}
