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

System steps in `system.d/` run as root in filename order.

| Step | What it does |
| --- | --- |
| `10-swap.sh` | 4G `/swapfile`, `vm.swappiness=10` |
| `20-remove-openvpn.sh` | Removes the OpenVPN server the first droplet ran: packages, PKI, NAT rules, IP forwarding, firewall port, client `.ovpn` files |
| `30-sshd.sh` | Key-only SSH via a `00-` drop-in, because sshd keeps the first value it reads and cloud-init's `50-cloud-init.conf` turns passwords back on |

## Still to do

- Claude Code config: link `~/.claude` to `dotfiles/claude`
- Remote Control as a `systemd --user` service with lingering, working dir `~/code`
- Toolchain: Node, uv, Playwright MCP with headless Chromium, media tools
- Bash sandbox (bubblewrap, socat, AppArmor profile) and root-owned
  `/etc/claude-code/managed-settings.json`
- Staging SSH key pattern
- Final lockdown: separate admin user, remove the agent user's passwordless
  sudo (deliberately left on until setup is finished)
