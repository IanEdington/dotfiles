let g:lightline = {
\   'colorscheme': 'solarized',
\   'active': {
\     'left': [ [ 'mode', 'paste' ],
\               [ 'readonly', 'filename' ],
\             ],
\     'right': [[ 'percent' ]]
\   },
\   'inactive': {
\ 'left': [ [ 'mode', 'paste' ],
\           [ 'readonly', 'filename', 'modified' ] ],
\ 'right': [[ 'percent' ]]
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
