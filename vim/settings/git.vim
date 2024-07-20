let w:_vsc_conflict_marker_match = matchadd('ErrorMsg', '^[><=|]\{7\}\([^=].\+\)\?$') |

"Open the current file in GitHub
nnoremap <M-k><M-g> :GBrowse<CR>
