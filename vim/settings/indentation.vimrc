" ==== Indentation ====

set expandtab
set smarttab
set tabstop=4
set shiftwidth=4
set softtabstop=4

set autoindent
set smartindent
set cindent

" Make line warping more apealing
set breakindent
set breakindentopt=shift:2

" Tab to indent
vnoremap <Tab> :><CR>gv
vnoremap <S-Tab> :<<CR>gv
nnoremap <Tab> :><CR>
nnoremap <S-Tab> :<<CR>
inoremap <Tab> <esc>:><CR>a
" inoremap <S-Tab> doesn't seem to register as Shift Tab..

