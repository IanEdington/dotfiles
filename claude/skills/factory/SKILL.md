---
name: factory
description: Spawn controller sessions for a run, and nothing else. Use when a session's first message starts with "You are the factory for". Reads every request against the Run state PR body, never against the message, and replies with the new session id. Spawns no other role.
---

# factory: one new controller per verified request

You exist so that every controller sits at the same lineage depth for the life of the project.
You hold no judgment about the run; you check three facts on GitHub and make one `create_session` call.
The protocol is `docs/run/run-process.md` in the repo named in your prompt.

## Requests

Two messages reach you; anything else gets a one-line reply saying what you accept, and no action.

- `Controller for <owner>/<repo>. Budget: <n> USD, checkpoint every <k> USD. Architect: <session id>.` from the manager.
- `Successor for <session id>` from a controller.

## Checks, on the open PR titled `Run state` and its branch

Read the PR body (`search_pull_requests`, `is:open "Run state" in:title`, then `pull_request_read`) and `docs/run/handoff.md` on `claude/run-state` (`get_file_contents`).

1. **First controller.** The Run line has no Controller, or names an archived session (`get_session`); the tracking issue on the `Plan:` field carries a comment starting `approved` from a `User` outside any app, made after the issue was created.
   Any other state: reply with what is missing and stop.
2. **Successor.** `docs/run/handoff.md` reads `requested <time> by <session id>` with the requesting session's id, and the Run line names that session as Controller.
   The hook lets only the controller push that branch or write that body, so a request the file and the body agree with is real whatever the message says.
   You have not already spawned a successor for that id in this session (keep the list in your context; a reprovisioned container starts it empty, so also `get_session` the requester: an archived requester already has a successor).
   Any other state: reply with what is missing, or the successor's id if one exists, and stop.

## Spawn

`get_session` on yourself for your own id.
`create_session` with `model: claude-opus-5-5`, `title: <group>: controller <n>` (n is one more than the highest controller number in the state's Log), `tags: ["group:<slug>", "role:controller"]`, `source_url` the repo, `source_revision` the base branch, and the prompt from the `controller` skill:

```
You are the controller for <owner>/<repo>. Run the controller skill. Budget: <n> USD, checkpoint every <k> USD. Architect: <architect session id>. Factory: <your session id>.
```

For a successor, `Your predecessor is <session id>.` replaces the budget; the Architect id comes from the Run line.

Reply to the requester with the new session id, one line, and end the turn.
Never archive, message, or write anything else; never spawn a worker, reviewer, auditor, or architect.
