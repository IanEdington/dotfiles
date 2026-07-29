# Claude Code Cloud Environments

**Setup Script vs. SessionStart hooks:** Setup Script (environment config field) runs once per environment build/rebuild, before a session starts. SessionStart hooks (`.claude/settings.json` in a repo) run every session, including resumes.

**Setup Script has broader GitHub/network access than a live session** — confirmed empirically twice, not just inferred. A GitHub operation scoped to a session (private repo clone, a package resolving through `api.github.com`) can succeed at Setup Script time and 403 mid-session. Corollary: a live session cannot validate its own Setup Script behavior. To test a Setup Script change, edit the environment config, rebuild it, then check from a **separate fresh session** for: an empty `~/.claude/cloud-setup-errors.log`, the expected files existing, and — the part that actually proves it ran at setup time rather than being a stale cached image — file timestamps relative to container boot time.

**Public GitHub Releases downloads are a different code path than `api.github.com`/`codeload.github.com` zipballs and are not scope-blocked mid-session** — `github.com/<owner>/<repo>/releases/download/...` (which redirects to `objects.githubusercontent.com`) works fine in a live session even when git/API operations on the same repo don't. Useful when a tool ships as a GitHub release rather than through a package manager.

**Custom non-standard domains** (anything outside npm/PyPI/crates/packagist/GitHub) may not be on an environment's default network allowlist — that's a network-policy fix ("Custom network access" in the environment settings), not something a clever script can route around.

**Setup Script pattern that works well:**
- Put the install logic in a versioned file in the repo (e.g. `claude/cloud-environment-setup.sh`), not inline in the Setup Script field. Keep the field itself a tiny fetch-and-run stub, download-then-run rather than `curl | bash` (so a failed fetch hits the `else` branch instead of piping nothing into bash):
  ```bash
  if curl -fsSL "https://raw.githubusercontent.com/<owner>/<repo>/main/claude/cloud-environment-setup.sh" -o /tmp/setup.sh; then
    bash /tmp/setup.sh
  else
    mkdir -p ~/.claude
    echo "<repo>: could not fetch setup script during environment setup" >> ~/.claude/cloud-setup-errors.log
  fi
  ```
- Make the fetched script self-contained — `git clone` the repo itself if not already present, rather than assuming a pre-existing checkout.
- Log failures to `~/.claude/cloud-setup-errors.log`, append-only (I already check this at every session start, so reusing it costs nothing new — just make sure anything that truncates the file runs *before* anything that appends to it).
- A local `.claude/setup-env.sh` convenience wrapper should just delegate to the same canonical script, never a second copy to keep in sync.
- Avoid the tempting alternative of an orphan git branch + CI workflow that builds and caches dependency output as a tarball — it can work, but it's a lot of undebuggable machinery that doesn't transfer between repos. Only reach for it if Setup Script genuinely can't do the job.

**Other gotchas:**
- The sandbox's git remote is a local proxy, not GitHub directly — its cached view of a branch can lag behind reality. If `git log origin/main` looks stale, cross-check with a direct `curl` to `raw.githubusercontent.com/<owner>/<repo>/main/<path>`.
- Multiple sessions can work the same repo on the same branch name concurrently. Before force-pushing or resetting, `git fetch` and check for unrecognized commits on the remote.
- Docker's daemon can start fine while image pulls still 403 depending on network policy — don't assume Docker works just because `docker version` succeeds; try an actual `docker pull` first.
