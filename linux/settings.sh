#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# How to use defcon to view setting
# https://askubuntu.com/questions/971067/how-can-i-script-the-settings-made-by-gnome-tweak-tool
# use `dconf watch / | tee linux/dconf-output.txt` to record settings changes
# convert from 
#   before:
#       /org/gnome/shell/extensions/auto-move-windows/application-list
#         ['org.gnome.Terminal.desktop:9']
#   after:
#       gsettings set org.gnome.shell.extensions.auto-move-windows application-list "['org.gnome.Terminal.desktop:9']"
#
# sometimes gsettings throws the error `No such schema` and I've had to use `dconf write`
#
# some useful commands:
#   - dconf watch / | tee linux/dconf-output.txt
#   - dconf dump /
#   - gsettings list-recursively

# Disable unused or conflicting keyboard shortcuts
gsettings set org.gnome.mutter.wayland.keybindings restore-shortcuts "@as []"
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screenreader ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys video-out '' # (conflicts with screen reader)
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys logout ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screencast ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screensaver ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys screenshot-clip ''
gsettings set com.canonical.unity.settings-daemon.plugins.media-keys terminal ''

# attempt to remove the overlay key
gsettings set org.gnome.mutter overlay-key ""

# Textbox keyboard shortcuts
# it's also possible to customize if needed https://askubuntu.com/questions/124815/how-do-i-enable-emacs-keybindings-in-apps-such-as-google-chrome
# TODO: switch back to Emacs after figuring out how to customize it
gsettings set org.gnome.desktop.interface gtk-key-theme "default"

# Screen Shots
gsettings set org.gnome.shell.keybindings screenshot "['<Shift><Super>3']"
gsettings set org.gnome.shell.keybindings screenshot-window "@as []"
gsettings set org.gnome.shell.keybindings show-screen-recording-ui "['<Shift><Super>5']"
gsettings set org.gnome.shell.keybindings show-screenshot-ui "['<Shift><Super>4']"

# access settings and quick settings
gsettings set org.gnome.shell.keybindings toggle-quick-settings "['<Super>comma']"
gsettings set org.gnome.settings-daemon.plugins.media-keys control-center "['<Shift><Super>comma']"

# lock screen
gsettings set org.gnome.settings-daemon.plugins.media-keys screensaver "['<Control><Alt>l']"


##########################
## Switching Workspaces ##
##########################

# remove default <Super>+num to application 
gsettings set org.gnome.shell.extensions.dash-to-dock hot-keys false
function remove_dock_keybindings() {
    gsettings set org.gnome.shell.keybindings "switch-to-application-$1" "@as []"
    gsettings set org.gnome.shell.keybindings "open-new-window-application-$1" "@as []"
}
for i in {1..9} ; do
    remove_dock_keybindings $i
done
# remove default switch workspace left and right
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "@as []"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "@as []"

# add <Super>+num workspace bindings
function set_numbered_workspace_keybindings() {
    gsettings set org.gnome.desktop.wm.keybindings "switch-to-workspace-$1" "['<Super>$2']"
    gsettings set org.gnome.desktop.wm.keybindings "move-to-workspace-$1" "['<Shift><Super>$2']"
}
set_numbered_workspace_keybindings 10 0
for i in {1..9} ; do
    set_numbered_workspace_keybindings $i $i
done

# auto move windows to workspaces
dconf write "/org/gnome/shell/enabled-extensions" "['ding@rastersoft.com', 'ubuntu-dock@ubuntu.com', 'tiling-assistant@ubuntu.com', 'auto-move-windows@gnome-shell-extensions.gcampax.github.com']"
dconf write "/org/gnome/shell/extensions/auto-move-windows/application-list" "['org.gnome.Terminal.desktop:9', 'firefox-devedition.desktop:2', 'jetbrains-datagrip-df9acb29-00fd-4d39-ad03-180876092f7b.desktop:4', 'code.desktop:4', 'jetbrains-pycharm-fbf3f12f-658b-4d89-b1e2-dd79a673ca1c.desktop:4', 'signal-desktop.desktop:10', 'slack_slack.desktop:8', 'vivaldi-stable.desktop:2', 'jetbrains-webstorm-ce9f6128-45a5-434a-be9f-158ed642f714.desktop:4', 'jetbrains-phpstorm-9deaa717-0027-48e5-aaa1-3a4edd1fbd24.desktop:4', 'jetbrains-toolbox.desktop:4']"

##########################################
## Window Management ##
##########################################

gsettings set org.gnome.desktop.wm.keybindings close "['<Super>q']"
gsettings set org.gnome.desktop.wm.keybindings maximize "['<Control><Alt>Up']"
gsettings set org.gnome.desktop.wm.keybindings toggle-fullscreen "['<Control><Alt>f']"

# Tab through windows

# windows in a application group
gsettings set org.gnome.desktop.wm.keybindings switch-group "['<Shift><Super>h']"
gsettings set org.gnome.desktop.wm.keybindings switch-group-backward "['<Shift><Super>l']"
gsettings set org.gnome.desktop.wm.keybindings cycle-group "@as []"
gsettings set org.gnome.desktop.wm.keybindings cycle-group-backward "@as []"
# windows through windows in a workspace
gsettings set org.gnome.shell.app-switcher current-workspace-only true
gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>h']"
gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Super>l']"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows "@as []"
gsettings set org.gnome.desktop.wm.keybindings cycle-windows-backward "@as []"

# Tiling

# tile left and right keybindings
gsettings set org.gnome.shell.extensions.tiling-assistant tile-left-half "['<Control><Alt>Left']"
gsettings set org.gnome.shell.extensions.tiling-assistant tile-right-half "['<Control><Alt>Right']"

# behaviour when repeating a keybinding
gsettings set org.gnome.shell.extensions.tiling-assistant dynamic-keybinding-behavior 0
# tool to pick other window for split
gsettings set org.gnome.shell.extensions.tiling-assistant enable-tiling-popup false
# gap around outside
gsettings set org.gnome.shell.extensions.tiling-assistant single-screen-gap 0

gsettings set org.gnome.shell.extensions.tiling-assistant active-window-hint 1
gsettings set org.gnome.shell.extensions.tiling-assistant default-move-mode 0
gsettings set org.gnome.shell.extensions.tiling-assistant import-layout-examples false

# Remove default keybindings
gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout0 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout1 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant activate-layout2 "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant auto-tile "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant center-window "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant debugging-free-rects "@as []"
gsettings set org.gnome.shell.extensions.tiling-assistant debugging-show-tiled-rects "@as []"
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
