#### Command line, Primary and Secondary Text Editors
	export EDITOR=/usr/local/bin/vim
	export EDITOR1="atom" # used for projects
	export EDITOR2=$EDITOR # used for one off file edits
	alias EDITOR1=$EDITOR1
	alias EDITOR2=$EDITOR2
	alias edit=$EDITOR1

#### Edit the .profile file
	alias .profile='$EDITOR2 ~/.zshrc'
	alias .bookmarks='$EDITOR2 ~/.local/.bookmarked-folders'

