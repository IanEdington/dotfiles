# Verifying a Setup Script

You cannot verify your own Setup Script from the session you are working in.
Not "it is better to use a fresh session": the session you are in was built
from the _previous_ image, and the Setup Script phase has network access your
session does not, so every observation you make locally is measuring the wrong
thing. Two specific ways this bites:

- Running the setup script by hand mid-session and watching it succeed proves
  nothing about the setup phase, and vice versa. A composer install that clones
  everything from source in your session may download dists at setup time.
- A warm `vendor/` in your session might be the image cache from a build that
  predates your change entirely.

So: make the change, get the environment rebuilt, then look from a new session.

## The loop

1. Edit the environment config in the web UI and save. Saving is what schedules
   a rebuild; there is no manual rebuild button, and the cache otherwise
   expires in about 7 days. **Only the human can do this step.** Ask, and say
   exactly what to paste.
2. Wait for the rebuild, then start a fresh session in that environment. You
   can spawn one yourself with `create_session` (claude-code-remote MCP) and
   drive it with `send_message`, rather than waiting on the human to relay
   output. Inherit the environment by omitting `environment_id`.
3. Run the checks below in that session and read the raw output.

## What to ask the fresh session

Paste this as the prompt. It is written to report facts rather than
conclusions, because the conclusions are what you are trying to establish.

```markdown
Do not fix anything. Investigate and report only. I need a factual report about
how this cloud environment was built. Run every check and give me raw output,
not summaries. If a command fails, show the error rather than working around it.

Substitute the real repo path for REPO below.

1. SETUP SCRIPT: did it run?
    - `cat ~/.cloud-setup-errors.log` (say "empty" or "missing" explicitly)
    - The SessionStart hook's own output is the reliable signal. If the hook
      says it found the work already done and skipped it, then something
      before the hook did that work, and the Setup Script is the only
      candidate. Quote the line.
    - Ask whether the repo is attached to this environment at all. If it is
      not, and a checkout exists anyway, something cloned it and the Setup
      Script is the only candidate.
    - `ls -la --time-style=full-iso REPO/vendor 2>&1` and `uptime -s` for
      context, but see the warning below before drawing conclusions from them.

2. WHAT IS INSTALLED
    - `cd REPO && git log --oneline -3 && git status --short && git branch --show-current`
    - Does the setup script this environment invokes actually exist on the
      checked-out branch? If it lives on an unmerged branch, say so.
    - Whatever the build is meant to produce: binaries, vendor dirs, built assets.

3. WHICH NETWORK PATH DID THE INSTALL TAKE?
   The point is to tell a fast path from a slow fallback. For composer:
    - `du -sh ~/.cache/composer/vcs 2>&1` (large means source clones)
    - `ls ~/.cache/composer/files 2>&1 | head` (entries mean dist downloads)
      Report which dominates.

4. NETWORK, from this live session
   For each host the build depends on, report HTTP status and any
   `x-deny-reason` header:
   `for u in <urls>; do echo "== $u"; curl -sS -o /dev/null -D - --max-time 25 "$u" 2>&1 | grep -iE '^HTTP|x-deny|curl:'; done`
   Include `raw.githubusercontent.com/<owner>/<repo>/<branch>/<path>` for each
   repo involved, and `api.github.com/repos/<owner>/<repo>`.

5. ENVIRONMENT SHAPE
    - `echo "$CLAUDE_CODE_REMOTE"`, language runtime versions, required extensions
    - `ls /home/user/` (which repos are attached?)

Then answer directly:

- Did the Setup Script run successfully, or did the SessionStart hook do the work?
- Did the install take the fast path or the fallback?
- Is the working tree clean, or did the setup leave files modified?
```

## Reading the result

- `~/.cloud-setup-errors.log` naming a fetch failure usually means the Setup
  Script could not reach the file it was told to run. For a private repo,
  suspect `raw.githubusercontent.com` first (see gotchas.md).
- **Do not use timestamps versus `uptime -s` as your discriminator.** It is
  tempting and it is wrong: the Setup Script can run _after_ the boot time the
  container reports, so setup-built files legitimately postdate boot and look
  exactly like something the session just installed. Observed directly:
  `vendor/autoload.php` two and a half minutes after `uptime -s`, created by
  the Setup Script, while the hook logged that it found it already present.
  Use the hook's own output instead.
- The failure mode that looks like success: the Setup Script did nothing and
  the SessionStart hook covered for it, so the session works, just slowly,
  every time. The hook saying it _did_ the install (rather than skipping it)
  is what exposes this.
- **`rev-parse --is-shallow-repository` proves nothing either.** The platform's
  own attached checkouts are shallow, so `true` is the answer whether the Setup
  Script cloned the repo or the session was handed it. Confirmed across three
  attached repos in one session, none of them cloned by the agent.
- The composer caches are sharper than either. An **empty**
  `~/.cache/composer/files` next to a large `~/.cache/composer/vcs` means the
  install got no dist downloads at all, so it ran with session-level network
  access rather than setup-level. Do not read a non-empty `vcs` as failure on
  its own: packages with no `dist` entry in the lock can only ever be cloned,
  so some `vcs` is normal. Count them first. A run that looked ambiguous on
  cache size alone was unambiguous once its 12 source-only packages were
  counted.
