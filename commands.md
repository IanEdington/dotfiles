# System Settings


### Start with Homebrew
Everything is better and easier with homebrew so start here

##### Better bash
I used to use mac's bash and menu-complete option. In ```.inputrc``` put the following:

```
set completion-ignore-case on
set show-all-if-ambiguous on
TAB: menu-complete
```

I found the tab-complete to be subpar and that it wouldn't work with many imported tab-completes. I moved to homebrews bash and tab-completion. The following was taken from [cs.cmu.edu](https://www.cs.cmu.edu/~15131/f15/topics/terminal-configuration/configuring-bash/). This also installs core linux utilities instead of the default OSX utils, taken from @allquixotic on [superuser.](http://superuser.com/a/476594)

```
brew install bash bash-completion
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
brew install coreutils
```


### Programs used

##### sublime
###### setup comandline
	ln -s "/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl

##### macdown
###### comand line
	ln -s /Applications/MacDown.app/Contents/SharedSupport/bin/macdown macdow

### OSX System Preferences (the hiden ones):

##### Mute Startup Sound:

```bash
sudo nvram SystemAudioVolume=%00
```

##### Unhide /Library and ~/Library

```bash
sudo chflags nohidden /Library/ ~/Library/
```

##### Stop itunes from opening when pressing play/pause
http://www.thebitguru.com/projects/iTunesPatch or: [(1)][1]

```bash
# to disable
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist
# To reenable
launchctl load -w /System/Library/LaunchAgents/com.apple.rcd.plist
# credit
https://superuser.com/questions/31925/what-can-i-do-to-stop-the-play-pause-button-from-opening-itunes/827710
```

##### Enable debug menus
```bash
# AppStore
defaults write com.apple.appstore ShowDebugMenu -bool true
# Disk Utility
defaults write com.apple.DiskUtility DUDebugMenuEnabled 1
defaults write com.apple.DiskUtility advanced-image-options -bool true
```

##### Textedit: open with a new file by default
```bash
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false
```

##### Disable gamed (Game Centre daemon)
```bash
sudo defaults write /System/Library/LaunchAgents/com.apple.gamed Disabled -bool true
```

##### Preferences
/Users/ian/Library/Preferences/com.apple.symbolichotkeys.plist




# .profile .ir.. & 


# Editor of Choice: ATOM.IO


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


# Some other useful guilds:
https://github.com/nicolashery/mac-dev-setup
http://jesseatkinson.org/writing/2013/9/8/setting-up-a-new-mac
https://github.com/thejameskyle/favorite-software

# Web Dev

```bash
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;
```

[1]: http://example.com/  "Optional Title Here"