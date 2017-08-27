" remove commentary default mappings
function! UnmapCommentary()
  unmap gc
  nunmap gcc
  nunmap cgc
  nunmap gcu
endfunction
autocmd VimEnter * call UnmapCommentary()

" map commentary to <C-\>
nmap <C-\> <Plug>CommentaryLine
vmap <C-\> <Plug>Commentary
