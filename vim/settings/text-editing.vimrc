" Cut, Copy, Paste

nnoremap <leader>x "+Ydd
vnoremap <leader>x "+ygvd
inoremap <leader>x <esc>"+Yddi

nnoremap <leader>c "+Y
vnoremap <leader>c "+y
inoremap <leader>c <esc>"+Ya

nnoremap <leader>v "+p
nnoremap <leader>V "+P
vnoremap <leader>v d"+p
vnoremap <leader>V d"+P
inoremap <leader>v <esc>"+pa
inoremap <leader>V <esc>"+Pa

" Tab to indent
vnoremap <Tab> :><CR>

