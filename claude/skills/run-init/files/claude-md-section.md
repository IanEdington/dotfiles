## Runs (controller, workers, reviewers)

Long tasks run as a controller session with Opus subagents; protocol in `docs/run/run-process.md`, lessons in `docs/run/decisions.md`.
A session whose first message starts with `You are the controller for` runs the `controller` skill.
Hooks in `.claude/hooks/run-guard.mjs` enforce: the check command before every push, no worker merges, controller writes only under `docs/run/`, reviewer and auditor read-only, owner approval on any PR that changes `.claude/`, `docs/run/`, or this file beyond an index line.
