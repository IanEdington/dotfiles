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
    " remove commentary default mappings
"     function! UnmapCommentary()
"         unmap gc
"         nunmap gcc
"         nunmap cgc
"         nunmap gcu
"     endfunction
"     autocmd VimEnter * call UnmapCommentary()
"     " map commentary to <C-\>
"     nmap <C-\> <Plug>CommentaryLine
"     vmap <C-\> <Plug>Commentary
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
    " make visual line bubling select text after move
    xnoremap [e <Plug>unimpairedMoveSelectionUp gv
    xnoremap ]e <Plug>unimpairedMoveSelectionDown gv
Plug 'raimondi/delimitmate'
    let delimitMate_expand_cr=1
    let delimitMate_expand_space=1
" Plug 'mattn/emmet-vim' "emmet for vim, I wish I used it

"" Appearance
" Plug 'lifepillar/vim-solarized8'
    " let g:solarized_term_italics=1
    " let g:solarized_use16 = 1
" Plug 'ap/vim-css-color'

"" IDE (debuging, help, project awareness)
" Plug 'ctrlpvim/ctrlp.vim'
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
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
    set updatetime=250
" set ignore files from .gitignore
" Plug 'octref/rootignore'

"" Writting
" Plug 'beloglazov/vim-online-thesaurus'
" Plug 'chesleytan/wordcount.vim' "load the first time wordCount#WordCount is called

"" Languages
" Plug 'jalvesaq/nvim-r' "r
" Plug 'chrisbra/csv.vim'
Plug 'sheerun/vim-polyglot'
" Java
" Plug 'hsanson/vim-android'
" Plug 'artur-shaik/vim-javacomplete2'
" JavaSrcipt & TypeScript
"     let g:polyglot_disabled = ['javascript', 'typescript']
" Plug 'pangloss/vim-javascript'
" Plug 'leafgarland/typescript-vim'
