# When you need to start fresh on an Ubuntu System

# backup

# restore backedup home folder
rsync -aAXv /media/ian/Home\ Backup/manual_2024-06-26/ian /home/

sudo apt install \
    fasd \
    fzy \
    gpg \
    xdotool \
    autokey-gtk \
    deluge \
    flameshot \
    gimp \
    gnome-sushi \
    inkscape inkscape-tutorials \
    libheif-examples \
    okular \
    openscad \
    openshot-qt openshot-qt-doc \
    screenkey \
    shotwell \
    slack \
    vlc \
    brightnessctl \
    direnv \
    editorconfig \
    evtest \
    gh \
    git \
    curl \
    git-extras \
    unity-tweak-tool unity-lens-applications unity-lens-files  \
    jq \
    mosh \
    neovim \
    tig \
    tmux \
    zeal \ # offline documentation
    zsh

# kmonad
https://github.com/kmonad/kmonad/blob/master/doc/faq.md#q-how-do-i-get-uinput-permissions

```
sudo groupadd uinput
sudo usermod -aG input,uinput username
echo 'KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"' | sudo tee /lib/udev/rules.d/90-kmonad.rules
sudo modprobe uinput
```

# not installed through apt automatically
- albert: https://albertlauncher.github.io/setup/
- jetbrains: https://www.jetbrains.com/toolbox-app/
- code: https://code.visualstudio.com/
- vivaldi-stable: https://vivaldi.com/download/?platform=linux
- 1password & 1password-cli: https://support.1password.com/install-linux/#debian-or-ubuntu
- signal-desktop: https://signal.org/download
- slack: use snap - https://snapcraft.io/slack
- firefox-developer-edition: https://askubuntu.com/a/1510266/392415
- docker
    - install: https://docs.docker.com/engine/install/ubuntu/
        - sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    - post-install: https://docs.docker.com/engine/install/linux-postinstall/
- openvpn3: https://openvpn.net/cloud-docs/owner/connectors/connector-user-guides/openvpn-3-client-for-linux.html
- OpenTofu: https://opentofu.org/docs/intro/install/deb/

freecad freecad-doc: not done

# gnome extensions
1. install gnome extension manager `sudo apt install gnome-shell-extension-manager`
1. run `extension-manager` and install the following:
    * auto-move-windows

# framework suggested

https://github.com/FrameworkComputer/linux-docs/blob/main/LinuxMint21-1-Manual-Setup-13thGen.md

# should I install regolith?
    regolith-desktop \
    regolith-session-sway \
    regolith-look-solarized-dark
## Remove auto installed packages
sudo apt remove \
    # These are configs that have been replaced with user configs
    regolith-wm-navigation regolith-sway-ilia regolith-i3-ilia

# desktop tools
flatpak install flathub it.mijorus.smile

# suggestions
    Foliate (ebook reader app with lots of options)
    Drawing (a simple ‘Microsoft Paint’ alternative)
    Lollypop (a desktop music player with neat UI)

    Kdenlive (versatile video editor)
    Geary (modern email client)
    Chromium (web browser)

# MoonLander keyboard
https://github.com/zsa/wally/wiki/Linux-instal

