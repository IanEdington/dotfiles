#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# How to use defcon to view setting
# https://askubuntu.com/questions/971067/how-can-i-script-the-settings-made-by-gnome-tweak-tool

# Disable unused or conflicting keyboard shortcuts
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screenreader ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys video-out '' # (conflicts with screen reader)
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys logout ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screencast ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screensaver ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screenshot-clip ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys terminal ''
# attempt to remove the overlay key
gsettings set org.gnome.mutter overlay-key ""

# Set the textbox keyboard shortcuts to Emacs style
# it's also possible to customize if needed https://askubuntu.com/questions/124815/how-do-i-enable-emacs-keybindings-in-apps-such-as-google-chrome
gsettings set org.gnome.desktop.interface gtk-key-theme "Emacs"

# Screen Shots
gsettings set org.gnome.shell.keybindings screenshot "['<Shift><Super>3']"
gsettings set org.gnome.shell.keybindings screenshot-window "@as []"
gsettings set org.gnome.shell.keybindings show-screen-recording-ui "['<Shift><Super>5']"
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>4']"

# Set the keyboard shortcuts for switching workspaces
for i in {1..9} ; do
    gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$i" "['<Control><Super>$i']"

    # remove new application window
    gsettings set org.gnome.shell.keybindings "open-new-window-application-$i" "@as []"
done

gsettings set org.gnome.mutter.wayland.keybindings restore-shortcuts "@as []"

# window tiling
gsettings set org.gnome.mutter.keybindings toggle-tiled-left "['<Control><Alt>Left']"
gsettings set org.gnome.mutter.keybindings toggle-tiled-right "['<Control><Alt>Right']"
# see: https://bugs.launchpad.net/bugs/2073698
gsettings set org.gnome.shell.extensions.tiling-assistant overridden-settings "@as {}"

