---
name: cloud-environments
description: Create, configure, or debug Claude Code cloud environments (claude.ai/code). Covers environment config (Setup Script, network access levels, environment variables), SessionStart hooks for cloud sessions, setup-script authoring patterns, and verifying that setup actually ran. Use whenever the user wants to set up a new cloud environment, write or fix a Setup Script, add tools to cloud sessions, debug a 403 or install failure inside a cloud session, choose a network access policy, or asks why something works locally but fails in Claude Code on the web.
---

# Claude Code Cloud Environments

An environment is a saved config (name, network access level, environment
variables, Setup Script) applied to every cloud session started from it.
Environments are managed only in the web UI at claude.ai/code (no CLI or API
to create them). Sessions run as root in an ephemeral Ubuntu 24.04 VM
(4 vCPU, 16 GB RAM, 30 GB disk) with a fresh clone of the repo.

Two reference files back this skill. Read them when you reach the relevant
step, not preemptively:

- `references/gotchas.md`: the living log of empirically confirmed behaviour
  (network scoping, what is reachable at Setup Script time, proxy quirks).
  Read this before writing or debugging any Setup Script, and append new
  confirmed findings to it.
- `references/official.md`: condensed official docs (config fields, caching,
  network levels, hooks, limits) with source URLs.
- `references/verification.md`: how to prove a Setup Script actually ran, and
  the prompt to hand a fresh session. Read it at Step 4, and do not skip it.

## Step 1: Decide what goes where

Three places to put setup, with different lifecycles:

| Mechanism                                           | Runs                                            | Use for                                                                                         |
| --------------------------------------------------- | ----------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| Setup Script (env config field)                     | Once per environment build, then cached ~7 days | Installing toolchains, heavy dependencies, Docker images                                        |
| SessionStart hook (`.claude/settings.json` in repo) | Every session start and resume                  | Fast per-session setup, starting services, injecting context                                    |
| Environment variables (env config field)            | Every session                                   | Config values and tokens (visible to anyone with environment access; there is no secrets store) |

Rules of thumb:

- Anything slow or cacheable belongs in the Setup Script; SessionStart hooks
  add latency to every session.
- Running processes (Postgres, Redis, docker compose stacks) are NOT cached;
  start them per session via a SessionStart hook or on demand.
- Scope cloud-only hook behaviour with `CLAUDE_CODE_REMOTE=true`.
- User-level `~/.claude/settings.json` hooks do not run in cloud sessions;
  only repo `.claude/settings.json`, org settings, and plugins carry over.

## Step 2: Choose the network access level

Levels: None, Trusted (default allowlist: package registries, GitHub, Docker
registries, cloud SDKs), Full, and Custom (own allowlist, optionally on top
of Trusted, wildcards like `*.internal.example.com` allowed).

Critical distinctions (details in `references/gotchas.md`):

- A blocked host returns a proxy-level 403 with `x-deny-reason:
host_not_allowed`; DNS, TCP, and TLS all succeed. Fix: add the host to
  Custom network access. It is a policy block, not an outage.
- `api.github.com` access is scoped to repos attached to the session, and
  allowlisting the host does NOT fix it. Tools that hit the GitHub API for
  arbitrary repos (e.g. `mise`'s aqua backend) fail in both the Setup Script
  phase and live sessions. Prefer package managers or direct GitHub Release
  asset downloads (`github.com/<owner>/<repo>/releases/download/...`), which
  use a different, unscoped code path.

## Step 3: Write the Setup Script

Constraints: must exit 0 (non-zero fails session start), must finish within
about 5 minutes, runs as root.

Pattern that works well:

1. Put the real install logic in a versioned script in the repo (e.g.
   `claude/cloud-environment-setup.sh`), not inline in the config field.
2. Keep the config field a tiny download-then-run stub (never `curl | bash`,
   so a failed fetch hits the error branch instead of piping nothing):

    ```bash
    if curl -fsSL "https://raw.githubusercontent.com/<owner>/<repo>/main/claude/cloud-environment-setup.sh" -o /tmp/setup.sh; then
      bash /tmp/setup.sh
    else
      echo "<repo>: could not fetch setup script during environment setup" >> ~/.cloud-setup-errors.log
    fi
    ```

3. Make the fetched script self-contained: clone the repo itself if needed,
   assume nothing about pre-existing checkouts.
   **The curl stub only works for a public repo.**
   `raw.githubusercontent.com` 404s for private repos, so a fetch-and-run
   stub copied from a public reference repo will silently take its error
   branch and install nothing. For a private repo, reach the script through
   a checkout instead, cloning first if it isn't there (the Setup Script
   phase can clone private repos even though a live session cannot):

    ```bash
    REPO=/home/user/<repo>
    [ -d "$REPO/.git" ] || git clone --depth 1 https://github.com/<owner>/<repo>.git "$REPO"
    bash "$REPO/claude/cloud-environment-setup.sh" || true
    ```

    More generally: a pattern lifted from a working reference repo needs
    re-verifying against yours. Public vs private is the difference that
    bites most often, because everything else about the two looks identical.

4. Log failures append-only to `~/.cloud-setup-errors.log` and append
   `|| true` to non-critical commands so one flaky install does not brick the
   environment. Anything that truncates the log must run before anything
   that appends.
5. A local convenience wrapper should delegate to the same canonical script,
   never be a second copy to keep in sync.
6. Avoid orphan-branch-plus-CI tarball caching schemes; they are
   undebuggable machinery. Only consider them if the Setup Script genuinely
   cannot do the job.

## Step 4: Verify from a fresh session

**Read `references/verification.md` and do this. A Setup Script you have not
verified this way is not finished, however carefully you wrote it.**

You cannot verify it from the session you are working in. The Setup Script
phase has network access your session does not, and your session was built
from the previous image, so local observations measure the wrong thing.
Running the script by hand mid-session and watching it pass proves nothing.

The failure mode is quiet: the SessionStart hook covers for a Setup Script
that never ran, so sessions work, just slowly, forever. Nobody notices,
because nothing is broken. That is exactly what makes the check worth
running rather than reasoning about.

`references/verification.md` has the loop and a ready-to-paste prompt for the
fresh session. Step 1 of that loop (editing and saving the environment config
to schedule a rebuild) can only be done by the human, so ask, and say exactly
what to paste. You can spawn the verification session yourself with
`create_session` rather than relaying output through the human.

## Debugging quick checks

- Install 403s or hangs: suspect network scoping before your approach; check
  for `x-deny-reason: host_not_allowed`, then decide allowlist fix vs
  scope-blocked (`api.github.com`) workaround.
- `git log origin/<branch>` looks stale: the remote is a caching proxy;
  cross-check `curl https://raw.githubusercontent.com/<owner>/<repo>/<branch>/<path>`.
- Docker daemon up but pulls 403: network policy; try an actual `docker pull`
  before assuming Docker works.
- Session dies on start: Setup Script exited non-zero or exceeded ~5 minutes.
- Bun and some custom package managers have known issues with the security
  proxy.
