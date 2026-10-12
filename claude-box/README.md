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

## Bootstrap a new box

As a sudo-capable user on a fresh Ubuntu 24.04 server:

```bash
mkdir -p ~/code && git clone https://github.com/IanEdington/dotfiles ~/code/dotfiles
bash ~/code/dotfiles/claude-box/bootstrap
```

`bootstrap` installs Ubuntu's `ansible` package if needed, then runs
`playbook.yml` against the local machine. It is not named `install` because
the root `install` runs every `*/install`, and this must never run on a
laptop.

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
| `swap` | 4G `/swapfile`, active and in fstab, `vm.swappiness=10` |
| `hardening` | Key-only SSH via a `00-` drop-in (sshd keeps the first value it reads, and cloud-init's `50-cloud-init.conf` turns passwords back on), verified with `sshd -T`. Firewall allowing only SSH and mosh. OpenVPN absent: packages, PKI, NAT rules, IP forwarding, port, client `.ovpn` files |
| `packages` | Command-line, media and document tools from Ubuntu. GitHub's `gh` and Google Chrome from their own apt repositories (deb822 sources), with unattended-upgrades allowed to update both. Chrome is told not to add a duplicate apt source |
| `environment` | `CLAUDE_BOX=true` for every login, cron job and systemd user service (`/etc/environment`) and every Claude Code session (`managed-settings.d/` installed to `/etc/claude-code/`, root-owned; files removed from the repo are removed from the box) |
| `dotfiles` | Links the shared `git` and `tmux` config and `diff-so-fancy`, and includes `git/config` from `~/.local/git/config`. The laptop links the same files through each folder's `install`; keep the lists in step |
| `github` | Links the per-owner GitHub token helper and `gh` wrapper into `~/.local/bin`; creates the token directory |
| `node` | fnm in `~/.local/bin`, latest LTS Node as the default, linked into `~/.local/bin` so non-interactive shells and MCP servers find `node`/`npx`. Interactive bash gets fnm's `--use-on-cd` hook |
| `python` | uv (installed without editing shell files), Python 3.13, and `yt-dlp` as a uv tool |
| `claude` | Links `~/.claude` to `dotfiles/claude` and selects `claude-box.md` as the environment section. Registers the Playwright MCP with headless Chrome. On a box that already had a real `~/.claude`, copies its runtime state (login, sessions) over first and keeps the old directory as `~/.claude.pre-dotfiles-<timestamp>` |
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

### Switching to the Remote Control service

A box that already runs `claude remote-control` by hand (in tmux, say) sets
`remote_control_started: false` in `/etc/claude-box/vars.yml`, so the
playbook installs and enables the service without starting a second server.
To switch over, from your own SSH session (this ends any conversation served
by the old server):

```bash
sudo sed -i '/^remote_control_started:/d' /etc/claude-box/vars.yml
pkill -f 'claude remote-control'
bash ~/code/dotfiles/claude-box/bootstrap --tags remote_control
systemctl --user status claude-remote-control
```

Then open claude.ai/code and pick the box's environment. Logs:
`journalctl --user -u claude-remote-control`.

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
  `-R/--repo` or the current repo's `origin`.
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

## Still to do

- Staging SSH key pattern
- Final lockdown: separate admin user, remove the agent user's passwordless
  sudo (deliberately left on until setup is finished)
- cloud-init / autoinstall template that creates the users and runs this
  playbook on first boot
