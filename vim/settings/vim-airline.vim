" Fixes bug where airline dosen't show up with single window open
" https://github.com/bling/vim-airline/issues/20
set laststatus=2

" nice gliphs for airline
let g:airline_powerline_fonts = 1

" Remove pause when leaving insert mode
set timeoutlen=50

" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1

