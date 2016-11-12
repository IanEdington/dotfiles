# System Settings

## interesting commands to keep in mind
https://github.com/cowboy/dotfiles/blob/master/bin/multi_firefox
https://github.com/gregburek/github-emoji-expansion-in-osx/blob/master/NSUserReplacementItems.plist

## add brew's zsh and bash to the "acceptable shells" file
echo "$(brew --prefix)/bin/bash" | sudo tee -a /etc/shells
echo "$(brew --prefix)/bin/zsh" | sudo tee -a /etc/shells

## link cli for sublime and macdown
ln -s "/Applications/Sublime\ Text\ 2.app/Contents/SharedSupport/bin/subl" ~/bin/subl
ln -s /Applications/MacDown.app/Contents/SharedSupport/bin/macdown macdow

## Stop itunes from opening when pressing play/pause
http://www.thebitguru.com/projects/iTunesPatch or: [(1)][1]

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
