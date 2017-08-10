let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [ [ 'mode', 'paste' ],
\               [ 'gitbranch', 'readonly', 'filename', 'modified', 'wordcount' ],
\             ]
\   },
\   'component_function': {
\     'gitbranch': 'fugitive#head',
\     'fugitive': 'MyFugitive',
\     'readonly': 'MyReadonly',
\     'filename': 'MyFilename',
\     'wordcount': 'wordCount#WordCount',
\     'syntastic': 'SyntasticStatuslineFlag',
\   },
\ }
