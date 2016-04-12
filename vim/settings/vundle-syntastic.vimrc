"mark syntax errors with :signs
let g:syntastic_enable_signs=1
"automatically jump to the error when saving the file
let g:syntastic_auto_jump=0
"show the error list automatically
let g:syntastic_auto_loc_list=1
"don't care about warnings
"let g:syntastic_quiet_messages = {'level': 'warnings'}

" suggested defaults
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_scss_checkers = ['scss_lint']
"let g:syntastic_php_checkers = ['php', 'phpcs']
"let g:syntastic_scss_scss_lint_args = "-c ~/dev/Instuctio/ecpd/site/web/app/themes/EyeCarePD/.scss-lint.yml"
