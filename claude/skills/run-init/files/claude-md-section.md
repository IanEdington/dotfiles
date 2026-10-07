## Runs (controller, workers, reviewers)

Long tasks run as a group of cloud sessions (manager, architect, factory, controller, workers, reviewers, auditors); protocol in `docs/run/run-process.md`, lessons in `docs/run/decisions.md`.
A session's role is the first words of its first prompt (`You are the controller for`, `You are a worker in`, and so on); the matching skill or prompt in `docs/run/prompts/` applies.
Hooks in `.claude/hooks/run-guard.mjs` enforce: the check command before every push, no worker merges, controller writes only under `docs/run/`, reviewer, auditor, architect, and factory read-only in the checkout, only the controller updates the `Run state` PR, owner approval on any PR that changes `.claude/`, `docs/run/`, or this file beyond an index line.
