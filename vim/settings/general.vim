set history=1000
set showcmd
set showmode
set visualbell
set autoread
set hidden

"Allow backspace in insert mode
set backspace=indent,eol,start

" Move backups to temp directory
set backupdir=/tmp/vim/backup//
set directory=/tmp/vim/swap//
set undodir=/tmp/vim/undo//

" if leader is hit twice in insert mode the leader character is inserted
inoremap <leader><leader> <leader>
