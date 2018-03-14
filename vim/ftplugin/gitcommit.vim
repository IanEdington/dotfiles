if exists("s:did_ftplugin")
  finish
endif

let s:did_ftplugin = 1 " Don't load twice in one buffer

setlocal spell
