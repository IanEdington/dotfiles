"" settings
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
" Plug 'embear/vim-localvimrc'
"     let g:localvimrc_persistent = 1
"     let g:localvimrc_persistence_file = expand("~/.local/vim/localvimrc_persistent")
Plug 'editorconfig/editorconfig-vim'
    let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"" Text Editing
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
    " make visual line bubling select text after move
    xnoremap [e <Plug>unimpairedMoveSelectionUp gv
    xnoremap ]e <Plug>unimpairedMoveSelectionDown gv
Plug 'raimondi/delimitmate'
    let delimitMate_expand_cr=1
    let delimitMate_expand_space=1

"" Appearance
" Plug 'ap/vim-css-color'

"" IDE (debuging, help, project awareness)
Plug 'ctrlpvim/ctrlp.vim'
" Plug 'mileszs/ack.vim'
    " let g:ackprg = 'ag --vimgrep --smart-case'
    " cnoreabbrev ag Ack
    " cnoreabbrev ack Ack
" Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"     let g:deoplete#enable_at_startup = 1
"     let g:deoplete#disable_auto_complete = 1
" Plug 'scrooloose/syntastic' " linting
"     let g:syntastic_mode_map={'mode': 'passive'}
"     let g:syntastic_enable_signs=1
"     let g:syntastic_auto_jump=1
"     let g:syntastic_auto_loc_list=1
"     let g:syntastic_always_populate_loc_list = 1
"     let g:syntastic_check_on_open = 1
"     let g:syntastic_aggregate_errors = 1
"     " Syntastic toggle Mode
"     noremap cot :SyntasticToggleMode<CR>
" Plug 'janko-m/vim-test' "testing use `;t`
"     nnoremap <silent> <leader>t :TestFile<CR>
Plug 'sbdchd/neoformat'
    let g:neoformat_try_node_exe = 1
Plug 'tpope/vim-fugitive'
    " enables GitHub
    Plug 'tpope/vim-rhubarb'
Plug 'airblade/vim-gitgutter'
    set updatetime=250
    let g:gitgutter_preview_win_floating = 1
" set ignore files from .gitignore
" Plug 'octref/rootignore'

"" Writting
" Plug 'beloglazov/vim-online-thesaurus'
" Plug 'chesleytan/wordcount.vim' "load the first time wordCount#WordCount is called

"" Languages
" Plug 'jalvesaq/nvim-r' "r
" Plug 'chrisbra/csv.vim'
Plug 'sheerun/vim-polyglot'

" the default csv language definition in polyglot is frustratingly inaccurate
" This disables that csv plugin in favour of rainbow csv
let g:polyglot_disabled = ['csv']
Plug 'mechatroner/rainbow_csv'

" Java
" Plug 'hsanson/vim-android'
" Plug 'artur-shaik/vim-javacomplete2'
" JavaSrcipt & TypeScript
"     let g:polyglot_disabled = ['javascript', 'typescript']
" Plug 'pangloss/vim-javascript'
" Plug 'leafgarland/typescript-vim'
