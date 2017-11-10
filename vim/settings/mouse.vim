" enable mouse mode (scrolling, selection, etc)
set mouse+=a

" tmux knows the extended mouse mode
if &term =~ '^screen'
    set ttymouse=xterm2
endif
