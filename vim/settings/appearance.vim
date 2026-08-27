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

" Follow the system light/dark setting
"
" macOS/theme/ runs `dark-notify` as a LaunchAgent that writes the current
" mode to this state file (via bin/theme-sync) whenever Appearance changes.
" Vim only polls it -- on startup and on FocusGained/CursorHold -- so an
" already-open buffer picks up a change without needing a restart.
let s:theme_state_file = expand('~/.cache/dotfiles/theme-mode')

function! s:SyncBackgroundFromSystem() abort
    if !filereadable(s:theme_state_file)
        return
    endif
    let l:mode = trim(get(readfile(s:theme_state_file, '', 1), 0, ''))
    if l:mode ==# 'light'
        set background=light
        silent! colorscheme solarized8_high
    elseif l:mode ==# 'dark'
        set background=dark
        silent! colorscheme solarized8_flat
    endif
endfunction

augroup dotfiles_theme_sync
    autocmd!
    autocmd VimEnter,FocusGained,CursorHold * call s:SyncBackgroundFromSystem()
augroup END

call s:SyncBackgroundFromSystem()
