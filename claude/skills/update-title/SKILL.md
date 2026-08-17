---
name: update-title
description: Rename the current Claude Code session with a short, specific title derived from the conversation. Use when the user invokes /update-title, or asks to rename, retitle, or name this chat or session, or when the auto-derived name (e.g. "dotfiles-63") no longer reflects what the session became.
---

# update-title

The title is how the user finds this session in a list of thirty later. Replace
the stale auto-name ("dotfiles-63") with one that names what the session became.
Choose the title well (the whole value), then apply it.

## Step 1: Choose the title

Write it like a good commit or PR title: a short, specific, subject-first noun
phrase summarizing the whole body of work. Title the session's through-line, not
just the first message, and draft a few to keep the most specific. What you
want:

1. **Name the subject, not the activity.** "Fix parser unicode crash", not
   "Debugging". A verb is fine if a concrete noun follows.
2. **Front-load the distinctive word** — sidebars truncate from the right.
3. **Short noun phrase, ~2 to 6 words.** Sentence case, no trailing period.
4. **Distinctive in the list.** Drop words every session shares: the repo name
   the UI already shows, "session", "work", "help".
5. **No appended explainer** after a dash or colon; keep the half that names it.

Unlike a commit or PR title, skip the `fix:`/`feat:` prefix and the imperative
mood: a session is often a topic or a question, not a merged change ("Airflow
retry backoff", not "fix: add DAG retry backoff").

For a thin session (a quick question), a plain two-word topic is correct.

## Step 2: Apply it

Detect the environment (these tools are deferred, so this loads them too):

```
ToolSearch("select:mcp__Claude_Code_Remote__get_session,mcp__Claude_Code_Remote__set_session_title")
```

**Tools loaded (cloud, Remote Control):** call `get_session` with **no
arguments** to get this session's own id (starts with `session_`; no-args always
targets the caller), then `set_session_title({session_id, title})`. Report the
applied title and list the runners-up so the user can swap with one word.

**Tools absent (local desktop, VS Code):** no tool can rename the current
session and the model cannot type a slash command, so hand the user
`/rename <title>` to paste (plus a couple of alternates). Always include the
text; bare `/rename` auto-generates.
