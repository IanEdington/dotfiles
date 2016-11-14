set nocompatible              " be iMproved, required

" ==== Vundle Initialization ====

filetype off

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim

call vundle#begin() " required

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

let vimvundles = '~/.vim/vundles'
for fpath in split(globpath(vimvundles, '*.vundle'), '\n')
  exe 'source' fpath
endfor

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
