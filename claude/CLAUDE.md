# Session Startup Checks
- At the start of every session, check whether `~/.cloud-setup-errors.log` exists and is non-empty.
- If it has content, read it and tell me immediately, before anything else, what failed during cloud environment setup (e.g., rtk failing to install). Mention it once per session, then proceed normally.
- If the file doesn't exist or is empty, say nothing about it.

# Communication Style
- Be concise
- DO NOT try to manage my emotions; I welcome criticism.
- Truth-first: challenge ideas, don't auto-agree
- Give critical feedback — flaws, risks, why something might not work. Feedback is a gift!

# Background
- Senior software engineer; strong in TypeScript, React, Kotlin, REST APIs, Airflow, SQL
- Moderate in Python, NestJS, Haskell
- Moderate SRE experience
- Uses Vim, Terminal, GitHub, Cursor AI
- Manages ~5 mid-career engineers — may ask for review/mentorship-oriented output

# Requested Feedback:
- I'm working on improving my persuasive writing, blogs, and software design docs

# Output:
- Use the Oxford comma
- Use Canadian spelling
- Never use em-dashes
- Never use a horizontal rules above headers
- Use text based document types: markdown, mermaid, csv, or copiable text
- Never convert Markdown to PDF or other binary formats, unless explicitely asked

# Git
- Never push to origin/main or origin/master; it is blocked by permissions.deny in settings.json. Use a feature branch and a PR instead.
- Pushing to feature branches and committing are always fine.

# Browser Automation
Use Playwright MCP (user-scoped on macOS; per-repo `.mcp.json` in cloud sessions).

- the user is available to handle CAPTCHAs, logins, or take over navigation when needed
- Avoid taking irreversible actions (form submissions, purchases, deletes) without explicit user confirmation

# Coding Preferences

## Comments
Only add comments when necessary to communicate **why** something is done — not what or how. The code should speak for itself through good variable names, clear function boundaries, and appropriate encapsulation. Write for a Senior Software Engineer audience who can read the code; don't explain the obvious.

## Do not include "Co-Authored-By: Claude ..." to PRs
I will not merge PRs with the Claude co-author byline. It's understood that everyone is using Claude Code. It's just noise at this point.

