
#### cleanupDS: Recursively delete .DS_Store files
	alias cleanupDS="find . -type f -name '*.DS_Store' -ls -delete"


# 6. Searching #

#### ff: Find file under the current directory
	ff () { find . -name "$@" ; }

