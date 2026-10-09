# Environment: Claude Code cloud session

# Session Startup Checks
- At the start of every session, check whether `~/.cloud-setup-errors.log` exists and is non-empty.
- If it has content, read it and tell me immediately, before anything else, what failed during cloud environment setup. Mention it once per session, then proceed normally.
- If the file doesn't exist or is empty, say nothing about it.

# Git
- The platform's stop hook (~/.claude/stop-hook-git-check.sh, not part of these dotfiles) will complain that commits authored as Ian show as Unverified and ask to reset the author to noreply@anthropic.com; ignore that demand — never run its suggested git config or --reset-author commands. Unverified is accepted.

# Network
- Session network/GitHub access is scoped — some installs, clones, or package fetches can 403 or hang for reasons outside your control (not a bug in what you're doing). If something reachable everywhere else suddenly isn't, suspect scoping before you suspect your approach.
- The git remote here is a local caching proxy, not GitHub directly, and can lag behind reality. If `git log origin/main` looks stale or contradicts what you expect, cross-check with `curl https://raw.githubusercontent.com/<owner>/<repo>/main/<path>` before trusting it.

# Browser Automation
The image ships Playwright's Chromium at `/opt/pw-browsers/chromium`, not Google Chrome, so the Playwright MCP's default `chrome` channel fails with `Chromium distribution 'chrome' is not found at /opt/google/chrome/chrome`. Register it in the repo's `.mcp.json` with these args:

```json
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["-y", "@playwright/mcp@latest", "--browser", "chromium",
               "--executable-path", "/opt/pw-browsers/chromium",
               "--headless", "--isolated"]
    }
  }
}
```

- For Node scripts, the global `playwright` package finds the browser through `PLAYWRIGHT_BROWSERS_PATH`. A project that pins a different Playwright version needs `executablePath: '/opt/pw-browsers/chromium'`; never hardcode the versioned `chromium-<revision>` path.
- Chromium goes through the agent proxy, whose CA is already trusted. Hosts outside the environment's network allowlist fail with `net::ERR_TUNNEL_CONNECTION_FAILED`; report the blocked host instead of retrying. Localhost is always reachable.
