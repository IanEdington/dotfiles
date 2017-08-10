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

