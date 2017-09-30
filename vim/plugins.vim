"" settings
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
Plug 'embear/vim-localvimrc'
Plug 'editorconfig/editorconfig-vim'

"" Text Editing
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-unimpaired'
Plug 'raimondi/delimitmate'

"" Appearance
" Plug 'itchyny/lightline.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'ap/vim-css-color'

"" IDE (debuging, help, project awareness)
Plug 'scrooloose/syntastic' " linting
" Plug 'joonty/vdebug' "debuging tool - not currently used
Plug 'janko-m/vim-test' "testing use `;t`
Plug 'Chiel92/vim-autoformat' "autoformater, use `=`
"" Search
Plug 'ctrlpvim/ctrlp.vim'
"" AutoComplete
Plug 'Valloric/YouCompleteMe' ", { 'do': './install.py --all' }
" Plug 'mattn/emmet-vim' "emmet for vim, I wish I used it
Plug 'airblade/vim-gitgutter'

"" Writting
" Plug 'beloglazov/vim-online-thesaurus'
" Plug 'chesleytan/wordcount.vim' "load the first time wordCount#WordCount is called

"" Languages
" Plug 'jalvesaq/nvim-r' "r
Plug 'chrisbra/csv.vim'
Plug 'sheerun/vim-polyglot'
" Java
" Plug 'hsanson/vim-android'
" Plug 'artur-shaik/vim-javacomplete2'
