# Ian Edington Dotfiles
## dotfiles I really liked
https://github.com/mathiasbynens/dotfiles
https://github.com/anishathalye/dotfiles
https://github.com/holman/dotfiles
https://github.com/cowboy/dotfiles
https://github.com/skwp/dotfiles

## General philosophy
In creating this dotfile repo I was influenced by Zach Holman's "[Dotfiles Are Meant to Be Forked][2]" and Anish Athalye's "[Dotfiles Are Not Meant to Be Forked][3]". I took the linking style from Anish, the structure from Zach and functions from all over. I have extended these two ideas to create what I hope will be an easily modifiable dotfile set. The idea is that each package folder could be swapped in for any other folder and it will use those settings instead of the default. ie. if you don't like skwp's implementation of vim you can replace it with your own vim folder and everything will work as expected.

Dependancies

1. brew as much as is reasonable.
2. Use package managers where possible.
2. Use git submodules for anything that slips through the cracks.
3. Document anything that isn't managed.


[1]: https://github.com/anishathalye/dotbot
[2]: http://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/
[3]: http://www.anishathalye.com/2014/08/03/managing-your-dotfiles/

## TODO
- what to symlink in home directory
- npm global packages
- python global packages
- neovim switch from vundle to another package manager
- figure out karabiner elements
- look over MacOS Overrides, macos.sh, and security docs

## Apps to install Manually

Deluge Magnet Handler
Diamond.app
Pixelmator.app
Popcorn-Time.app
Server.app
## Security
https://github.com/drduh/macOS-Security-and-Privacy-Guide
https://github.com/SummitRoute/osxlockdown

## Android File Transfer - auto start off
Android File Transfer auto-starts when you plug an android phone into a USB port.
This is frustrating when your deving on Android.
Turn it off using this [ref](https://gist.github.com/zeroseis/ce66d4c6b776577442a6):

    PID=$(ps -fe | grep "[A]ndroid File Transfer Agent" | awk '{print $2}'); if [[ -n $PID ]]; then kill $PID; fi; mv "/Applications/Android File Transfer.app/Contents/Resources/Android File Transfer Agent.app" "/Applications/Android File Transfer.app/Contents/Resources/Android File Transfer Agent DISABLED.app"; mv "${HOME}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent.app" "${HOME}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent DISABLED.app"; osascript -e 'tell application "System Events" to delete every login item whose name is "Android File Transfer Agent"'

