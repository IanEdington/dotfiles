---
last-reviewed: TODAY
review-interval-days: 180
---

# Run process decision log

Append-only: add a row at the bottom and never edit an existing one. One line per row so concurrent appends merge. The id is a short kebab-case name; cite it as decision `name`. A decision that replaces another says "Supersedes `name`". The first rows carry lessons inherited from the google-mcp coordinated runs (its `docs/design/process-decisions.md`), so this repo does not pay for them again.

| Id | Decision | Why | Alternatives rejected |
|---|---|---|---|
| `fresh-worker-per-issue` | One issue per worker; a worker's result returns in-process and the worker is not reused across issues | A long-lived worker reached 750k tokens and 54 USD in three hours; context quality falls with length on every model measured | Long-lived workers, reuse by area |
| `controller-reads-no-diffs` | The controller reads head SHA, check runs, and the reviewer's verdict line; never a diff, file list, or review thread | A coordinator that watched everything reached 311k tokens in 42 minutes; in-session every report lands in the controller's context | Controller reviews, controller watches work PRs |
| `controller-spawns-reviewer` | The controller, not the worker, spawns the reviewer with a fixed prompt, and receives the verdict directly | Author framing cut reviewer detection by 16% to 93% in a 2026 study; a worker-spawned reviewer sees the worker's narrative and the worker relays its verdict | Worker spawns and relays review |
| `holdout-on-state-branch` | Each issue has a held-out check on `claude/run-state` that only the reviewer runs; workers branch from the base and never read it | Agents pass visible tests by editing or special-casing them; hiding tests cut cheating to near zero (ImpossibleBench) | Visible-only acceptance, no verifier |
| `done-means-mergeable` | The controller merges only on green checks, a `merge` verdict for the head SHA, no conflict, closed dependencies, no open one-way door | Two PRs arrived as done without a head verdict or against a hard rule and cost a fresh worker each to recover | Done as a worker status |
| `rules-are-hooks` | Pre-push check, no worker merge, controller writes only `docs/run/`, reviewer and auditor read-only, permission prompts denied, process PRs need the owner: all hooks | Every one of these was broken while it was prose | Prose rules |
| `owner-owns-process` | A PR touching `.claude/`, `docs/run/`, or non-index `CLAUDE.md` merges only when the owner merges it or comments approval after its last commit; the hook checks GitHub | Every session posts as the owner, so a comment made outside the Claude app is the one signal an agent cannot forge | Required review (blocks the owner too), approval label (agents can add it) |
| `reversible-never-blocks` | Only one-way doors stop work for the owner; other choices are taken, recorded, and routed to the Questions list or an `owner-review` issue | About half of one run's questions did not change the outcome | Ask on every departure |
| `three-counted-rounds` | Three review rounds per issue; base-merge and fix-verification rounds do not count; past the cap is `blocked` | Two PRs needed a fourth round only to verify a base merge | Hard cap of three |
| `post-merge-audit` | An auditor every 4 merged PRs files real defects as `audit` issues | An independent audit found about one defect per PR that review had passed | Audit before merge (holds the flow) |
| `controller-lineage` | A controller hands off in one turn at 250k tokens once no worker is mid-turn, or at 300k regardless: write state, delete the check-in, spawn a successor one lineage level deeper, archive itself; at depth 7 it asks the owner for a new line | The platform refuses `create_session` and `send_later` at depth 8; predecessors that waited for an acknowledgement never woke and ran on; background subagents die with their session, so handing off between turns wastes nothing | The owner restarting after every controller (a manual step per 250k tokens), successor archiving the predecessor (its last turn is invisible to it) |
| `one-timer-only` | The controller's `send_later` at the usage-limit reset is the only timer; nothing else polls | The five-hour limit stopped every session with no wake until the owner noticed; a worker that self-scheduled wasted turns | Hourly check-ins, worker timers |
