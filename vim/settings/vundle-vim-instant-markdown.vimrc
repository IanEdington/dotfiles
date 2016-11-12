" Don't autostart the browser
let g:instant_markdown_autostart = 0

autocmd FileType markdown nnoremap <buffer> <localleader>p :InstantMarkdownPreview<CR>
