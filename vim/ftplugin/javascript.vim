let g:javascript_plugin_jsdoc = 1
let g:javascript_plugin_ngdoc = 1
let g:javascript_plugin_flow = 1

setlocal foldlevel=3
setlocal foldmethod=syntax
setlocal foldtext=IansFoldText()

" syntastic
let g:syntastic_javascript_closurecompiler_script = '/usr/local/bin/closure-compiler'
