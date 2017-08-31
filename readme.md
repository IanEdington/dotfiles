# Ian Edington's dotfiles

## Todos

- [ ] go through settings and clean up how I like my personal macOS settings

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

## Apps to install Manually
Deluge Magnet Handler
Diamond
Pixelmator
Popcorn-Time
Server

## Mac Settings

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

## Browsing Strategy
The idea is to separate and compartmentalize data, so that an exploit or privacy violation in one "session" does not necessarily affect data in another.

Create three profiles
- trusted Web sites (email, banking)
    * One or more profile(s) for secure and trusted browsing needs, such as banking and email only.
- mostly trusted Web sites (link aggregators, news sites)
    * One profile with [uMatrix](https://github.com/gorhill/uMatrix) or [uBlock Origin](https://github.com/gorhill/uBlock) (or both). Use this profile for visiting **mostly trusted** Web sites. Take time to learn how these firewall extensions work. Other frequently recommended extensions are [Privacy Badger](https://www.eff.org/privacybadger), [HTTPSEverywhere](https://www.eff.org/https-everywhere) and [CertPatrol](http://patrol.psyced.org/) (Firefox only).
- untrusted sites - cookie-less and script-less experience
    * One profile **without cookies or Javascript** enabled (e.g., turned off in `chrome://settings/content`) which should be the preferred profile to visiting untrusted Web sites. However, many pages will not load at all without Javascript enabled.

In each profile, visit `chrome://plugins/` and disable **Adobe Flash Player**.
If you must use Flash, visit `chrome://settings/contents` to enable **Let me choose when to run plugin content**, under the Plugins section (also known as *click-to-play*).

Also be aware of WebRTC, which may reveal your local or public (if connected to VPN) IP address(es).
This can be disabled with extensions such as [uBlock Origin](https://github.com/gorhill/uBlock/wiki/Prevent-WebRTC-from-leaking-local-IP-address) and [rentamob/WebRTC-Leak-Prevent](https://github.com/rentamob/WebRTC-Leak-Prevent).
