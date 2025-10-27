# Previous Mac setup in case I go back

## Mac Settings
### yabai scripting-addition loader

The yabai scripting addition is loaded automatically at login via a root LaunchDaemon installed by `macOS/install`.

- Script: `macOS/yabai/yabai-load-sa.sh`
- Plist: `macOS/yabai/com.ianedington.yabai.plist`
- Installed to:
  - `/usr/local/libexec/yabai-load-sa` (root:wheel 755)
  - `/Library/LaunchDaemons/com.ianedington.yabai.plist` (root:wheel 644)

Manage the daemon:

```bash
sudo launchctl print system/com.ianedington.yabai
sudo tail -f /var/log/com.ianedington.yabai.out
sudo tail -f /var/log/com.ianedington.yabai.err
```

To force reload after edits:

```bash
sudo launchctl bootout system /Library/LaunchDaemons/com.ianedington.yabai.plist || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.ianedington.yabai.plist
sudo launchctl kickstart -k system/com.ianedington.yabai
```

Places to look for settings:
- nvram - boot settings
- pmset - power settings
- scutil - system config params
- systemsetup - Many system settings from prefs
- launchctl - list, 
- /usr/libexec/PlistBuddy
    - ~/Library/Preferences/com.apple.finder.plist
- defaults read
- defaults -currentHost read
- defaults files:
    - /Library/Preferences/SystemConfiguration/com.apple.smb.server
    - /Library/Preferences/com.apple.loginwindow

## Security
https://github.com/drduh/macOS-Security-and-Privacy-Guide
https://github.com/SummitRoute/osxlockdown

### Firmware
Firmware use `firmwarepasswd` to manage firmware password
1. restart machine while pressing `Command R`
1. Choose **Firmware Password Utility** from the Utilities menu.
1. Select **Turn On Firmware Password**.
1. Restart and hold `Alt` to test that it worked.

### First boot
1. Disconnect networking. Late 2016 MacBooks require online OS activation.
1.  hold `Command` `Option` `P` `R` keys to [clear NVRAM](https://support.apple.com/en-us/HT204063).
1. configuring firewall and privacy before connecting to network

### Check App signatures
Use `codesign -dvv $Path_to_App` to check the signature of an application.

### System Preferences
- turn on root password to change settings
- FileVault
    - only turn on after running for a couple hours, increases pseudo randomness.
    - `sudo fdesetup enable`
    - force hibernation and modify standby and power nap settings. see macos-override.sh
- Turn off spotlight suggestions
- Turn off safari's suggestions

### Enable Secure Keyboard Entry
Enable [Secure Keyboard Entry](https://security.stackexchange.com/questions/47749/how-secure-is-secure-keyboard-entry-in-mac-os-xs-terminal) in Terminal (unless you use [YubiKey](https://mig5.net/content/secure-keyboard-entry-os-x-blocks-interaction-yubikeys) or applications such as [TextExpander](https://smilesoftware.com/textexpander/secureinput)).

### Hosts file
To block a domain, append `0 example.com` or `0.0.0.0 example.com` or `127.0.0.1 example.com` to `/etc/hosts`

hosts lists:
- [someonewhocares.org](http://someonewhocares.org/hosts/zero/hosts)
- [l1k/osxparanoia/blob/master/hosts](https://github.com/l1k/osxparanoia/blob/master/hosts)
- [StevenBlack/hosts](https://github.com/StevenBlack/hosts)
- [gorhill/uMatrix/hosts-files.json](https://github.com/gorhill/uMatrix/blob/master/assets/umatrix/hosts-files.json)

### Public DNS

Two popular alternatives are [Google DNS](https://developers.google.com/speed/public-dns/) and [OpenDNS](https://www.opendns.com/home-internet-security/).

### OpenSSL
TODO

If you're going to use OpenSSL on your Mac, download and install a recent version of OpenSSL with `brew install openssl`. Note, linking brew to be used in favor of `/usr/bin/openssl` may interfere with built-in software. See [issue #39](https://github.com/drduh/OS-X-Security-and-Privacy-Guide/issues/39).

### Curl
TODO

If you prefer to use OpenSSL, install with `brew install curl --with-openssl` and ensure it's the default with `brew link --force curl`

Here are several recommended [options](http://curl.haxx.se/docs/manpage.html) to add to `~/.curlrc` (see `man curl` for more):

```
user-agent = "Mozilla/5.0 (Windows NT 6.1; rv:45.0) Gecko/20100101 Firefox/45.0"
referer = ";auto"
connect-timeout = 10
progress-bar
max-time = 90
verbose
show-error
remote-time
ipv4
```

### Spoof MAC Address Wi-Fi

You may wish to [spoof the MAC address](https://en.wikipedia.org/wiki/MAC_spoofing) of your network card before connecting to new and untrusted wireless networks to mitigate passive fingerprinting:

    $ sudo ifconfig en0 ether $(openssl rand -hex 6 | sed 's%\(..\)%\1:%g; s%.$%%')

Also see [feross/SpoofMAC](https://github.com/feross/SpoofMAC).

### SSH

For outgoing ssh connections, use hardware- or password-protected keys, [set up](http://nerderati.com/2011/03/17/simplify-your-life-with-an-ssh-config-file/) remote hosts and consider [hashing](http://nms.csail.mit.edu/projects/ssh/) them for added privacy.

Here are several recommended [options](https://www.freebsd.org/cgi/man.cgi?query=ssh_config&sektion=5) to add to  `~/.ssh/config`:

    Host *
      PasswordAuthentication no
      ChallengeResponseAuthentication no
      HashKnownHosts yes

**Note** [macOS Sierra permanently remembers SSH key passphrases by default](https://openradar.appspot.com/28394826). Append the option `UseKeyChain no` to turn this feature off.

### duti
Manage default file handlers with [duti](http://duti.org/), which can be installed with `brew install duti`. One reason to manage extensions is to prevent auto-mounting of remote filesystems in Finder (see [Protecting Yourself From Sparklegate](https://www.taoeffect.com/blog/2016/02/apologies-sky-kinda-falling-protecting-yourself-from-sparklegate/)). Here are several recommended handlers to manage:

```
$ duti -s com.apple.Safari afp

$ duti -s com.apple.Safari ftp

$ duti -s com.apple.Safari nfs

$ duti -s com.apple.Safari smb
```

