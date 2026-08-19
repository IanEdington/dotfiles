# Claude Code Cloud Environments

> Single living log of empirically confirmed cloud-environment findings.
> Append new confirmed discoveries here.

**Setup Script vs. SessionStart hooks:** Setup Script (environment config field) runs once per environment build/rebuild, before a session starts. SessionStart hooks (`.claude/settings.json` in a repo) run every session, including resumes.

**Setup phase and session phase have DIFFERENT GitHub access, not more-vs-less.** An earlier version of this file said "Setup Script has broader access"; that is wrong and cost real time. The accurate model is in the "credential model" section below. Short version: session phase runs behind a credential-injecting proxy scoped to the attached repos; setup phase talks to real GitHub anonymously. Each reaches things the other cannot. A live session still cannot validate its own Setup Script (it was built from the previous image) — see `verification.md` for how to prove a Setup Script ran, and for why file timestamps and `--is-shallow-repository` are both wrong discriminators.

**Public GitHub Releases downloads are a different code path than `api.github.com`/`codeload.github.com` zipballs and are not scope-blocked mid-session** — `github.com/<owner>/<repo>/releases/download/...` (which redirects to `objects.githubusercontent.com`) works fine in a live session even when git/API operations on the same repo don't. Useful when a tool ships as a GitHub release rather than through a package manager.

**`raw.githubusercontent.com` 404s for private repos.** Confirmed: 200 for `gpo/canopy` (public), 404 for `gpo/gpo-ca` and `gpo/secure-gpo-ca` (private), on paths that exist. It is a 404 rather than a 401/403, so it reads as "wrong path" and invites you to debug the branch or filename instead of the access model. This breaks the curl fetch-and-run Setup Script stub for any private repo: the stub takes its error branch, logs, and installs nothing, while the SessionStart hook quietly covers for it. Reach the script through the attached checkout instead — it already exists at setup time (see the credential model section; the setup phase canNOT clone a private repo without a token, so do not write a clone fallback that assumes it can). The wider lesson: a Setup Script pattern copied from a public reference repo needs re-verifying against a private one, because nothing else about them differs visibly.

**Custom non-standard domains** (anything outside npm/PyPI/crates/packagist/GitHub) may not be on an environment's default network allowlist — that's a network-policy fix ("Custom network access" in the environment settings), not something a clever script can route around.

**The credential model — setup phase vs session phase.** Confirmed by repeated real rebuilds and a token probe across `gpo/gpo-ca` (private), `gpo/secure-gpo-ca` (private), and `gpo/canopy` (public):

- **Session phase** runs behind a credential-injecting proxy. It sets `GIT_CONFIG_KEY_*` / `GIT_ASKPASS` / `GITHUB_TOKEN` plus a `url.https://github.com/.insteadOf` rewrite, and authenticates git and `api.github.com` access to the repos ATTACHED to the session. Attached private repo → `api.github.com` 200, `git clone` works. Any repo NOT attached — a _public_ repo included, e.g. `canopy` — is 403 at `api.github.com` and `codeload`. The proxy ignores your own `Authorization` header: a bogus token and no token return the same status. So in session, access is by attachment, not by public/private, and you cannot present your own credentials.
- **Setup phase** has none of that machinery — no injected git config, no proxy credential injection, no `GITHUB_TOKEN`. It talks to real GitHub anonymously. Public content is reachable (`canopy` tarball/codeload/archive/raw all 200); private repos are NOT (`git clone` fails "could not read Username", tarball 404), and `api.github.com/repos/<x>` metadata is 403 even for the attached repo. But because nothing strips it, an `Authorization` header you send reaches GitHub: a bogus token returns 401 (not 403), and **a valid token authenticates and pulls any repo it is scoped to** — private, any owner, attached or not. Confirmed with a fine-grained read-only token inline: `api.github.com/repos/<private>` → 200, and tokened tarball + `git clone` of both private repos returned full source.

**To use a token at setup, it MUST be inline in the Setup Script field.** Environment variables set in the env-vars config section are injected into SESSIONS ONLY and are absent at setup — confirmed: the same token read as ABSENT when set as an env var, and present when written into the field. Consequences, none avoidable:

- The token lives in plaintext in the Setup Script field, visible to anyone with environment access (there is no secrets store). Scope it minimal, read-only, short expiry, and rotate after.
- It cannot be version-controlled or shared through the repo, and each environment holds its own copy — rotation is per-environment, by hand.
- Prefer a tokened **tarball** (`curl -H "Authorization: Bearer $TOK" https://api.github.com/repos/<owner>/<repo>/tarball/<ref> | tar -xz`) over a tokened `git clone`: the clone writes the token into `.git/config` and the reflog, where it persists into the cached image and every session; the tarball leaves no token on disk.

**Attached checkouts already exist at setup, before the Setup Script runs.** `/home/user/<repo>/` is a populated (shallow) git checkout by the time the field executes, so the field's fast path is to run the repo's script straight out of that checkout — no clone needed. **Name the repo explicitly; do NOT glob `/home/user/*/` and run whatever setup scripts happen to be attached.** An environment that runs "whatever is attached" produces different tooling run to run, depending on which repos are mounted at build time — the opposite of the stability people rely on an environment to have. A named repo with a token fetch fallback (pattern below) builds the same tools every time, whether or not that repo is currently attached.

**The Setup Script field runs under `set -e`.** A single failing command aborts the whole build and blocks session start — observed directly: a failing `git clone` exited 128 and the session would not start. Put `set +e` at the top of a probing/best-effort script, or guard every expected-failure command; a bare `|| true` on the last line does not protect the earlier ones.

**Setup Script pattern that works well:**

- Put the install logic in a versioned file in the repo (e.g. `claude/cloud-environment-setup.sh`), not inline in the Setup Script field. The field's job is to reach that file and run it.
- **How the field reaches the file depends on repo visibility.** For a **public** repo, the tiny fetch-and-run stub works (download-then-run rather than `curl | bash`, so a failed fetch hits the `else` branch instead of piping nothing into bash):

    ```bash
    if curl -fsSL "https://raw.githubusercontent.com/<owner>/<repo>/main/claude/cloud-environment-setup.sh" -o /tmp/setup.sh; then
      bash /tmp/setup.sh
    else
      echo "<repo>: could not fetch setup script during environment setup" >> ~/.cloud-setup-errors.log
    fi
    ```

    For a **private** repo the stub 404s (`raw.githubusercontent.com` serves no private content), so name the repo explicitly and give it two paths: run the script from the attached checkout if it is there, and fall back to a tokened tarball fetch if it is not. The token is required, checked up front, and the field hard-fails on the placeholder — a misconfigured environment should fail loudly at build time, not quietly produce a half-set-up sandbox:

    ```bash
    # === REQUIRED: a GitHub token with read (contents) access to gpo/gpo-ca.
    # The env-vars config section is NOT visible at setup time, so the token
    # must be pasted here in the field. Plaintext, no secrets store — scope it
    # read-only and rotate it.
    GH_SETUP_TOKEN="REPLACE_WITH_TOKEN"

    set -uo pipefail
    OWNER=gpo; REPO=gpo-ca; REF=main
    DIR="/home/user/$REPO"

    if [ "$GH_SETUP_TOKEN" = "REPLACE_WITH_TOKEN" ] || [ -z "$GH_SETUP_TOKEN" ]; then
      msg="$REPO setup: GH_SETUP_TOKEN not set in the Setup script field"
      echo "$msg" >> ~/.cloud-setup-errors.log
      echo "!! $msg — edit the field and rebuild." >&2
      exit 1
    fi

    if [ ! -d "$DIR/.git" ]; then
      echo "==> $REPO not attached; fetching $REF via token"
      mkdir -p "$DIR"
      if ! curl -fsSL -H "Authorization: Bearer $GH_SETUP_TOKEN" \
             "https://api.github.com/repos/$OWNER/$REPO/tarball/$REF" \
             | tar -xz -C "$DIR" --strip-components=1; then
        msg="$REPO setup: token fetch of $REF failed (token, scope, or ref?)"
        echo "$msg" >> ~/.cloud-setup-errors.log; echo "!! $msg" >&2; exit 1
      fi
    fi

    bash "$DIR/claude/cloud-environment-setup.sh"
    ```

    The tokened fetch uses a `Bearer` header, not a token-in-URL clone, so the secret is never written to `.git/config` or the reflog.

- Do NOT add an anonymous `git clone` fallback — the setup phase cannot clone a private repo without a token (see the credential model section), so it fails exactly when the fallback is needed. The tokened tarball above is the fallback.
- Log failures to `~/.cloud-setup-errors.log`, append-only (I already check this at every session start, so reusing it costs nothing new — just make sure anything that truncates the file runs _before_ anything that appends to it).
- A local `.claude/setup-env.sh` convenience wrapper should just delegate to the same canonical script, never a second copy to keep in sync.
- Avoid the tempting alternative of an orphan git branch + CI workflow that builds and caches dependency output as a tarball — it can work, but it's a lot of undebuggable machinery that doesn't transfer between repos. Only reach for it if Setup Script genuinely can't do the job.

**Setup Script phase network connectivity:**

Reachable / works:

- Standard package managers: `apt`, `pip`, `npm`, `packagist.org` (composer)
- `raw.githubusercontent.com` — for fetching scripts/files by exact path on a specific branch (404s if the path/branch doesn't exist, same as anywhere else)
- Plain GitHub Release asset downloads — `github.com/<owner>/<repo>/releases/download/<tag>/<asset>` (redirects to `objects.githubusercontent.com`). This works for any public repo, not just ones this session is attached to.
- Vendor-specific release CDNs, e.g. `get.helm.sh`
- `awscliv2.zip` from `awscliv2.amazonaws.com`
- Any host explicitly added to the environment's Custom network access allowlist (e.g. `mise.jdx.dev` once added — confirmed clean DNS/TCP/TLS/200 after allowlisting)

Blocked by default (egress allowlist, not a real network failure):

- Hosts not on the allowlist return a proxy-level 403 with `x-deny-reason: host_not_allowed` — DNS/TCP/TLS all succeed, so this is a policy block, not unreachable infrastructure. Fixable per-environment by adding the host to Custom network access. Confirmed for `mise.jdx.dev` before/after allowlisting.

Blocked regardless of allowlisting — this is the important one:

- `api.github.com` — mid-session, 403s with `"GitHub access to this repository is not enabled for this session"` for any repo not attached as a source (attached repos return 200). Allowlisting the host doesn't fix it; it is scope-based, not host-based. `mise install`'s `aqua` backend, which calls `api.github.com` directly for third-party tool repos (opentofu, sops, argocd, helmfile, jq, yq, pre-commit, helm), failed identically in both phases for this reason. Note the endpoint split confirmed by the token probe: at setup phase the `/repos/<x>` _metadata_ endpoint is 403 anonymously, but the `/repos/<x>/zipball/<ref>` and `/tarball/<ref>` _content_ endpoints return 200 for public repos (and for any repo with a valid inline token) — which is why composer dist downloads work at setup while `mise`'s metadata calls do not.

**Composer specifically:**

Composer resolves GitHub-hosted packages to a dist URL of the form `https://api.github.com/repos/<owner>/<repo>/zipball/<sha>`, so everything above about `api.github.com` scoping applies to every PHP dependency at once. The split between the two phases is sharp, and it is the whole reason composer belongs in the Setup Script:

- **At Setup Script time, dist downloads work.** Confirmed by a real environment rebuild on `gpo/canopy`: `composer install` pulled dist zips straight from `api.github.com`. Fast, and well inside the roughly 5 minute Setup Script budget.
- **Mid-session, no dist download from GitHub succeeds.** Every GitHub-hosted package 403s with "Could not authenticate against github.com", public packages included, and composer silently falls back to `git clone` from source. Non-GitHub dist hosts are unaffected and stay fast, so the damage is proportional to how much of the lock file resolves to GitHub: `gpo-ca` is 102 of 112 packages, `secure-gpo-ca` 266 of 332 (the rest come from `ftp.drupal.org`, `downloads.wordpress.org`, and `registry.npmjs.org`). Check with a one-liner over `composer.lock` before assuming the worst. Confirmed on `gpo/gpo-ca` and `gpo/secure-gpo-ca`. The message reads like a credentials problem and is not one: **mid-session**, no token or `COMPOSER_AUTH` value helps, because the proxy denies at CONNECT, before auth is offered. `codeload.github.com` is blocked identically, so composer's `use-github-api: false` escape hatch does not help either. (Setup phase is the opposite — a token there does authenticate; see the credential model section. This is exactly why the install belongs at setup.)

Consequences for the mid-session fallback path, which is worth keeping but is genuinely slow:

- Source clones work for public repos, but composer's default 300s per-process timeout kills the large ones (phpstan is a reliable casualty). Set `COMPOSER_PROCESS_TIMEOUT=0`. Budget tens of minutes for a cold install: measured on two repos of roughly 100 and 300 packages.
- Have the session hook short-circuit on `vendor/autoload.php` existing, so a warm cached image costs nothing.
- Packages from **private** repos are unreachable _mid-session_ by every method: dist 403s on scope, and the source clone falls through to an interactive credential prompt. Two ways out at SETUP phase, where a token works (see the credential model section):
    - **Inline token + `COMPOSER_AUTH`.** A composer dist URL is `api.github.com/repos/<owner>/<repo>/zipball/<sha>` — the exact shape a setup-phase token authenticates — so `COMPOSER_AUTH='{"github-oauth":{"github.com":"<token>"}}'` inline in the field should let `composer install` pull private packages directly, scoped by the token rather than by attachment. This sidesteps the cross-owner limit below entirely (a token can span `gpo/*` and `gppackagist/*`). Confirmed for raw tarball/clone; not yet confirmed end-to-end through composer — verify before relying on it.
    - **Attach the repos**, which only works same-owner: `add_repo` refuses a cross-owner add ("cross-tier adds are not supported"), so one environment cannot hold both `gpo/*` and `gppackagist/*`.
    - **Last resort — trim them.** Drop those packages from `composer.json` and `composer.lock` for the duration of the install and restore afterwards. The lock's `content-hash` must be recomputed with composer's own `Composer\Package\Locker::getContentHash` (reachable via `require "phar://<path-to-composer>/vendor/autoload.php"`), or composer rejects the trimmed manifests. Only reach for this if the token route is unavailable, since it leaves the sandbox without those packages.
- **Composer plugins fetch their own files and fail late.** `--no-scripts` does not disable plugins. `civicrm/civicrm-core`'s downloads plugin pulls asset bundles from `github.com/<owner>/<repo>/archive/<tag>.zip`, a GitHub archive and so scope-blocked, and aborts _after_ every package installs but _before_ the autoloader is written. The result is a `vendor/` that looks complete and is unusable. Recovery is `composer dump-autoload`, not a reinstall. `--no-plugins` is not an alternative, because plugins are also what place Drupal core and WordPress plugins outside `vendor/`.
- `composer install` reads only `composer.lock` and never queries repository metadata, so custom repository hosts (`wpackagist.org`, `gppackagist.github.io`) do not need allowlisting for it to succeed. `composer update` and `composer require` do need them. This is a useful diagnostic split: if `install` works but `update` 403s, the missing host is a repository host, not a dist host.
- Confirmed reachable once allowlisted, for PHP CMS work: `ftp.drupal.org` and `packages.drupal.org` (`*.drupal.org`), `git.drupalcode.org` (`*.drupalcode.org`), `downloads.wordpress.org`, `download.civicrm.org` and `lab.civicrm.org` (`*.civicrm.org`, and `lab` is a git host, so CiviCRM extensions clone from it), and `ga.jspm.io`. `ppa.launchpadcontent.net` (`*.launchpadcontent.net`) is what makes `apt install php8.x-<ext>` work from the sury PPA, which is easy to overlook until an extension install fails.

**Other gotchas:**

- The sandbox's git remote is a local proxy, not GitHub directly — its cached view of a branch can lag behind reality. If `git log origin/main` looks stale, cross-check with a direct `curl` to `raw.githubusercontent.com/<owner>/<repo>/main/<path>`.
- Multiple sessions can work the same repo on the same branch name concurrently. Before force-pushing or resetting, `git fetch` and check for unrecognized commits on the remote.
- Docker's daemon can start fine while image pulls still 403 depending on network policy — don't assume Docker works just because `docker version` succeeds; try an actual `docker pull` first.
