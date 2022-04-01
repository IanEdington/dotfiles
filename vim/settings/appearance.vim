" turn on true color if available
if ($TERM == 'tmux-256color-italic')
    set termguicolors
endif

"turn on syntax highlighting
syntax enable

" Make line warping more appealing
set wrap
set linebreak
set breakindent
set breakindentopt=shift:2

" left gutter
set number " con - toggle
set relativenumber "cor - toggle

" Display tabs and trailing spaces visually
set list listchars=tab:\⋙\ ,trail:·

"Start scrolling when we're 8 lines away from margins
set scrolloff=5
set sidescrolloff=3
set sidescroll=1

" Use status bar even with single buffer
set laststatus=2
" status line
set statusline=%f\  " Path to the file
set statusline+=%y " Filetype of the file
set statusline+=%m
set statusline+=%r
set statusline+=%w " preview window flag
set statusline+=%= " Expanding Space
set statusline+=\ b%n " Current buffer
set statusline+=\ %4c/%l/%-4L " Current and Total Lines
set statusline+=\ %P " Percent Through Document

" Toggle ColorScheme
" let s:colorschemetoggle=0
" function! s:fold_column_toggle()
"     if s:colorschemetoggle
"         let s:colorschemetoggle=0
"         set background=light
"         colorscheme solarized8_high
"     else
"         let s:colorschemetoggle=1
"         set background=dark
"         colorscheme solarized8_flat
"     endif
" endfunction

" silent call s:fold_column_toggle()

" nnoremap <Plug>FoldColumnToggle :call <SID>fold_column_toggle()<CR>
" nmap cok <Plug>FoldColumnToggle
