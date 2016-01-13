" ==== Persistent Undo ====
" Keep undo history across sessions, by storing in file. Only works all the time.
if has('persistent_undo')
  if !isdirectory(expand('~').'/.vim/backups')
    silent !mkdir ~/.vim/backups > /dev/null 2>&1
  endif
  set undodir=~/.vim/backups
  set undofile
  set undolevels=1000
  set undoreload=10000
endif

