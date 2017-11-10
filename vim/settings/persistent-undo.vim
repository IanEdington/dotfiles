" Keep undo history across sessions, by storing in file.
let s:backupFolder='~/.cache/vim/undo-backups'
if has('persistent_undo')
  set undofile
  let &undodir=expand(s:backupFolder)
  set undolevels=1000
  set undoreload=10000
endif
