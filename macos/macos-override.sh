# Places to look for settings:
# nvram - boot settings
# pmset - power settings
# scutil - system config params
# systemsetup - Many system settings from prefs
# launchctl - 
# /usr/libexec/PlistBuddy
    # ~/Library/Preferences/com.apple.finder.plist
# defaults read
# defaults -currentHost read
# defaults files:
    # /Library/Preferences/SystemConfiguration/com.apple.smb.server
    # /Library/Preferences/com.apple.loginwindow

# Custom Mac OSX settings

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "ians-laptop"
sudo scutil --set HostName "ians-laptop"
sudo scutil --set LocalHostName "ians-laptop"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "ians-laptop"

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=%80

# reset default highlight colour
defaults delete NSGlobalDomain AppleHighlightColor

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

# Disable automatic termination of inactive apps
defaults delete NSGlobalDomain NSDisableAutomaticTermination

# Disable the crash reporter
defaults write com.apple.CrashReporter DialogType -string "none"

# Load Notification Center and add the menu bar icon
launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: map bottom right corner to right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick 0
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior 0
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable “natural” (Lion-style) scrolling
defaults delete NSGlobalDomain com.apple.swipescrolldirection

# Disable press-and-hold for keys in favor of key repeat
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool true

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en-CA"
defaults write NSGlobalDomain AppleLocale -string "en_CA"

# Set the timezone; see `sudo systemsetup -listtimezones` for other values
sudo systemsetup -settimezone "America/Toronto" > /dev/null

# Stop iTunes from responding to the keyboard media keys
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2> /dev/null

###############################################################################
# Finder                                                                      #
###############################################################################

# Disable disk image verification
defaults delete com.apple.frameworks.diskimages skip-verify
defaults delete com.apple.frameworks.diskimages skip-verify-locked
defaults delete com.apple.frameworks.diskimages skip-verify-remote

# Show item info near icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo false" ~/Library/Preferences/com.apple.finder.plist

# Show item info to the right of the icons on the desktop
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom true" ~/Library/Preferences/com.apple.finder.plist

# Increase grid spacing for icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:gridSpacing 80" ~/Library/Preferences/com.apple.finder.plist

# Increase the size of icons on the desktop and in other icon views
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:iconSize 72" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:iconSize 72" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:iconSize 72" ~/Library/Preferences/com.apple.finder.plist

# Disable the MacBook Air SuperDrive on any Mac
sudo nvram -d boot-args

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Make dock on left
defaults write com.apple.dock orientation "left"

# Don’t group windows by application in Mission Control
# (i.e. use the old Exposé behavior instead)
defaults delete com.apple.dock expose-group-by-app

# Disable the Launchpad gesture (pinch with thumb and three fingers)
defaults write com.apple.dock showLaunchpadGestureEnabled -int 0

# Add iOS & Watch Simulator to Launchpad
sudo rm "/Applications/Simulator.app"
sudo rm "/Applications/Simulator (Watch).app"

# Add a spacer to the left side of the Dock (where the applications are)
defaults write com.apple.dock persistent-apps -array-add '{tile-data={}; tile-type="spacer-tile";}'
# Add a spacer to the right side of the Dock (where the Trash is)
defaults write com.apple.dock persistent-others -array-add '{tile-data={}; tile-type="spacer-tile";}'

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Mission Control
defaults delete com.apple.dock wvous-tl-corner
defaults delete com.apple.dock wvous-tl-modifier
# Top right screen corner → Desktop
defaults delete com.apple.dock wvous-tr-corner
defaults delete com.apple.dock wvous-tr-modifier
# Bottom left screen corner → Start screen saver
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0

###############################################################################
# Address Book, Dashboard, iCal, TextEdit, and Disk Utility                   #
###############################################################################

# Enable Dashboard dev mode (allows keeping widgets on the desktop)
defaults write com.apple.dashboard devmode -bool false

# Textedit: open with a new file by default
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

###############################################################################
# Messages                                                                    #
###############################################################################

# Disable automatic emoji substitution (i.e. use plain text smileys)
defaults delete com.apple.messageshelper.MessageController SOInputLineSettings

###############################################################################
# Google Chrome & Google Chrome Canary                                        #
###############################################################################

# Disable installing user scripts via GitHub Gist or Userscripts.org
defaults delete com.google.Chrome ExtensionInstallSources
defaults delete com.google.Chrome.canary ExtensionInstallSources

# Use Chrome’s print preview dialog
defaults delete com.google.Chrome DisablePrintPreview
defaults delete com.google.Chrome.canary DisablePrintPreview

###############################################################################
# Transmission.app                                                            #
###############################################################################

# Use `~/Downloads/Torrents` to store incomplete downloads
defaults write org.m0k.transmission IncompleteDownloadFolder -string "${HOME}/Downloads/Torrents"
