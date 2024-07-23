let w:_vsc_conflict_marker_match = matchadd('ErrorMsg', '^[><=|]\{7\}\([^=].\+\)\?$') |

"Open the current file in GitHub
nnoremap <C-k><C-g> :GBrowse<CR>
