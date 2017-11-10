set history=1000
set showcmd
set showmode
set visualbell
set autoread
set hidden

"Allow backspace in insert mode
set backspace=indent,eol,start

"Turn Off Swap Files
set noswapfile
set nobackup
set nowb

" if leader is hit twice in insert mode the leader character is inserted
inoremap <leader><leader> <leader>
