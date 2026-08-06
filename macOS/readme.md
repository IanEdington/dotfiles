# Previous Mac setup in case I go back

## yabai + skhd

**Broken? Run this first.**

```bash
./macOS/yabai/doctor.sh
```

It checks every layer and names the culprit. Everything below is what it points at.

### Symptom → cause

| Symptom | Cause | Fix |
| --- | --- | --- |
| Hotkeys dead, skhd running, log empty | Secure Keyboard Entry blocks all event taps | Turn it off (iTerm2 menu). If `loginwindow` holds it, log out and back in |
| Hotkeys dead after `brew upgrade skhd` | Upgrade changed the signature, so macOS revoked Accessibility. The Settings entry still looks enabled | Settings > Privacy & Security > Accessibility: `−` the skhd entry, `+` re-add `/opt/homebrew/bin/skhd`, `skhd --restart-service` |
| Windows ignore space rules at login | Rules only fire for windows created after they are registered | Already handled by `rule --apply` in `yabairc` |
| `Refusing to load formula ... untrusted tap` | Homebrew needs explicit trust; a Brewfile cannot grant it | `brew trust asmvik/formulae` |
| `Formulae found in multiple taps` | yabai moved koekeishiya → asmvik; Homebrew cloned the redirect as a second tap | `brew untap koekeishiya/formulae` (uninstalls nothing) |
| `load-sa failed` in the daemon log | See below | |

Toggling an Accessibility entry off and on does **not** work. The stale entry
points at the old signature; it has to be removed and re-added.

### `load-sa failed`

The log carries yabai's own error. Read it first:

```bash
sudo tail -f /var/log/com.ianedington.yabai.out
sudo yabai --load-sa   # or reproduce by hand
```

Then, in order:

1. **SIP** — `csrutil status` needs Filesystem Protections, Debugging
   Restrictions, and NVRAM Protections all `disabled`. From recoveryOS:
   `csrutil enable --without fs --without debug --without nvram`
2. **arm64e boot-arg** — Apple Silicon needs
   `sudo nvram boot-args=-arm64e_preview_abi` and a reboot. Check: `nvram boot-args`
3. **`payload (0x..) doesn't support this macOS version`** — `brew upgrade yabai`.
   The addition is built per macOS release, and a new major release may have no
   support yet.
4. **Sudoers hash** — `/private/etc/sudoers.d/yabai` pins a SHA256 of the yabai
   binary, so it breaks on every upgrade. `macOS/install` regenerates it.

`--install-sa` does not exist; it was removed in yabai v6. `--load-sa` installs
and injects in one step, as root.

### The daemon

Loads the scripting addition at login and on every Dock restart, as root.

| | |
| --- | --- |
| Script | `macOS/yabai/yabai-load-sa.sh` → `/usr/local/libexec/yabai-load-sa` |
| Plist | `macOS/yabai/com.ianedington.yabai.plist` → `/Library/LaunchDaemons/` |
| Logs | `/var/log/com.ianedington.yabai.{out,err}` |

```bash
sudo launchctl kickstart -k system/com.ianedington.yabai   # reload after edits
```

`macOS/install` installs the script; editing the repo copy alone changes nothing.

### Gotchas

- **Layout is `float`**, so `padding` and `window_gap` in `yabairc` do nothing.
  `yabai -m config layout bsp` turns tiling on.
- **`ctrl-h`/`ctrl-l`** use `macOS/yabai/cycle-window.sh`, which sorts by window
  id. yabai's own `prev`/`next` follow stacking order, which reshuffles on every
  focus change.
- **Accessibility revocation recurs** on every `brew upgrade skhd`. TCC grants
  cannot be scripted.

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

**Incompatible with skhd.** It blocks event taps, so every hotkey silently stops
working. Pick one; see the yabai + skhd section above.

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

