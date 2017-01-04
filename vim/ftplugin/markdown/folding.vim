" Fold Markdown - folding for markdown that is fast and snappy
" Maintainer: Ian Edington <http://IanEdington.com/>
" Version: 0.1

finish
if exists("g:markdown_foldtext_loaded") || &cp || v:version < 700
endif
let g:markdown_foldtext_loaded = 1

function! s:HashIndent(lnum)
  let hash_header = matchstr(getline(a:lnum), '^#\{1,6}')
  if len(hash_header) > 0
    " hashtag header
    return hash_header
  else
    " == or -- header
    let nextline = getline(a:lnum + 1)
    if nextline =~ '^=\+\s*$'
      return repeat('#', 1)
    elseif nextline =~ '^-\+\s*$'
      return repeat('#', 2)
    endif
  endif
endfunction

function MarkdownFoldText()
  let hash_indent = s:HashIndent(v:foldstart)
  let title = substitute(getline(v:foldstart), '^#\+\s*', '', '')
  let foldsize = (v:foldend - v:foldstart)
  let linecount = '['.foldsize.' line'.(foldsize>1?'s':'').']'
  return hash_indent.' '.title.' '.linecount
endfunction

setlocal foldtext=MarkdownFoldText()
