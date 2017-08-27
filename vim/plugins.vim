"" Appearance
Plug 'altercation/vim-colors-solarized'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'itchyny/lightline.vim'
Plug 'ap/vim-css-color'
" Plug 'bling/vim-bufferline'
" Plug 'chrisbra/color_highlight'
" Plug 'jby/tmux.vi
" Plug 'morhetz/gruvbox'
" Plug 'xsunsmile/showmarks'
" Plug 'chriskempson/base16-vim'
" Required for Gblame in terminal vim
" Plug 'godlygeek/csapprox'


"" Languages
Plug 'jalvesaq/nvim-r'
Plug 'sheerun/vim-polyglot'
Plug 'skwp/vim-html-escape'
Plug 'cakebaker/scss-syntax.vim'
" Tools
Plug 'scrooloose/syntastic'
Plug 'tpope/vim-markdown'
" Plug 'jtratner/vim-flavored-markdown'
" Plug 'nelstrom/vim-markdown-folding'
" Plug 'suan/vim-instant-markdown'
" Plug 'vim-pandoc/vim-pandoc'
" Plug 'vim-pandoc/vim-pandoc-syntax'


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
" Plug 'gregsexton/gitv'
" Plug 'mattn/gist-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'airblade/vim-gitgutter'


"" AutoComplete
" Plug 'garbas/vim-snipmate'
" Plug 'honza/vim-snippets'
Plug 'Valloric/YouCompleteMe', { 'do': './install.py --all' }
Plug 'mattn/emmet-vim'
" Snippet engine
" Plug 'SirVer/ultisnips'
" Snippet Library
"Plug 'honza/vim-snippets'

"" Writting
Plug 'beloglazov/vim-online-thesaurus'
Plug 'chesleytan/wordcount.vim' "load the first time wordCount#WordCount is called

"" Text Objects
" These bundles introduce new textobjects into vim,
" For example the Ruby one introduces the 'r' text object
" such that 'var' gives you Visual Around Ruby
" Plug 'austintaylor/vim-indentobject'
" Plug 'bootleq/vim-textobj-rubysymbol'
" Plug 'coderifous/textobj-word-column.vim'
" Plug 'kana/vim-textobj-datetime'
" Plug 'kana/vim-textobj-entire'
" Plug 'kana/vim-textobj-function'
" Plug 'kana/vim-textobj-user'
" Plug 'lucapette/vim-textobj-underscore'
" Plug 'nathanaelkane/vim-indent-guides'
" Plug 'nelstrom/vim-textobj-rubyblock'
" Plug 'thinca/vim-textobj-function-javascript'
" Plug 'vim-scripts/argtextobj.vim'


"" Text Editing
Plug 'tpope/vim-surround'
Plug 'Raimondi/delimitMate'
Plug 'editorconfig/editorconfig-vim'
Plug 'vim-scripts/matchit.zip'
Plug 'terryma/vim-multiple-cursors'
Plug 'chrisbra/csv.vim'
" Plug 'vim-scripts/YankRing.vim'
Plug 'Chiel92/vim-autoformat'


"" Search
Plug 'ctrlpvim/ctrlp.vim'
" Plug 'rking/ag.vim'
" Plug 'justinmk/vim-sneak'
" Plug 'vim-scripts/IndexedSearch'
" Plug 'nelstrom/vim-visual-star-search'
" Plug 'skwp/greplace.vim'
" Plug 'Lokaltog/vim-easymotion'


"" Projects
" Plug 'xolox/vim-misc'
" Plug 'xolox/vim-session'
" Plug 'unterzicht/vim-virtualenv'


"" Vim Improvements
if !has('nvim')
    Plug 'tpope/vim-sensible'
endif
Plug 'tpope/vim-unimpaired'
" Plug 'AndrewRadev/splitjoin.vim'
" Plug 'briandoll/change-inside-surroundings.vim'
" Plug 'godlygeek/tabular'
" Plug 'vim-scripts/camelcasemotion'
" Plug 'Keithbsmiley/investigate.vim'
" Plug 'chrisbra/NrrwRgn'
" Plug 'christoomey/vim-tmux-navigator'
" Plug 'MarcWeber/vim-addon-mw-utils'
" Plug 'bogado/file-line'
" Plug 'mattn/webapi-vim'
" Plug 'sjl/gundo.vim'
" Plug 'tomtom/tlib_vim'
" Plug 'tpope/vim-abolish'
" Plug 'tpope/vim-endwise'
" Plug 'tpope/vim-ragtag'
" Plug 'tpope/vim-repeat'
" Plug 'vim-scripts/AnsiEsc.vim'
" Plug 'vim-scripts/AutoTag'
" Plug 'vim-scripts/lastpos.vim'
" Plug 'vim-scripts/sudo.vim'
" Plug 'goldfeld/ctrlr.vim'


"" Ruby
" Plug 'ecomba/vim-ruby-refactoring'
" Plug 'tpope/vim-rails'
" Plug 'tpope/vim-rake'
" Plug 'tpope/vim-rvm'
" Plug 'vim-ruby/vim-ruby'
" Plug 'keith/rspec.vim'
" Plug 'skwp/vim-iterm-rspec'
" Plug 'skwp/vim-spec-finder'
" Plug 'ck3g/vim-change-hash-syntax'
" Plug 'tpope/vim-bundler'

Plug 'jceb/vim-orgmode'
