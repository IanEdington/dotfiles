# Handoff: SigNoz OTel backend for Claude Code telemetry

You are setting up a self-hosted SigNoz instance on a DigitalOcean droplet to
receive OpenTelemetry data from Claude Code sessions. Treat the host as
hostile-facing: assume scanning begins within minutes of the TLS certificate
appearing in Certificate Transparency logs, because it does.

## Goal

Claude Code (cloud sessions on claude.ai/code, and local CLI) exports OTLP over
HTTPS to this server. The metric of interest is the `assistant_response` event's
`response_length` (characters of visible assistant text, excluding thinking and
tool-use blocks) plus `claude_code.token.usage`. The end state is a SigNoz
dashboard trending daily median and p90 response length.

## Inputs you need from the operator before starting

- Droplet IP, SSH access, and the droplet's size (RAM matters, see Sizing).
- DNS control for `ianedington.ca` (wildcard `*.ianedington.ca` is available).
- An email address for Let's Encrypt registration.
- Where secrets should be stored (assume 1Password unless told otherwise; the
  operator uses it).

Ask for anything missing rather than inventing values. Do not proceed past
Phase 2 if the droplet is smaller than the Sizing section requires.

## Sizing (check this first)

SigNoz runs ClickHouse, ZooKeeper, an OTel Collector, a query service, and the
UI. ClickHouse alone wants ~4 GB RAM to be stable. A 1 GB or 2 GB droplet will
OOM-kill ClickHouse under any real ingest.

- Minimum workable: 4 GB RAM / 2 vCPU, 80 GB disk.
- If the droplet is smaller, stop and tell the operator, with two options:
  resize the droplet, or drop SigNoz in favour of a plain OTel Collector plus
  ClickHouse with no APM UI (much lighter, but loses the reason SigNoz was
  chosen). Do not silently tune SigNoz down to fit; a memory-starved ClickHouse
  fails in confusing ways later.

Also add swap (2 GB) regardless: it converts a hard OOM kill into slow
degradation you can see in metrics.

## Threat model

Two services want to be reachable, with very different exposure:

1. **OTLP ingest** (`otel.ianedington.ca`) must accept connections from
   Anthropic's cloud egress, whose IP range is not publishable or stable. It
   therefore cannot be IP-restricted, and is the exposed surface. Protect it
   with a bearer token checked at the reverse proxy, so an unauthenticated
   request never reaches the collector.
2. **SigNoz UI** (`signoz.ianedington.ca`) only ever needs to be reached by the
   operator. Do not expose it to the internet. Prefer Tailscale (bind the UI to
   the tailnet interface only). If the operator does not want Tailscale, second
   choice is a firewall allowlist of their home and mobile IPs; third choice,
   and only with explicit approval, is public exposure behind proxy-level basic
   auth on top of SigNoz's own login.

Non-negotiables for this build:

- No database, ClickHouse, ZooKeeper, or collector port is published on the
  host's public interface. In `docker-compose`, bind published ports to
  `127.0.0.1:` explicitly. ClickHouse's 8123/9000 reaching the internet is the
  single most common way self-hosted setups get owned.
- The only inbound ports open in the DO cloud firewall and in `ufw` are 443 and
  the SSH port. Not 80 (see the ACME note below), not 4317, not 4318, not 8080.
- SSH: key auth only, `PasswordAuthentication no`, `PermitRootLogin no`, work as
  a non-root user with sudo. Install and enable `fail2ban` for sshd.
- `unattended-upgrades` enabled for security patches.
- Every secret (ingest token, SigNoz admin password) is generated on the server
  with `openssl rand -hex 32`, never typed into a chat, and handed to the
  operator once for storage in 1Password.

## Certificates

Use a DNS-01 challenge with a wildcard certificate for `*.ianedington.ca`. Two
reasons: it avoids opening port 80 for HTTP-01, and a wildcard keeps the
specific hostnames out of Certificate Transparency logs, so scanners see only
the wildcard rather than a list of your service names. It does not hide the
server, but it removes the free directory listing.

Caddy is the recommended proxy (automatic ACME, small config). It needs the
DNS-provider plugin for whoever hosts `ianedington.ca` DNS, which means using a
Caddy image built with that plugin (`xcaddy`, or a prebuilt
`caddy:*-with-dns-*` image). Ask the operator for a DNS API token scoped to
that zone only. If a DNS token cannot be issued, fall back to HTTP-01, which
requires opening port 80; say so explicitly rather than deciding alone.

## Phases

Work through these in order. After each phase, verify before moving on, and
report what you verified.

### Phase 1: Host hardening
Non-root sudo user, SSH keys only, sshd hardened and restarted (keep your
current session open and test a second login before closing it), ufw default
deny inbound with 443 and SSH allowed, DO cloud firewall matching, fail2ban,
unattended-upgrades, 2 GB swap, Docker Engine and the compose plugin installed
from Docker's own apt repo.

### Phase 2: DNS and certificates
`A` records for `otel` and `signoz` (or a wildcard `A`) pointing at the droplet.
Caddy running with the DNS plugin, issuing the wildcard certificate. Verify the
cert is live and that plain HTTP is not serving anything.

### Phase 3: SigNoz
Clone `https://github.com/SigNoz/signoz`, use `deploy/docker`, and override the
compose file so that no service publishes a port on `0.0.0.0`. Bring the stack
up and confirm ClickHouse is healthy and the query service is running.

### Phase 4: Proxy and auth
Caddy routes:
- `otel.ianedington.ca` → collector OTLP/HTTP on `127.0.0.1:4318`, gated on an
  `Authorization: Bearer <token>` header matching the generated ingest token.
  Reject anything else with 401 before proxying. Rate-limit if straightforward.
- `signoz.ianedington.ca` → UI on `127.0.0.1:8080`, restricted per the threat
  model above.

Prefer OTLP over HTTP (4318) rather than gRPC (4317): header-based auth and
proxying are simpler, and Claude Code supports `http/protobuf`.

### Phase 5: Verify ingest
Send a synthetic OTLP payload with `curl` and confirm it appears in SigNoz.
Confirm that the same request without the bearer token returns 401. Then have
the operator add these to their Claude Code cloud environment settings:

```
CLAUDE_CODE_ENABLE_TELEMETRY=1
OTEL_METRICS_EXPORTER=otlp
OTEL_LOGS_EXPORTER=otlp
OTEL_EXPORTER_OTLP_PROTOCOL=http/protobuf
OTEL_EXPORTER_OTLP_ENDPOINT=https://otel.ianedington.ca
OTEL_EXPORTER_OTLP_HEADERS=Authorization=Bearer <ingest token>
```

`OTEL_LOGS_EXPORTER` is not optional here: `response_length` arrives as a log
event, not a metric. If the cloud environment restricts outbound domains,
`otel.ianedington.ca` must be added to its allowlist.

Then start a throwaway cloud session, say anything, and confirm an
`assistant_response` event lands in the SigNoz logs explorer.

### Phase 6: Retention, backup, dashboard
- Set ClickHouse TTL / SigNoz retention deliberately (suggest 90 days for
  logs, 13 months for metrics so year-over-year comparisons work).
- Back up the compose files, Caddyfile, and SigNoz's ClickHouse volume; a
  nightly `docker compose exec` dump to a DO Space or off-box location is
  enough. An untested backup is not a backup, so restore it once.
- Build one dashboard: daily median and p90 of `response_length`, plus session
  count. That single chart is the reason this server exists.

## Deliverables

- Everything reproducible: compose files, Caddyfile, and any scripts committed
  to a git repo (ask the operator which; likely a new private repo, not the
  dotfiles repo, since it will hold host-specific config).
- A short `README.md` in that repo: what runs where, which ports are open, how
  to restart, where secrets live, how to restore from backup.
- A handover message listing the generated secrets once, the URLs, and anything
  you could not complete.

## Rules of engagement

- Do not weaken any hardening step to make something work. If a step blocks
  progress, report it and propose alternatives.
- Do not paste secrets into files that get committed; use an untracked `.env`
  with `600` permissions, and note its location in the README.
- Prefer official upstream install paths over convenience scripts from
  third parties.
- If SigNoz's upstream compose layout has changed from what this document
  assumes, follow upstream and say what differed.
