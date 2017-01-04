" fenced code highlighting
let g:markdown_folding = 1
let g:markdown_fenced_languages = ['html', 'java', 'python', 'bash=sh']

" create a \( surround using the local surround key
autocmd FileType markdown let b:surround_45 = "\\\\(\r\\\\)"
