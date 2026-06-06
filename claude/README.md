# Claude Code Cloud Configuration

This directory contains personal Claude Code configuration that is loaded into
every Claude Code cloud (web) session via an environment setup script.

## How it works

Claude Code cloud sessions start with an empty home directory — `~/.claude`
does not exist. The setup script in this directory shallow-clones this public
dotfiles repo and copies the `claude/` contents into `~/.claude/` before the
session begins.

`~/.claude/CLAUDE.md` is the user-level memory file that Claude Code reads
automatically, so your preferences, conventions, and constraints are available
in every session without any manual steps.

## Wiring it up

1. Open the [Claude Code web UI](https://claude.ai/code) and navigate to
   **Environments**.
2. Create a new environment (or edit an existing one).
3. In the **Setup script** field, paste the following one-liner:

   ```bash
   bash <(curl -fsSL https://raw.githubusercontent.com/IanEdington/dotfiles/main/claude/cloud-setup.sh)
   ```

   Alternatively, paste the full contents of `cloud-setup.sh` directly into the
   field if you prefer not to use a remote curl.

4. Set the environment's **network policy** to one that allows outbound HTTPS to
   `github.com` — the script clones the repo over HTTPS.  If the clone is
   blocked the script will warn and exit cleanly (the session still starts, just
   without the custom config).

5. Save the environment and start a session.  You should see `[cloud-setup]`
   lines in the session startup output confirming the config was loaded.

## Keeping config up to date

Edit `claude/CLAUDE.md` (or any other files here) in this repo and push.  The
next session will pick up the latest version automatically — the setup script
always clones fresh.

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | User memory file — loaded by Claude Code as `~/.claude/CLAUDE.md` |
| `cloud-setup.sh` | Environment setup script — run once before each cloud session |
| `README.md` | This documentation |
