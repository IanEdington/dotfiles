# (f)ind by (n)ame
# usage: fn foo 
# to find all files containing 'foo' in the name
function fn() { ll **/*$1* }

# ff: Find file under the current directory
ff () { find . -name "$@" ; }

