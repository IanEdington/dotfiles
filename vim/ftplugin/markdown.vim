setlocal foldtext=MarkdownFoldText()
setlocal foldlevel=1

" anything past here only run once per vim execution
if exists('s:load_once')
    finish
endif
let s:load_once=1

" fenced code highlighting
let g:markdown_folding = 1
let g:markdown_fenced_languages = ['html', 'java', 'python', 'bash=sh']

function s:HashIndent(lnum)
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
