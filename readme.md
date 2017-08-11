# Ian Edington's dotfiles

## General philosophy
- Know whats running on your machine.
- Security is scary
- Learn from others dotfiles

Basic strategy
1. brew as much as is reasonable.
    1. App Store
    1. Cask
1. Use package managers where possible.
    - yarn
    - pip
1. Document anything that isn't managed.

## dotfiles I liked
https://github.com/mathiasbynens/dotfiles  
https://github.com/anishathalye/dotfiles  
https://github.com/holman/dotfiles  
https://github.com/cowboy/dotfiles  
https://github.com/skwp/dotfiles  
https://github.com/christoomey/dotfiles  

## TODO
- figure out karabiner elements
    - https://github.com/tekezo/Karabiner-Elements/issues/8#issuecomment-309037790
- look over MacOS Overrides, macos.sh, and security docs

## Apps to install Manually
Deluge Magnet Handler
Diamond
Pixelmator
Popcorn-Time
Server

## Security
https://github.com/drduh/macOS-Security-and-Privacy-Guide
https://github.com/SummitRoute/osxlockdown

## Android File Transfer - auto start off
Android File Transfer auto-starts when you plug an android phone into a USB port.
This is frustrating when your deving on Android.
Turn it off using this [ref](https://gist.github.com/zeroseis/ce66d4c6b776577442a6):

    PID=$(ps -fe | grep "[A]ndroid File Transfer Agent" | awk '{print $2}'); if [[ -n $PID ]]; then kill $PID; fi; mv "/Applications/Android File Transfer.app/Contents/Resources/Android File Transfer Agent.app" "/Applications/Android File Transfer.app/Contents/Resources/Android File Transfer Agent DISABLED.app"; mv "${HOME}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent.app" "${HOME}/Library/Application Support/Google/Android File Transfer/Android File Transfer Agent DISABLED.app"; osascript -e 'tell application "System Events" to delete every login item whose name is "Android File Transfer Agent"'
