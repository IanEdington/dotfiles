" ==== Search ====

set incsearch       " Find the next match as we type the search
set hlsearch        " Highlight searches by default
set ignorecase      " Ignore case when searching...
set smartcase       " ...unless we type a capital


" Search and Replace quick key
nnoremap <leader>sr :%s/
inoremap <leader>sr <esc>:%s/
vnoremap <leader>sr <esc>:%s/
