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
# TODO: switch back to Emacs after figuring out how to customize it
gsettings set org.gnome.desktop.interface gtk-key-theme "default"

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

# window tiling using tiling assistant

# tile left and right keybindings
gsettings set org.gnome.shell.extensions.tiling-assistant tile-left-half "['<Control><Alt>Left']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-right-half "['<Control><Alt>Right']"

# behaviour when repeating a keybinding
gsettings set org.gnome.shell.extensions.tiling-assistant dynamic-keybinding-behavior 0
# tool to pick other window for split
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup false
# gap around outside
gsettings set org.gnome.shell.extensions.tiling-assistant single-screen-gap 0

gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout0 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout1 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout2 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant active-window-hint 1
gsettings set org.gnome.shell.extensions.tiling-assistant auto-tile "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant center-window "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant debugging-free-rects "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant debugging-show-tiled-rects "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant default-move-mode 0
gsettings set org.gnome.shell.extensions.tiling-assistant import-layout-examples false
gsettings set org.gnome.shell.extensions.tiling-assistant restore-window "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant search-popup-layout "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottom-half "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottomleft-quarter "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-bottomright-quarter "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-edit-mode "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-maximize "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-maximize-horizontally "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-maximize-vertically "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-top-half "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-top-half-ignore-ta "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-topleft-quarter "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-topright-quarter "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant toggle-always-on-top "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant toggle-tiling-popup "@as []"

