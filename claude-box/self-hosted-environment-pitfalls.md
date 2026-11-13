# Self-hosted environment pitfalls

Empirically confirmed findings about running Claude Code on the Claude box (a
self-hosted environment provisioned by this directory's playbook). The cloud
equivalent is `claude/skills/cloud-environments/references/gotchas.md`. Append
new confirmed discoveries here, with the date.

## Git and GitHub

**A private clone fails with `could not read Username` when it runs inside the
sandbox.** The sandbox hides `~/.config/github-tokens`, so the credential
helper has nothing to return. Confirmed 2026-11-13 on `IanEdington/pkm` and
`IanEdington/personal-assistant`:

| Command | Result |
|---|---|
| `git clone <url> /home/claude/code/ianedington/pkm` (absolute destination) | `fatal: could not read Username for 'https://github.com/IanEdington/pkm.git': No such device or address` |
| `cd ~/code && mkdir -p ianedington && git clone <url> ianedington/pkm && ...` (compound command) | same error |
| `git clone <url> ianedington/pkm` (plain, relative destination, working directory `~/code`) | works |
| `git -C ~/code/dotfiles push --set-upstream origin <branch>` | `fatal: could not read Username for 'https://github.com/IanEdington/dotfiles'` |
| `cd ~/code/dotfiles` as its own command, then plain `git push --set-upstream origin <branch>` | works |

Run each network git command (`clone`, `push`, `fetch`, `pull`) as its own
plain command starting with `git`, with no `git -C`. Clone to a destination
relative to `~/code`; push from inside the repo after a standalone `cd`. A private `gpo/gpo-ca` clone inside a
`cd ... && git clone ...` chain succeeded in the same session, so the
sandbox-versus-excluded rule is not fully pinned down; the plain relative form
is the only shape that worked every time. See "Sandbox notes" in `README.md`.

**`gh` inside the sandbox reports `You are not logged into any GitHub hosts`.**
Tokens are invisible there. Run `gh` as its own command so it executes outside
the sandbox, where `bin/gh` picks the token for the repo's owner.

**The claude.ai GitHub connector's commit and PR search does not return
private repos.** `search_commits` and `search_pull_requests` for
`involves:IanEdington` returned public repos only: private repos with recent
pushes (`gpo/gpo-ca`, `gpo/secure-gpo-ca`, `IanEdington/pkm`) never appeared.
A repo list built from those searches undercounts private activity. Cross-check
against the repo list from `list_repos`. Cause unconfirmed.

## Filesystem

**`mv` of a directory under `~/code` can fail with `Device or resource busy`.**
Confirmed 2026-11-13 moving `~/code/qomon-automations` into
`~/code/trelliscommons/`. The directory is probably a mount point inside the
sandbox. Clone a second copy at the destination and have Ian delete the
original from outside the sandbox.

**`~/code/dotfiles/claude/` is the live `~/.claude`, so `git status` there lists
dozens of untracked entries** (`claude/.cc-writes`, `claude/access-audit`,
`claude/agents`, `claude/daemon.json`, `claude/ide`, and more). Stage by
explicit path; never `git add -A` or `git add .` in the dotfiles repo. Several
of those directories are unreadable to the sandbox, so `rg` over the repo
prints `Permission denied (os error 13)` for each; pass `--glob '!claude/*'`
or search a subdirectory.

**`~/code` holds character-device placeholders** (`.bashrc`, `.gitconfig`,
`.mcp.json`, `.idea`, `.vscode`, and others, owned by `nobody:nogroup`). They
are the sandbox's masks over protected paths, not files. Do not remove or
stage them.

## Commands and timing

**Foreground commands stop at 120 seconds and move to the background.** A
chain of clones then keeps running unattended, and a slow repo blocks every
repo queued after it (`secure-gpo-ca` stalled three later clones). Start each
large clone as its own `run_in_background` command.

**A foreground `sleep` is blocked.** Wait with a Monitor `until` loop or the
background-task notification instead of `sleep N; cat output`.

**Do not inspect the token store.** `ls ~/.config/github-tokens` is denied by
the permission classifier even when the aim is to debug a failed clone. Test
access with the clone itself, and ask Ian to check the token files.
