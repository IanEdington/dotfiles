set history=1000
set showcmd
set showmode
set visualbell
set autoread
set hidden

"Allow backspace in insert mode
set backspace=indent,eol,start

set autowrite
" Move backups to temp directory
set backup
set backupdir=~/.cache/vim/backup//
set directory=~/.cache/vim/swap//
set undodir=~/.cache/vim/undo//

" if leader is hit twice in insert mode the leader character is inserted
inoremap <leader><leader> <leader>
