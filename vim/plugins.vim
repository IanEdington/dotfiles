"" settings
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
Plug 'embear/vim-localvimrc'
Plug 'editorconfig/editorconfig-vim'
    let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

"" Text Editing
Plug 'tpope/vim-commentary'
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
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'jiangmiao/auto-pairs'
" Plug 'mattn/emmet-vim' "emmet for vim, I wish I used it

"" Appearance
Plug 'lifepillar/vim-solarized8'
Plug 'ap/vim-css-color'

"" IDE (debuging, help, project awareness)
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup=1
Plug 'scrooloose/syntastic' " linting
" Plug 'joonty/vdebug' "debuging tool - not currently used
Plug 'janko-m/vim-test' "testing use `;t`
Plug 'Chiel92/vim-autoformat' "autoformater, use `=`
    nnoremap = :Autoformat<CR>
    let g:autoformat_autoindent = 0
    let g:autoformat_retab = 0
    let g:autoformat_remove_trailing_spaces = 0
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
    set updatetime=250
" set ignore files from .gitignore
Plug 'octref/rootignore'

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
