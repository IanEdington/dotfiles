#!/usr/bin/env bash
# Bash Strict Mode: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

sudo apt install \
    # dotfile requirements
    fasd \
    fzy \
    gpg \
    xdotool \

    # gui apps
    1password \
    albert \
    autokey-gtk \
    code \ #visual studio code
    deluge \
    flameshot \
    freecad freecad-doc \
    gimp \
    gnome-sushi \ # previews in file explorer
    inkscape inkscape-tutorials \
    libheif-examples \ # convert heif photos into jpg
    okular \
    openscad \
    openshot-qt openshot-qt-doc \ # video editor
    screenkey \ # displays the keys you type on screen
    shotwell \
    signal-desktop \
    slack \
    vivaldi-stable \ # preferred browser
    vlc \

    # terminal apps
    1password-cli \
    brightnessctl \
    direnv \
    docker \
    editorconfig \
    evtest \
    gh \
    git \
    git-extras \
    jq \
    kmonad \
    mosh \
    neovim \
    openvpn3 \
    tig \
    tmux \
    zsh \

    # regolith-desktop
    regolith-desktop \
    regolith-session-sway \
    regolith-look-solarized-dark \

# Remove auto installed packages
sudo apt remove \
    # These are configs that have been replaced with user configs
    regolith-wm-navigation regolith-sway-ilia regolith-i3-ilia

# maybe install
pipewire
slurp
sqlite3
wofi

# desktop tools
flatpak install flathub it.mijorus.smile

# suggestions
    Foliate (ebook reader app with lots of options)
    Drawing (a simple ‘Microsoft Paint’ alternative)
    Lollypop (a desktop music player with neat UI)

    Kdenlive (versatile video editor)
    Geary (modern email client)
    Chromium (web browser)
