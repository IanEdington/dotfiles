# Claude Code Cloud Environments: official docs summary

Condensed from the official docs as of 2026-08. Sources:

- https://code.claude.com/docs/en/cloud-environments.md (main reference)
- https://code.claude.com/docs/en/claude-code-on-the-web.md
- https://code.claude.com/docs/en/hooks.md
- https://code.claude.com/docs/en/routines.md
- https://code.claude.com/docs/en/network-config.md

## What an environment is

- A saved configuration applied to cloud sessions started from any surface:
  web, `claude --cloud`, Claude Tag, routines, mobile, and desktop.
- Fields: Name, Network access level (None, Trusted, Full, Custom),
  Environment variables (`.env` format), and Setup Script (Bash).
- Sessions run as root in an isolated Ubuntu 24.04 VM: 4 vCPUs, 16 GB RAM,
  30 GB disk, with a fresh clone of the repo. No custom base image.
- Personal environments are created at claude.ai/code (environment selector
  above the message box); org-shared environments by admins at
  claude.ai/admin-settings/claude-code. Environments can be archived.
- No CLI or public API creates environments. `/remote-env` in the CLI only
  picks the default environment for `claude --cloud` (stored in user
  settings as `remote.defaultEnvironmentId`).
- Env var edits affect only new sessions. Env vars are readable by anyone
  with access to the environment; there is no secrets store.

## Setup Script semantics

- Runs once, before Claude Code launches, in the first session after an
  environment build. Afterwards the filesystem is snapshotted and reused.
- Cache invalidation: editing the Setup Script, editing network access, or
  ~7 day expiry. No manual rebuild button.
- Must exit 0 (otherwise the session fails to start) and finish within
  about 5 minutes. Append `|| true` to non-critical commands.
- The cache stores files and Docker images but not running processes;
  databases and compose stacks must be started per session.

## SessionStart hooks in cloud sessions

- Run on every session start and resume, after Claude Code launches.
  Matchers: startup, resume, clear, compact, fork.
- Sources that apply in cloud: repo `.claude/settings.json`, org
  server-managed settings, and plugins. User `~/.claude/settings.json` does
  NOT apply (it stays on the local machine).
- Cannot block the session; can inject context via
  `hookSpecificOutput.additionalContext`.
- Env vars set in a hook do not propagate; write them to a file and source
  it. Check `CLAUDE_CODE_REMOTE=true` to scope hooks to cloud sessions.

## Network access levels

- None: no outbound internet (Anthropic API still reachable via a separate
  channel).
- Trusted (default): allowlist of package registries (npm, PyPI, RubyGems,
  crates.io, Maven, NuGet, Composer, Hex), GitHub, Docker registries, cloud
  provider SDK endpoints, Linux package mirrors, common dev tools and CDNs.
  Full list: https://code.claude.com/docs/en/cloud-environments.md#default-allowed-domains
- Full: any domain.
- Custom: user-defined allowlist, one domain per line, `*.domain` wildcards,
  optional checkbox to also include the Trusted defaults.
- All traffic passes through a security proxy. GitHub traffic uses a
  dedicated proxy with scoped credentials independent of the access level.
  MCP connector traffic routes through Anthropic and needs no allowlist
  entries.
- `git push` is limited to the current working branch; GitHub API requests
  only reach repositories attached to the session (403 otherwise).

## Pre-installed toolchains

Python (pip, poetry, uv, pytest, ruff), Node 20 to 22 (npm, yarn, pnpm,
bun), Ruby 3.1 to 3.3, PHP 8.4, OpenJDK 21 (Maven, Gradle), Go, Rust,
GCC/Clang/cmake, Docker with compose, PostgreSQL 16 and Redis 7 (installed,
not started), plus git, jq, yq, ripgrep, tmux. Not installed: .NET, `gh`
CLI. Run `check-tools` in a cloud session for exact versions.

## Routines and environments

- Each routine selects exactly one environment at creation and inherits its
  network policy, env vars, and Setup Script on every run; no per-run
  override.
- Fire API: `POST https://api.anthropic.com/v1/claude_code/routines/<id>/fire`
  with beta header `anthropic-beta: experimental-cc-routine-2026-04-01`.

## Limits and quirks

- Sessions expire after inactivity; the VM is reclaimed and can be reopened
  on a fresh VM with conversation restored.
- No interactive auth (SSO or browser logins fail).
- Bun has known compatibility issues with the security proxy; no SOCKS
  proxy support.
- Org IP allowlisting breaks cloud sessions (Anthropic infrastructure is
  outside your IP range); support can exempt Anthropic IPs.
- `claude --teleport <session-id>` pulls a cloud session into a local
  terminal (same account, clean git state, branch on remote required).
