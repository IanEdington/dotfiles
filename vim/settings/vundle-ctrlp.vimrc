" use ag as default search, with fallback
if exists("g:ctrlp_user_command")
  unlet g:ctrlp_user_command
endif
if executable('ag')
  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s --files-with-matches -g "" --ignore "\.git$\|\.hg$\|\.svn$"'
  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
else
  " Fall back to using git ls-files if Ag is not available
  let g:ctrlp_custom_ignore = '\.git$\|\.hg$\|\.svn$'
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . --cached --exclude-standard --others']
  let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
endif

" Default to filename searches - so that appctrl will find application controller
let g:ctrlp_by_filename = 1

" Don't jump to already open window. This is annoying if you are maintaining several Tab workspaces and want to open two windows into the same file.
let g:ctrlp_switch_buffer = 0

" fuzzy find within file in vim
let g:ctrlp_extensions = ['buffertag', 'tag', 'line', 'dir']

" We don't want to use Ctrl-p as the mapping because it interferes with YankRing (paste, then hit ctrl-p)
let g:ctrlp_map = ''
nnoremap <leader>in :CtrlP<CR>

" Additional mapping for buffer search
nnoremap sbl :CtrlPLine<CR>
nnoremap sb :CtrlPBuffer<CR>

" Cmd-Shift-P to clear the cache
nnoremap <leader>ix :ClearCtrlPCache<cr>

" Idea from : http://www.charlietanksley.net/blog/blog/2011/10/18/vim-navigation-with-lustyexplorer-and-lustyjuggler/
" Open CtrlP starting from a particular path, making it much
" more likely to find the correct thing first. mnemonic 'jump to [something]'
noremap <leader>ia :CtrlP app/assets<CR>
noremap <leader>im :CtrlP app/models<CR>
noremap <leader>ic :CtrlP app/controllers<CR>
noremap <leader>iv :CtrlP app/views<CR>
noremap <leader>ih :CtrlP app/helpers<CR>
noremap <leader>il :CtrlP lib<CR>
noremap <leader>is :CtrlP spec<CR>
noremap <leader>if :CtrlP fast_spec<CR>
noremap <leader>id :CtrlP db<CR>
noremap <leader>iC :CtrlP config<CR>
noremap <leader>iV :CtrlP vendor<CR>
noremap <leader>iF :CtrlP factories<CR>

"Cmd-Shift-(M)ethod - jump to a method (tag in current file)
"Ctrl-m is not good - it overrides behavior of Enter
nnoremap <D-M> :CtrlPBufTag<CR>
