" ================ Completion =======================

set wildmode=list:longest
"enable ctrl-n and ctrl-p to scroll thru matches
    set wildmenu
"stuff to ignore when tab completing
    set wildignore=*.o,*.obj,*~
set wildignore+=*vim/backups*
set wildignore+=*sass-cache*
set wildignore+=*DS_Store*
set wildignore+=vendor/rails/**
set wildignore+=vendor/cache/**
set wildignore+=*.gem
set wildignore+=log/**
set wildignore+=tmp/**
set wildignore+=*.png,*.jpg,*.gif

