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

`bootstrap` is idempotent: rerun it after pulling changes. It is not named
`install` because the root `install` runs every `*/install`, and this must
never run on a laptop.

## Steps

System steps in `system.d/` run as root, then user steps in `user.d/` run as
the invoking user, each in filename order.

| Step | What it does |
| --- | --- |
| `system.d/10-swap.sh` | 4G `/swapfile`, `vm.swappiness=10` |
| `system.d/20-remove-openvpn.sh` | Removes the OpenVPN server the first droplet ran: packages, PKI, NAT rules, IP forwarding, firewall port, client `.ovpn` files |
| `system.d/30-sshd.sh` | Key-only SSH via a `00-` drop-in, because sshd keeps the first value it reads and cloud-init's `50-cloud-init.conf` turns passwords back on |
| `system.d/40-environment.sh` | `CLAUDE_BOX=true` for every login, cron job and systemd user service (`/etc/environment`) and every Claude Code session (`managed-settings.d/` installed to `/etc/claude-code/`, root-owned) |
| `user.d/10-dotfiles.sh` | Links the shared `git` and `tmux` config and `diff-so-fancy`; skips the laptop-only installers |
| `user.d/20-github-tokens.sh` | Links the per-owner GitHub token helper and `gh` wrapper into `~/.local/bin` and includes `git/config` from `~/.local/git/config` |

## GitHub access

Fine-grained personal access tokens, one per owner, because a fine-grained
token belongs to exactly one user or org. Tokens live outside the repo in
`~/.config/github-tokens/<owner>` (lowercase, mode 0600).

- `bin/git-credential-github-owner` hands git the token matching the owner in
  the remote URL (`credential.useHttpPath` makes git pass the path).
- `bin/gh` wraps the real `gh` and exports `GH_TOKEN` for the owner from
  `-R/--repo` or the current repo's `origin`.
- HTTPS remotes only; SSH remotes bypass both.

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

- Claude Code config: link `~/.claude` to `dotfiles/claude`
- Remote Control as a `systemd --user` service with lingering, working dir `~/code`
- Toolchain: Node, uv, Playwright MCP with headless Chromium, media tools
- Bash sandbox (bubblewrap, socat, AppArmor profile) and root-owned
  `/etc/claude-code/managed-settings.json`
- Staging SSH key pattern
- Final lockdown: separate admin user, remove the agent user's passwordless
  sudo (deliberately left on until setup is finished)
