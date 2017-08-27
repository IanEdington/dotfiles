set foldlevel=8

function IansFoldText()
    let start = getline(v:foldstart)
    let end = substitute(getline(v:foldend), '^\s*', '', 'g')
    let foldsize = (v:foldend - v:foldstart - 1)
    return start.' '.foldsize.' lines '.end
endfunction
