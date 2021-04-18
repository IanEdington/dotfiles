# Git
I follow this methodology for [git branching](http://nvie.com/posts/a-successful-git-branching-model/)

### Git aliases

I make use of the standard git aliases A LOT!!! More about this [here](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases). You can use the following commands to get them all at once:

	git config --global alias.co checkout
	git config --global alias.br branch
	git config --global alias.ci commit
	git config --global alias.st status
	git config --global alias.unstage 'reset HEAD --'
	git config --global alias.last 'log -1 HEAD'
	git config --global alias.visual '!gitk'

### git visual (or git view)
The default for 'git visual' is above but I like soursetree instead of gitk. Below are versions for github desktop and sourcetree. You need their command line tools for this to work.

	git config --global alias.visual '!stree .'
	git config --global alias.visual '!github'
	git config --global alias.view '!stree .'

### git cam (Commit All with Message)
One other github alias I use is git cam (commit all with message). This is cautioned against by a lot of people but I find that the habit of commiting is greatly increased because of how easy it is. Of course I do fix commits more often but the time it saves earily makes up for the inconveince of fixing commits.

You can use this command to add cam to your alias list.

	git config --global alias.cam '!git add -A && git commit -m'

Which means thes two are the same:

	git cam 'This is a commit message'
	git add -A && git commit -m 'This is a commit message'
