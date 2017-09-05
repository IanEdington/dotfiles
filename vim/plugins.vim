"" Appearance
Plug 'altercation/vim-colors-solarized'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-css-color'

"" Languages
Plug 'jalvesaq/nvim-r'
Plug 'sheerun/vim-polyglot'
Plug 'skwp/vim-html-escape'
Plug 'cakebaker/scss-syntax.vim'

" Tools
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-markdown'

"" IDE (debuging, help, project awareness)
Plug 'embear/vim-localvimrc'
Plug 'joonty/vdebug'
Plug 'tpope/vim-commentary'
Plug 'janko-m/vim-test'

" Java IDE
Plug 'hsanson/vim-android'
Plug 'artur-shaik/vim-javacomplete2'

" Help finder
Plug 'rizzatti/dash.vim'

"" git
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter'

"" AutoComplete
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --all' }
Plug 'mattn/emmet-vim'

"" Writting
Plug 'beloglazov/vim-online-thesaurus'
Plug 'chesleytan/wordcount.vim' "load the first time wordCount#WordCount is called

"" Text Editing
Plug 'tpope/vim-surround'
Plug 'tpope/vim-abolish'
Plug 'Raimondi/delimitMate'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-scripts/matchit.zip'
Plug 'terryma/vim-multiple-cursors'
Plug 'chrisbra/csv.vim'
Plug 'Chiel92/vim-autoformat'

"" Search
Plug 'ctrlpvim/ctrlp.vim'

"" Vim Improvements
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
Plug 'tpope/vim-unimpaired'
