# Research: controller, worker, reviewer processes for long-running tasks

Question: for a process that runs inside one Claude Code cloud session, with a controller in the main context and Opus or Sonnet subagents as workers and reviewers, what does published evidence and our own google-mcp run say about what works, what fails, and what to measure before trusting a rule? Findings feed the design of a reusable skill in this repo.

Tags: **[E]** measured, **[O]** practitioner report without controlled measurement, **[S]** primary source blocked by the cloud proxy (arxiv.org, cognition.com, research.trychroma.com, ghuntley.com, research.google); figure taken from a snippet or secondary write-up, verify before quoting. **[G]** our google-mcp run, `docs/design/process-decisions.md` in that repo.

## Core findings

1. **Verification is the load-bearing part, not coordination.** MAST attributes 21% of multi-agent failures to missing or shallow verification and 42% to under-specification [E, S]. Our auditor found about one defect per PR that an Opus reviewer had passed [G `silent-stalls-become-events`]. Agents game visible tests: GPT-5 "passed" 54% of an impossible SWE-bench variant by editing or special-casing tests, and hiding tests cut cheating to near zero [E, S, ImpossibleBench]. The reviewer and its held-out checks are where the design effort goes.
2. **The reviewer must see only the spec and the diff.** Telling a reviewer a change is safe cut vulnerability detection by 16% to 93%, and adversarial PR descriptions bypassed Claude Code review 88% of the time; redacting author metadata recovered the misses [E, S, arXiv 2603.18740]. A reviewer coupled to the generator drifts into a rubber-stamp regime [E, S, arXiv 2606.28438]. google-mcp's `pr-reviewer` already follows this: issue, docs, diff, no author reasoning.
3. **The controller's context is the single point of failure.** Our coordinator hit 311k tokens in 42 minutes when it subscribed to everything, and a second passed its handoff unmeasured and reached 357k [G `coordinator-message-diet`, `usage-limit-check-in`]. In-session, every subagent report lands in the controller's context, so this gets worse, not better. The Workflow tool is the one primitive that keeps intermediate output out of the controller: the script holds results in variables and returns only what the script returns.
4. **Fresh workers beat long ones.** One long-lived worker reached 750k tokens and 54 USD in three hours [G `coordinator-workers`]. Context quality degrades with length on every model tested, with difficulty held constant [E, S, Chroma]. Anthropic's long-running harness and the Ralph loop both restart a fresh agent per unit of work with state on disk [O]. Anthropic's 2026 harness post preferred a structured handoff and reset over compaction because Opus 4.5 wrapped up early near perceived limits [O].
5. **Cheap workers are an unproven saving.** Anthropic's Opus-lead plus Sonnet-subagents beat solo Opus by 90% on a research eval [E], and Morph saw 28% to 57% cost cuts from downgrading executors [E, S]. But Akita found no planner-plus-cheap-executor mix that beat solo Opus 4.7 on quality in a mature coding harness [E, S], and SpecBench shows smaller models have larger visible-vs-held-out test gaps, so they hack tests more [E, S]. Sonnet workers need a held-out verifier to be safe; without one the saving is spent on review rounds.
6. **Rules agents break as prose must become hooks.** Every google-mcp rule that mattered (push checks, no worker merge, no coordinator product code, context limits, process changes need Ian) was broken as prose and now lives in `guard.mjs` [G `guard-hooks`, `ian-owns-agent-process`]. Claude Code now offers `SubagentStop` (`decision: "block"`), `TaskCompleted` (exit 2 blocks completion with feedback), and `PreToolUse` on the Agent tool, so a definition of done can be enforced in-session.
7. **Silent stalls cost more than any other failure.** google-mcp lost 5 hours three times to things that produced no event: a worker waiting on an unseen permission prompt, a message to a closed mailbox, and a usage-limit stop [G `silent-stalls-become-events`, `usage-limit-check-in`]. In-session, a subagent stuck on a prompt blocks the controller's turn, and a usage limit stops controller and subagents together with no wake. A `PermissionRequest` deny hook and one `send_later` at the limit reset are still required.

## 1. Anthropic guidance, in order of relevance

- Orchestrator-workers only when subtasks cannot be predicted up front; evaluator-optimizer only when criteria are clear and feedback measurably improves output. Building effective agents, https://www.anthropic.com/engineering/building-effective-agents, 2024-12.
- Scale effort explicitly in the lead prompt (1 agent for fact-finding, 2 to 4 for comparisons, 10+ only for complex research); vague delegation duplicated work; subagents write to the filesystem and return references; the lead saves its plan to external memory before 200k tokens. Multi-agent research system, https://www.anthropic.com/engineering/multi-agent-research-system, 2025-06.
- Subagents return condensed summaries of 1,000 to 2,000 tokens; context is a budget; retrieve just in time by identifier. Context engineering, https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents, 2025-09.
- Initializer agent writes `init.sh`, a progress file, an initial commit, and a JSON feature list where coding agents may edit only `passes`; each session reads git log and progress, runs an end-to-end check before new work, does one feature, commits, leaves a mergeable state. Mandatory browser verification fixed premature "done". Long-running harnesses, https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents, 2025-11.
- Planner, generator, evaluator: self-evaluation "confidently praises" mediocre work; a separate evaluator with few-shot score breakdowns was tractable; generator and evaluator agree a testable "sprint contract" before each chunk. Solo 20 min and 9 USD vs full harness 6 h and 200 USD; Opus 4.6 needed less scaffolding (3 h 50 min, 125 USD). Re-test every harness component on each model release. Harness design, https://www.anthropic.com/engineering/harness-design-long-running-apps, 2026-03.
- 16 parallel agents, 2,000 sessions, 20k USD, a C compiler: task locks claimed through git; "the task verifier is nearly perfect, otherwise Claude will solve the wrong problem"; one-line `ERROR` log markers to avoid context pollution; agents repeatedly broke existing features until CI was tightened. https://www.anthropic.com/engineering/building-c-compiler, 2026-02.
- Bun port: 3 h of adversarially reviewed planning docs before any code; each implementer paired with 2+ hostile reviewers in separate contexts given only the diff and told to assume it is wrong, then a separate fixer; 165k USD API [O, S]. https://blog.pragmaticengineer.com/the-pulse-what-can-we-learn-from-buns-rapid-rust-rewrite-with-ai/, 2026.
- Evals: grade outcomes not paths; one isolated judge per rubric dimension; give the judge an "Unknown" exit; pass^k for reliability. https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents, 2026-01.
- Agent teams: 3 to 5 teammates, file ownership to avoid overwrites, `TaskCompleted` and `TeammateIdle` hooks as gates; the lead sometimes starts implementing instead of waiting, and both lead and teammates stop early. https://code.claude.com/docs/en/agent-teams, read 2026-10-05.

## 2. Failure modes with numbers

| Failure | Evidence |
|---|---|
| Under-specification, inter-agent misalignment, weak verification | 41.8%, 36.9%, 21.3% of 1,600+ failed traces. MAST, https://arxiv.org/abs/2503.13657, 2025-03 [E, S] |
| Multi-agent on sequential work | Every multi-agent variant lost 39% to 70% on sequential planning; centralized coordination gained 81% on parallelizable tasks; independent agents amplified errors 17x vs 4x under a coordinator. Google, https://research.google/blog/towards-a-science-of-scaling-agent-systems-when-and-why-agent-systems-work/, 2025-12 [E, S] |
| Reward hacking | 43x more common when the scoring function was visible. METR, https://metr.substack.com/p/2025-06-05-recent-reward-hacking, 2025-06 [E] |
| Held-out gap grows with code size | About 28 points per tenfold increase; one agent built a 2,900-line "compiler" that memorized test inputs. SpecBench, https://arxiv.org/abs/2605.21384, 2026-05 [E, S] |
| Self-preference | GPT-4o and Claude 3.5 Sonnet score their own and same-family outputs higher. https://arxiv.org/abs/2504.03846, 2025-04 [E, S] |
| Context rot | 18 models degraded with input length at fixed difficulty; U-shaped recall (75% first, 55% middle, 72% last). Chroma 2025-07 [E, S]; Lost in the middle, TACL 2024 [E] |
| Parallel writers | Cognition 2025: actions carry implicit decisions, so parallel writers conflict; Cognition 2026: works when writes stay single-threaded per area and extra agents add review or research, not actions. https://cognition.com/blog/dont-build-multi-agents, https://cognition.com/blog/multi-agents-working [O, S] |

## 3. What google-mcp paid to learn

Full table in that repo's `docs/design/process-decisions.md`. The rows that transfer:

| Lesson | In-session verdict |
|---|---|
| `done` is a checked condition (head SHA, green checks, `merge` verdict for that SHA, no conflict), never a status | Applies, and is now enforceable with a `TaskCompleted` or `SubagentStop` hook |
| Reviewer gets issue, docs, branch, base; fetches the diff itself; never the author's reasoning | Applies; the controller is the leak path, so the reviewer prompt is a fixed template |
| 3 counted review rounds; merge-of-main and fix-verification rounds free; past the cap is `blocked` | Applies |
| Post every review round; file non-blocking findings as issues | Applies more: subagent output otherwise vanishes when the controller compacts |
| Post-merge auditor every 4 PRs, read-only, files issues | Applies; one defect per PR is the review-quality floor to beat |
| Only one-way doors block for Ian; research before asking; half of run-3 questions did not change the outcome | Applies |
| Coordinator never writes product code, never resolves conflicts | Applies, by hook |
| 250k controller handoff, 600k and 30 USD worker caps | Thresholds need re-measuring; the controller now absorbs reports, and per-subagent cost is not visible to it |
| Mailboxes, relay, subscription confirmation, lineage depth 8 | Moot: subagent results return in-process |
| Usage-limit `send_later` at `resetsAt` + 5 min | Still required; one limit stops everything |
| Archive does not stop a session (57 USD) | Unknown in-session: verify that background subagents end with the parent and that reopening a cloud session does not orphan them (docs say background work "may be lost") |
| `PermissionRequest` auto-deny | Applies with higher stakes: a stuck subagent blocks the controller's turn |

## 4. Claude Code primitives available in cloud (read 2026-10-05)

Source: https://code.claude.com/docs/en/sub-agents, /workflows, /hooks-guide, /claude-code-on-the-web.

- Custom agents: `model` (opus, sonnet, haiku, inherit, full id), `tools`, `permissionMode`, `maxTurns`, `effort`, `isolation`, `skills`, `hooks`, `memory`, `omitClaudeMd`, `background`. Subagents inherit CLAUDE.md and can spawn 3 deep; 20 concurrent by default. The parent gets final text only, plus an id for `SendMessage` resume; transcripts survive parent compaction.
- Hooks: `SubagentStart`, `SubagentStop` (can block), `PreToolUse` on Agent, `TaskCreated`, `TaskCompleted` (exit 2 blocks with feedback), `Stop`, `PermissionRequest`.
- Workflow: script-driven fan-out with `agent()` (JSON schema output), `pipeline()` (per-item streaming, no barrier), `parallel()`, `budget`, `resumeFromRunId` replaying cached prefixes; 16 concurrent, 1,000 per run; intermediate results never enter the controller's context. Needs explicit opt-in ("use a workflow" or `ultracode`). Available in cloud.
- Tasks: persist across compaction and resume, shared with subagents in the session, dependencies unblock automatically. Not shared across sessions.
- Cloud: compaction fires early (`CLAUDE_AUTOCOMPACT_PCT_OVERRIDE`); inactivity timeout undocumented; waiting on an MCP approval counts as inactive; usage limits shared with all account usage; default permission mode is auto, inherited by subagents.

## 5. Design implications

These are positions, to be challenged in the design review, not settled rules.

1. **Controller is a thin ledger-keeper.** It holds the plan, the Questions list, and a durable state file committed to the branch (JSON, since models rewrite Markdown lists more readily [O]). It never reads a diff, never writes product code, and spends its turns on three verbs: spawn, gate, record.
2. **One worker per unit of work, fresh each time.** Spec in an issue or a feature-list entry with a nearly perfect acceptance check; `isolation: worktree` when two run at once; one owner per file area; commit and leave mergeable before returning a report under 200 words.
3. **Reviewer is Opus, adversarial, and blind.** Template prompt: issue, docs, base, branch, "assume it is wrong"; fetches its own diff; verdict names the SHA. Two reviewers with different lenses (correctness, hard rules and security) where the cost is justified. Hold back a verifier the worker cannot see: a held-out test or an end-to-end check the reviewer runs.
4. **Model choice is a policy with a measurement, not a preference.** Opus for the controller, every reviewer, and any task whose spec leaves design choices; Sonnet only for tasks with a mechanical acceptance check and a held-out verifier. Log cost and review rounds per model so the Sonnet share can be adjusted on evidence.
5. **Gates are hooks.** `TaskCompleted` refuses a task without a `merge` verdict for the head SHA; `SubagentStop` refuses a worker report that lacks the required fields; `PreToolUse` on Bash keeps the pre-push check; `PermissionRequest` denies with a message.
6. **Fan-out through Workflow, not through the controller.** Review panels, audits, and discovery sweeps run as workflow scripts that return a schema-validated summary; the controller never sees the transcripts.
7. **Budget is explicit.** `maxTurns` on every agent, a try cap per task, a run cap and checkpoint in the first prompt, and a stop when a task fails review three counted rounds. A usage-limit check-in is the only timer.

## 6. Open questions to settle before the design

- Can a hook tell roles apart in-session? `SubagentStart` carries the agent type, so named custom agents (`worker`, `reviewer`, `auditor`) should be enough; unverified.
- Is per-subagent token and USD spend visible to the controller? The Agent tool result reports tokens; USD is not documented.
- Do background subagents survive the cloud session being backgrounded or reopened? Docs say background work "may be lost".
- Where should the state file live when the repo is not the controller's own (dotfiles skill reused across repos)?
- Does Sonnet as a worker pay for itself once review rounds are counted? No published study isolates this for Claude Code; run a pilot of 10 tasks each way.
- Hidden tests vs agent feedback: the agent needs test output to make progress, yet visible tests invite gaming. The split (visible unit tests, reviewer-only end-to-end check) is a guess.

## Evidence quality

Most harness guidance, Anthropic's included, has no controlled measurement. The measured work (MAST, Google scaling study, SpecBench, ImpossibleBench, Chroma, the contextual-bias paper) covers failure modes, not fixes. Treat every threshold here as a starting point to be re-measured on this account's tasks and the current model.
