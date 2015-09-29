# Git aliases

I make use of the standard git aliases A LOT!!! More about this [here](https://git-scm.com/book/en/v2/Git-Basics-Git-Aliases). You can use the following commands to get them all at once:

    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'

### git visual
The default for git visual is above but I use soursetree instead of gitk. I have also included a github desktop version. In order for these to work you have to install command line tools for each.

    git config --global alias.visual '!stree .'
    git config --global alias.visual '!github'

# git cam (Commit All with Message)
One other github alias I use is git cam (commit all with message). This is cautioned against by a lot of people but I find that the habit of commiting is greatly increased because of how easy it is. Of course I do fix commits more often but the time it saves earily makes up for the inconveince of fixing commits.

You can use this command to add cam to your alias list.

    git config --global alias.cam '!git add -A && git commit -m'

Which means thes two are the same:

    git cam 'This is a commit message'
    git commit -am 'This is a commit message'


# Python Development

## Virtual Environments
are invaluable. Don't go without.

In the directory you want to keep your env folder, run this command. I usualy keep my environment folder in the related project folder. I call it .env and have a global git ignore and a .profile alias for .env/bin/activate. Keeping it always the same name makes it easy to keep strait.

### python 2 virtual environment:

    # 1. install virtualenv
    sudo pip install virtualenv

    # 2. make the environment
    virtualenv .env

### python 3 virtual environment:

    pyvenv .env
