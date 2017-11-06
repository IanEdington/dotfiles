setlocal foldmethod=syntax
setlocal foldtext=JavaFoldText()

" JavaComplete2
setlocal omnifunc=javacomplete#Complete

" Fold text for Java
function JavaFoldText()
  let title = getline(v:foldstart)
  let foldsize = (v:foldend - v:foldstart)
  let linecount = '['.foldsize.' line'.(foldsize>1?'s':'').'] }'
  return title.' '.linecount
endfunction

" java /usr/local/Cellar/checkstyle/7.4/libexec/checkstyle-7.4-all.jar
let s:version = "7.6.1"
let g:syntastic_java_checkstyle_classpath = "/usr/local/Cellar/checkstyle/".s:version."/libexec/checkstyle-".s:version."-all.jar"
let g:syntastic_java_checkstyle_conf_file = "~/.dotfiles/java/google_checks.xml"
let g:syntastic_java_checkers = ['javac', 'checkstyle']
