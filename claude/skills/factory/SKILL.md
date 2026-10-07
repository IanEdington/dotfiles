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

- `Controller for <owner>/<repo>. Budget: <n>M tokens, checkpoint every <k>M.` from the manager.
- `Successor for <session id>` from a controller.

## Checks, all on the open PR titled `Run state`

Read its body (`search_pull_requests`, `is:open "Run state" in:title`, then `pull_request_read`).

1. **First controller.** The Run line has no Controller, or names an archived session (`get_session`); the tracking issue on the `Plan:` field carries a comment starting `approved` from a `User` outside any app.
   Any other state: reply with what is missing and stop.
2. **Successor.** The Run line names the requesting session as Controller and carries `Handoff: requested <time>`; `list_sessions` with tag `predecessor:<session id>` returns nothing unarchived.
   The hook lets only the controller update that PR, so a request that matches the body is real whatever the message says.
   Any other state: reply with what is missing and stop.

## Spawn

`create_session` with `model: claude-opus-5-5`, `title: <group>: controller <n>` (n is one more than the highest controller number in the state's Log), `tags: ["group:<slug>", "role:controller", "predecessor:<session id or none>"]`, `source_url` the repo, `source_revision` the base branch, and the prompt from the `controller` skill:

```
You are the controller for <owner>/<repo>. Run the controller skill. Budget: <n>M tokens, checkpoint every <k>M.
```

or, for a successor, with `Your predecessor is <session id>.` in place of the budget.

Reply to the requester with the new session id, one line, and end the turn.
Never archive, message, or write anything else; never spawn a worker, reviewer, auditor, or architect.
