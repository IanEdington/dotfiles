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

1. SETUP SCRIPT: did it run, and when?
    - `cat ~/.cloud-setup-errors.log` (say "empty" or "missing" explicitly)
    - `ls -la --time-style=full-iso REPO/vendor REPO/node_modules 2>&1`
    - `uptime -s` for container boot time
    - Are those files timestamped near boot (baked in at setup time) or minutes
      after (installed by the SessionStart hook just now)? Say which, or say you
      cannot tell.

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
- Timestamps minutes after boot, not at boot, mean the Setup Script did not run
  or did nothing, and the SessionStart hook silently covered for it. This is the
  failure mode that looks like success: the session works, just slowly, every
  time.
- A dominant `~/.cache/composer/vcs` means the fallback ran. If you expected
  setup-time dists, the Setup Script did not do its job.
