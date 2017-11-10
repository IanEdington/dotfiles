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
set list listchars=tab:\⋙\ ,trail:·,eol:¬

"Start scrolling when we're 8 lines away from margins
set scrolloff=5
set sidescrolloff=3
set sidescroll=1

" Use status bar even with single buffer
set laststatus=2

" Toggle ColorScheme
let s:colorschemetoggle=0
function! s:fold_column_toggle()
    if s:colorschemetoggle
        let s:colorschemetoggle=0
        colorscheme solarized8_light_flat
    else
        let s:colorschemetoggle=1
        colorscheme solarized8_dark_flat
    endif
endfunction

silent call s:fold_column_toggle()

nnoremap <Plug>FoldColumnToggle :call <SID>fold_column_toggle()<CR>
nmap cok <Plug>FoldColumnToggle
