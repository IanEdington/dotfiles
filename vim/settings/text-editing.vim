" make visual line bubbling select text after move
xnoremap [e <Plug>unimpairedMoveSelectionUp gv
xnoremap ]e <Plug>unimpairedMoveSelectionDown gv

" P with auto indent
" nnoremap p ]p

" Cut, Copy, Paste
nnoremap <leader>x "+Ydd
vnoremap <leader>x "+ygvd
inoremap <leader>x <esc>"+Yddi

nnoremap <leader>c "+Y
vnoremap <leader>c "+y
inoremap <leader>c <esc>"+Ya

nnoremap <leader>v "+]p
nnoremap <leader>V "+]P
vnoremap <leader>v d"+]p
vnoremap <leader>V d"+]P
inoremap <leader>v <esc>"+]pa
inoremap <leader>V <esc>"+]Pa

" U uppercase u lowercase WHOLE WORD
nnoremap <leader>U viwU
nnoremap <leader>u viwu
inoremap <leader>U <esc>viwU
inoremap <leader>u <esc>viwu
