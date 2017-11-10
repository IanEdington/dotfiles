" Find the next match as we type the search
set incsearch
set hlsearch!
" Ignore case when searching, unless we type a capital
set ignorecase
set smartcase

" Search and Replace quick key
nnoremap <leader>sr :%s/
inoremap <leader>sr <esc>:%s/
vnoremap <leader>sr <esc>:%s/
