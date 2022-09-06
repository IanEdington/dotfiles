# Standard Command defaults flags and extra functionality

# ls (and derivatives)
# ls - Always list directory path and perfered ls view
alias ls='pwd; ls -AF --color'
# A: list all except . & ..
# F: '/' = directory, '*' = executable, '@' = link, '=' = socket, '%' = whiteout, '|' = FIFO
# --color: Enable colorized output (G in Mac OSX bash)
# ll - Long List alias 'ls -l' implementation
alias ll='ls -AFGlh'
# l: List in long format
# h: use unit suffixes: Byte, Kilobyte, Megabyte, Gigabyte ...

# lr: Full Recursive Directory Listing (I don't understand this)
alias lr="ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/ /' -e 's/-/|/'"

# less
alias l='less -i -s -u -w'

# cd
#	Always list directory contents
#cd () { /usr/bin/cd "$@"; ls; }
# make it easier to cd
alias ~="cd ~"
alias cd..='cd ../'
alias ..='cd ../'
alias .2='cd ../../'
alias .3='cd ../../../'
alias .4='cd ../../../../'
alias .5='cd ../../../../../'
alias .6='cd ../../../../../../'

# cp
alias cp='cp -Ri'
# scp
alias scp='scp -C'
# rm
alias rm="echo Dont Fn touch this! Use 'tr', or the full path i.e. '/bin/rm'"


# Preferred 'mv' implementation
if [[ $OSTYPE == darwin* ]]; then
    alias mv='gmv -iv'
else
    alias mv='mv -iv'
fi
# verbose and interactive
# Preferred 'mkdir' implementation
alias mkdir='mkdir -pv'
# Preferred 'less' implementation
alias less='less -FSRXc'
# c: Clear terminal display
alias c='clear'
# which: Find executables
alias which='type -a'
# path: Echo all executable Paths
alias path='echo -e ${PATH//:/\\n}'
alias fpath='echo -e ${FPATH//:/\\n}'

# trash: Moves a file to the MacOS trash
if [[ $OSTYPE == darwin* ]]; then
    alias tr='gmv --verbose -f --backup=numbered --target-directory ~/.Trash/'
else
    alias tr='mv --verbose -f --backup=numbered --target-directory ~/.Trash/'
fi


# ql: Opens any file in MacOS Quicklook Preview
ql () { qlmanage -p "$*" >& /dev/null; }

# cleanupDS: Recursively delete .DS_Store files
alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"

# f: Opens in Finder
alias f='open -a Finder ./'

# Zippin
alias gz='tar -zcvf'

# tree
alias tree='tree -Fc -L 2'

# (f)ind by (n)ame
# usage: fn foo
# to find all files containing 'foo' in the name
function fn() {
    find . -name "*$1*"
}

# ff: Find file under the current directory
ff () { find . -name "$@" ; }

# rsync compressed transfer
alias rsync_d="rsync -pzrv"

alias source_zsh="source ${ZDOTDIR:-$HOME}/.zshrc"
