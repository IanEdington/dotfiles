# claude-box

Provisioning for a headless Ubuntu 24.04 server that runs Claude Code as a
long-lived [Remote Control](https://code.claude.com/docs/en/remote-control)
server. Everything the box needs should be in this folder, so a replacement
server can be built from scratch by rerunning it.

## Access model

- No public web services, domain, or TLS. Remote Control makes outbound HTTPS
  requests only and never opens an inbound port.
- Inbound: SSH (key only) and mosh (UDP 60000-61000). Nothing else.
- No production credentials on the box, ever. Staging SSH access only, scoped
  per project (see the security notes once that step lands).
- This repo is public: no hostnames, IPs, keys, or tokens in it.

## New box

1. Create an Ubuntu 24.04 server with `cloud-init.yaml` as its user data.
   First boot creates `ian` (SSH keys from github.com/IanEdington.keys, sudo)
   and `claude` (no sudo, no SSH login), clones the dotfiles for both, and
   runs the playbook. The box starts locked down: sandbox on, no setup phase.
   Progress: `sudo tail -f /var/log/cloud-init-output.log`.
2. `mosh ian@<box>`, then as `claude` (`sudo -iu claude`):
   - `claude` once, then `/login`
   - `~/code/dotfiles/claude-box/bin/add-github-token <owner>` per owner
   - `~/code/dotfiles/claude-box/bin/new-staging-key ...` per project
3. As `ian`: `BOX_USER=claude bash ~/code/dotfiles/claude-box/bootstrap`
   again, so the Remote Control service starts with the login in place.

### Laptop

1. Boot the Ubuntu Desktop 26.04 USB, connect to the network, and choose
   "Automated installation" with this URL:
   `https://raw.githubusercontent.com/IanEdington/dotfiles/main/claude-box/autoinstall.yaml`
2. The installer asks only for identity and storage. Create `ian` with a
   password (the name must be `ian`). Erase the disk with LVM and encryption
   (passphrase); after any reboot or power cut the box stays offline until
   someone types the passphrase at the laptop.
3. Prefer Ethernet. On Wi-Fi, keep "All users may connect to this network"
   on, so it connects before anyone logs in.
4. On first boot `claude-box-firstboot.service` runs `bootstrap` as root,
   retrying every 2 minutes until it succeeds, then disables itself.
   Progress: `journalctl --follow --unit claude-box-firstboot`. It creates
   `claude`, takes over `ian`'s SSH keys (from GitHub, replacing any others),
   and gives `ian` passwordless sudo. `ian`'s login password is unchanged.
5. Reboot, so the lid setting applies. Don't log in; from another machine
   check `ssh ian@<laptop>.local` works, which proves the network comes up
   on its own.
6. Steps 2 and 3 of the server list above.

Without autoinstall, after a normal install with the same choices, as `ian`:

```bash
sudo apt install --yes git
git clone https://github.com/IanEdington/dotfiles ~/code/dotfiles
sudo install --directory /etc/claude-box
echo 'box_admin_user: ian' | sudo tee /etc/claude-box/vars.yml
BOX_USER=claude bash ~/code/dotfiles/claude-box/bootstrap --ask-become-pass
```

`bootstrap` installs Ubuntu's `ansible` package if needed, then runs
`playbook.yml` against the local machine. It is not named `install` because
the root `install` runs every `*/install`, and this must never run on a
laptop.

### Testing a rebuild

The playbook is complete when a fresh server built from `cloud-init.yaml`
works without hand fixes and a second `bootstrap` run reports `changed=0`.
Rerun that check after any change that touches several roles.

## How it works

`playbook.yml` declares the state the box should be in; each role is one
concern. Rerunning it changes only what has drifted, so a second run in a row
should report `changed=0`. That is the test that the playbook captures
everything.

```bash
bootstrap                    # apply
bootstrap --check --diff     # show what would change, change nothing
bootstrap --tags claude      # one role
```

| Role | What it declares |
| --- | --- |
| `swap` | 4G `/swapfile`, active and in fstab, unless other swap exists (Ubuntu Desktop's `/swap.img`). `vm.swappiness=10` |
| `hardening` | OpenSSH server. Key-only SSH via a `00-` drop-in (sshd keeps the first value it reads, and cloud-init's `50-cloud-init.conf` turns passwords back on), verified with `sshd -T`. Firewall allowing only SSH and mosh. OpenVPN absent: packages, PKI, NAT rules, IP forwarding, port, client `.ovpn` files |
| `gui` | Only on Ubuntu Desktop (`gnome-shell` present). Ignores the lid switch, masks the suspend and hibernate targets so idle settings can't sleep the box, and hides the box user from the login screen |
| `admin_user` | Only when `box_admin_user` is set. The human admin: SSH keys from github.com/IanEdington.keys (exclusive), passwordless sudo (key-only SSH is the authentication), and its own dotfiles clone that the box user can't edit |
| `lockdown` | Only when `box_setup_phase` is off. Refuses to run unless the admin has SSH keys; then removes the box user's sudo (cloud-init's sudoers entry and the `sudo` group) and allows only the admin over SSH |
| `packages` | Command-line, media and document tools from Ubuntu. GitHub's `gh` and Google Chrome from their own apt repositories (deb822 sources), with unattended-upgrades allowed to update both. Chrome is told not to add a duplicate apt source |
| `environment` | `CLAUDE_BOX=true` for every login, cron job and systemd user service (`/etc/environment`) and every Claude Code session (`managed-settings.d/` installed to `/etc/claude-code/`, root-owned; files removed from the repo are removed from the box) |
| `dotfiles` | Links the shared `git` and `tmux` config and `diff-so-fancy`, and includes `git/config` from `~/.local/git/config`. The laptop links the same files through each folder's `install`; keep the lists in step |
| `github` | Links the per-owner GitHub token helper and `gh` wrapper into `~/.local/bin`; creates the token directory |
| `node` | fnm in `~/.local/bin`, latest LTS Node as the default, linked into `~/.local/bin` so non-interactive shells and MCP servers find `node`/`npx`. Interactive bash gets fnm's `--use-on-cd` hook |
| `python` | uv (installed without editing shell files), Python 3.13, and `yt-dlp` as a uv tool |
| `ssh_client` | `~/.ssh/config` includes `~/.ssh/config.d/*` (one file per staging host, written by `bin/new-staging-key`), never forwards the agent, and offers only the configured key |
| `claude` | Links `~/.claude` to `dotfiles/claude` and selects `claude-box.md` as the environment section. Installs Claude Code with the native installer if `~/.local/bin/claude` is missing. Registers the Playwright MCP with headless Chrome, writing snapshots to `~/.cache/playwright-mcp` instead of the current directory. On a box that already had a real `~/.claude`, copies its runtime state (login, sessions) over first and keeps the old directory as `~/.claude.pre-dotfiles-<timestamp>` |
| `sandbox` | bubblewrap and socat, the AppArmor profile Ubuntu 24.04 needs for `bwrap`, and a root-owned policy (`/etc/claude-code/managed-settings.d/20-sandbox.json`): the Bash sandbox on (off during the setup phase), a short allowlist of hosts for sandboxed commands, `~/.ssh`, the GitHub tokens and the browser profile hidden from sandboxed commands and from the Read tool, `ssh`/`scp`/`sftp`/`rsync` always asking first, GitHub-authenticating commands (`gh`, `git push/fetch/pull/clone/ls-remote`) run outside the sandbox, and `--dangerously-skip-permissions` disabled |
| `remote_control` | `claude remote-control --name <hostname>` as a `systemd --user` service in `~/code`, restarting on exit (it quits after ~10 minutes without network) and running from boot via lingering. Marks `~/code` trusted in `~/.claude.json` (`projects[...].hasTrustDialogAccepted`, the documented manual route), since the trust prompt needs a terminal |

Two variables decide whose environment is configured:

- `box_user`: the user Claude runs as. `bootstrap` sets it to whoever runs it,
  or `BOX_USER` if set.
- `dotfiles_root`: the checkout running the playbook; system files come from
  here. Config links always point into `~box_user/code/dotfiles` so edits made
  on the box land in that clone.

Machine-specific settings that must not be public go in
`/etc/claude-box/vars.yml` (root-owned), which the playbook loads when
present.

### Setup phase

While a box is being set up, Claude needs `sudo`, and Claude Code never runs
a command that starts with `sudo` outside the Bash sandbox. So during setup,
`/etc/claude-box/vars.yml` holds:

```yaml
box_setup_phase: true
```

The sandbox policy is installed but `sandbox.enabled` is false; the
permission rules (hidden credentials, asking before `ssh`) apply regardless.
The lockdown removes the flag, which turns the sandbox on.

### Ending the setup phase (lockdown)

For a box that was set up with `box_setup_phase: true` (the first droplet):

1. Add `box_admin_user: ian` to `/etc/claude-box/vars.yml` and run
   `bootstrap`. This creates `ian` with the GitHub keys, sudo, and its own
   dotfiles clone in `~ian/code/dotfiles`.
2. From your own machine, check `mosh ian@<box>` and `sudo -n true` work.
3. As `ian`, remove `box_setup_phase` from `/etc/claude-box/vars.yml` and run
   `BOX_USER=claude bash ~/code/dotfiles/claude-box/bootstrap` from ian's
   clone. The lockdown role removes claude's sudo, allows only `ian` over SSH,
   and the sandbox turns on. It refuses to run until `ian` has SSH keys.

From then on, run the playbook only as `ian`, from ian's clone, after
reviewing what changed: `git -C ~/code/dotfiles pull` then `git log -p`
since the last run. The box user can edit its own clone, so running the
playbook from that clone as root would hand it root.

### Switching to the Remote Control service

A box that already runs `claude remote-control` by hand (in tmux, say) sets
`remote_control_started: false` in `/etc/claude-box/vars.yml`, so the
playbook installs and enables the service without starting a second server.
To switch over, as the admin (this ends any conversation served by the old
server):

```bash
sudo sed -i '/^remote_control_started:/d' /etc/claude-box/vars.yml
sudo pkill -f 'claude remote-control'
BOX_USER=claude bash ~/code/dotfiles/claude-box/bootstrap --tags remote_control
sudo -u claude XDG_RUNTIME_DIR=/run/user/$(id -u claude) \
    systemctl --user status claude-remote-control
```

Then open claude.ai/code and pick the box's environment. Logs: `sudo journalctl _UID=$(id -u claude) --user-unit claude-remote-control`
(as the admin), or `journalctl --user -u claude-remote-control` as `claude`.

### Sandbox notes

- GitHub tokens are hidden from sandboxed commands rather than masked.
  Masking (the proxy swapping a placeholder for the real token) was tested
  and dropped: git sends tokens base64-encoded in Basic auth, so the
  placeholder reached GitHub unchanged, and requests carrying a placeholder
  to `api.github.com` hung. The commands that authenticate to GitHub run
  outside the sandbox instead.
- Claude Code keeps some call shapes sandboxed even when excluded, for
  example anything starting with `sudo`, or `git clone` into an absolute or
  `~` path. Clone with a relative path from `~/code`.
- Inside the sandbox, `git status` can list empty files such as `.bashrc` or
  `.mcp.json`: placeholders the sandbox holds over protected paths while a
  command runs. They disappear afterwards; never `git add` them.
- Permission rules read `/path` as relative to the settings file. Use `~/` or
  `//` for absolute paths.

## GitHub access

Fine-grained personal access tokens, one per owner, because a fine-grained
token belongs to exactly one user or org. Tokens live outside the repo in
`~/.config/github-tokens/<owner>` (lowercase, mode 0600).

- `bin/git-credential-github-owner` hands git the token matching the owner in
  the remote URL (`credential.useHttpPath` makes git pass the path).
- `bin/gh` wraps the real `gh` and exports `GH_TOKEN` for the owner from
  `-R/--repo` or the current repo's `origin`, falling back to
  `~/.config/github-tokens/default` (a link to `github_default_owner`'s token)
  outside a repo or for owners without a token.
- HTTPS remotes only; SSH remotes bypass both.
- Claude uses Ian's own account, not a separate machine account (decided
  2026-10-09). Rulesets on `main` therefore can't exempt Ian without also
  exempting Claude; the push-to-main deny rules and hooks in
  `claude/settings.json` are the guard on the box side.
- Git identity for box commits is in `git/config` here.

Create each token from a prefilled link, then pick "Only select
repositories" and the repos by hand (GitHub can't prefill that part):

```bash
~/code/dotfiles/claude-box/bin/github-token-url IanEdington
~/code/dotfiles/claude-box/bin/github-token-url <org> --org
```

The permission set: write on Contents, Pull requests, Issues (and org
Projects); read on the rest that helps development. Deliberately left out:

- Secret scanning alerts: alerts contain the leaked secret.
- Webhooks: hook URLs often embed credentials.
- Workflows: a workflow pushed to any branch runs with access to Actions
  secrets not locked to a protected environment. Without it, GitHub rejects
  pushes that touch `.github/workflows/`; Claude can still edit those files
  locally for you to push.

Orgs must allow fine-grained tokens, and may hold a new token as pending
until an org owner approves it. Links default to a 366-day expiry, the
maximum (`--days N` to change); put a renewal reminder in your calendar.

Then, in your own terminal on the box (not through Claude, so the token stays
out of transcripts):

```bash
~/code/dotfiles/claude-box/bin/add-github-token <owner>
```

## Staging SSH access

One key per project, created on the box, usable only from the box's IP, for a
deploy user without sudo on the staging server. Run it yourself, not through
Claude (the key goes in `~/.ssh`, which Claude can't read):

```bash
~/code/dotfiles/claude-box/bin/new-staging-key <name> <host> [user] [port]
```

It writes `~/.ssh/staging/<name>` and `~/.ssh/config.d/<name>`, then prints
the `authorized_keys` line to install on the server:
`from="<box IP>",no-agent-forwarding,no-port-forwarding,no-X11-forwarding`.
Claude then reaches it with `ssh <name>`, which always asks you first. A new
box has a new IP and new keys, so rerun this per project after moving.

## Still to do

- Rebuild test on a second server (the first droplet was locked down on
  2026-10-13); the laptop install is the first build from scratch
- SSH and mosh to the laptop from outside the home network
