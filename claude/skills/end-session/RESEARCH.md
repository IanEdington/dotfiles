# What makes a good end-of-session skill

Research notes, 2026-09-05. Sources: 32 public end-session and handoff skills read directly or catalogued, Anthropic's docs and engineering posts, agent-memory papers, and human handoff literature (medicine, aviation, SRE).

## Three outputs, three lifetimes

Every mature design converges on the same split. Mixing them is the most common structural mistake.

| Output | Lifetime | Written how | Read by |
|---|---|---|---|
| Handoff (job state) | Until the next session consumes it | Overwritten, regenerated from git and test output | Next session, cold |
| Durable facts (memory) | Until superseded | Edited in place, timestamped, capped | Every session at start |
| Procedures | Indefinite | Skills, not prose in memory | On demand |

Sources: Hermes checklist, Claude Code auto memory types, Cline memory bank, haacked's `/handoff` vs `/note` vs plan boundary table.

## The handoff is state, not history

Git holds the history. The handoff holds what git cannot: goal, current state, what is verified and how, what is not verified, decisions and what was ruled out, assumptions, standing constraints, and one concrete next action.

Rules that recur across the strongest examples:

- **Regenerate from ground truth.** Run `git status`, `git diff --stat`, and the test command before writing. haacked: "Memory produces narrative; state produces handoffs." Summarizing the previous handoff compounds drift (SSGM paper on iterative summarization).
- **Pointers over prose.** `file.ts:42`, PR URLs, plan paths. Never inline a diff or plan. groundwork: "a baton, not a backpack." Manus: drop the page, keep the URL.
- **Decisions over events.** Record what was chosen, why, and what was ruled out. Cognition: "Actions carry implicit decisions, and conflicting decisions carry bad results."
- **Failed approaches are the most valuable section.** Named as such by three independent authors. Manus: "Erasing failure removes evidence."
- **Next action is file-and-command specific.** "Continue the refactor" is wrong. "Edit `foo.ts:42` to handle the null case, then run `pnpm test bar.spec.ts`" is right.
- **Contingency, not just plan.** I-PASS "situation awareness": if X fails, the likely cause is Y. Absent from nearly every public skill.
- **Standing constraints verbatim.** Compactors retain only 17% of side constraints on average (arXiv 2608.11242). User rules stated mid-conversation must be copied, not summarized.
- **Verification status is the most important field.** Hermes: "The biggest failure mode in long AI-agent work is not that the model forgets one fact. It is that nobody can tell which facts are verified." Record the command and its output, not the claim.
- **One page.** Chroma context-rot data: every model degrades with length. Caps in public skills range from 300 tokens to 2000 words. haacked: past one page, "the doc is wrong: split the work smaller or commit in-progress state to a branch."

Deliberately excluded: diff dumps, session narrative, re-explanation of readable code, speculation about future phases.

## Confidence audits: what the evidence says

Asking the model how confident it is does not work. Asking it to find bugs does.

- Agents that succeed 22% of the time predict 77% success; post-execution self-assessment is worse calibrated than pre-execution; "adversarial prompting reframing assessment as bug-finding achieves the best calibration" (arXiv 2602.06948).
- RLHF pushes verbalized confidence upward regardless of correctness (arXiv 2604.01457, TrustNLP 2024).
- Anthropic best practices: "A reviewer prompted to find gaps will usually report some, even when the work is sound." Scope the hunt to correctness and stated requirements.
- Known-unknowns listing is the one human debiasing technique with direct evidence of reducing overconfidence (Walters et al., Management Science 2017).
- Pre-mortem framing ("assume the next session finds this was wrong; why?") raised correct reason identification by 30% (Mitchell, Russo, Pennington 1989).

Design consequence: replace numeric confidence with evidence classes (ran and observed / inferred / assumed), run a scoped bug hunt, and list known unknowns. Pocock's skill is the only public example with any accuracy gate ("downgrade unverified claims before handoff").

## Lessons: the poisoning problem

Free-form reflection stores wrong beliefs at high rates. In one study 0 of 121 self-generated reflections named the correct cause; replacing open-ended self-diagnosis with programmatic failure signals raised it to 86% (arXiv 2605.29463, "Honest Lying"). Memory injection attacks succeed over 95% of the time through query-only access (MINJA, arXiv 2601.05504).

What the careful designs do:

- **A lesson needs a concrete trigger.** Error text, failing command, or a user correction. No trigger, no lesson.
- **Propose, then approve.** Every learning-extraction tool surveyed defaults to human review (ECC `auto_approve:false`, developersdigest confidence levels, bpg `/done` presents learnings and waits).
- **Lessons learned from untrusted content** (web pages, PR comments, tool output) never persist without confirmation.
- **Skip the derivable.** Claude Code auto memory "skips anything it can derive from the codebase" and "anything your CLAUDE.md files already say." One-offs, typos, and external API blips are excluded (ECC).
- **Update, do not append.** Letta memory blocks re-evaluate and replace. ADRs supersede visibly rather than silently edit, so a wrong lesson has a visible retraction.
- **Keep CLAUDE.md for day-one facts.** Most public skills never touch it. Docs: target under 200 lines; bloated files cause Claude to "ignore your actual instructions." The test per line: "Would removing this cause Claude to make mistakes?"
- **Cap and prune.** Reflexion uses a sliding window of 3. Generative Agents reflect only when importance crosses a threshold, roughly two or three times per day. MEMORY.md silently truncates at 200 lines or 25 KB.

## Staleness guards

The public field is stronger here than on audits.

- Date, branch, and HEAD stamped into the doc (haacked snapshot block; mer.vin filename convention plus a `status: active|blocked|done|stale` field).
- Resume reconciles: same branch and HEAD is fresh; HEAD moved means warn and show `git log <doc-head>..HEAD`; different branch means reference-only mode.
- who96 refuses to restore a handoff older than 900 seconds or from a different cwd.
- heyitworks deletes `HANDOVER.md` on consumption. haacked archives on resume, default yes, because "a stale doc on disk encourages re-loading outdated state."
- Cline critique: the most frequently updated files (`activeContext.md`, `progress.md`) drift fastest. Timestamp every entry; the `modified` frontmatter field in auto memory is the precedent.

## Honesty mechanisms worth stealing

- **Rationalized-failures scan** (navapbc): grep the conversation for "pre-existing", "infrastructure issue", "known issue", "not related"; for each, stash and re-run on the baseline to determine whether the failure predates this session's changes.
- **Calibration anchor** (navapbc): "If the agent spent non-trivial time debugging, hit an unexpected error, or applied a workaround, that learning qualifies. Do NOT skip a learning that caused real debugging cost just because it has since been understood."
- **Invented progress is the cardinal sin** (jellyrock): status verified against `git log`, never aspirational. Anthropic harness post: "declaring victory prematurely" is the named failure; mark complete "only after end-to-end verification."
- **Uncommitted-items honesty signal** (xp-agents): surface the count of open concerns newer than the last commit, verbatim.
- **Verify remote state** (bpg): check PR state and merge status on GitHub rather than trusting the conversation's claim of "merged."
- **Closed loop on resume** (I-PASS synthesis, on-call practice): the next session restates the handoff and re-runs the verification before acting.

## Git and workspace hygiene

- Shared working tree footgun (jellyrock): a parallel agent can switch branch or stage files under you. Verify branch, commit by explicit pathspec, re-check branch after.
- Cleanup (chroxy): stop daemons started this session, remove only this session's worktrees, prune branches only after confirming a `MERGED` PR.
- Cloud sessions: the VM is reclaimed after inactivity, uncommitted work is not documented as restored, and auto memory written in the cloud is machine-local. Only pushed branches survive. A wrap-up in a cloud session must push or explicitly say what is unpushed.
- Redaction: strip secrets and PII; reference the env var name or secret manager path, never the value (groundwork, hex, Pocock).

## Platform constraints that shape the design

- `SessionEnd` hooks cannot run a model, have a 1.5 s default budget, and fire on `/clear` and `/resume` too. A model-written handoff must be a skill, invoked by the user or nudged by a `Stop` hook. Anthropic closed the request for a model-driven pre-compaction write as not planned.
- `Stop` fires after every turn, so wrap-up logic there runs constantly. Skill frontmatter `hooks:` with `once: true` lets a skill register its own hook at invocation.
- `PreCompact` can snapshot or block but cannot add context to the summary. Re-injection after compaction is a `SessionStart` hook with `matcher: "compact"`.
- Invoked SKILL.md enters as one message and is not re-read. `context: fork` gives the body no conversation history, which makes it wrong for a skill that must inspect the session.
- Skill `description` is truncated at 1,536 characters in the listing; Claude undertriggers, so trigger phrases belong in the description and the key use case goes first.
- Cloud sessions do not load `~/.claude/skills/`. A user-level end-session skill needs to be synced through claude.ai or committed to the repo.
- Auto memory topic files load on demand; only `MEMORY.md` (200 lines or 25 KB) loads every session.

## Design tensions, with a position on each

| Tension | Position |
|---|---|
| Automatic vs manual | Skill for the narrative, hook only for a deterministic snapshot. Hooks are reliable but cannot think; skills think but need invoking. |
| Length vs fidelity | Hard cap, one page. Length competes for the context it is meant to preserve. |
| Where to persist | Repo-scoped and gitignored for handoff; auto memory for facts. Root-level `HANDOFF.md` pollutes git and gets trusted when stale. |
| Overwrite vs append | Overwrite the handoff. Append only to an index with pruning. |
| Lessons in CLAUDE.md vs sidecar | Sidecar with approval. CLAUDE.md is for rules that prevent a repeated mistake, not for observations. |
| Report vs act | Report git state; act only on cleanup that is clearly this session's. Push in cloud sessions. |
| Ask the user vs decide | Ask once for lesson approval and for anything the model cannot verify. Do not ask a status question every session (jellyrock: "friction that erodes the skill"). |

## Recurring skeleton

Present in nearly every example, in this order:

1. Gather state actively: branch, status, recent commits, stash, test result, PR state.
2. Extract from conversation: goal, done, decisions with rationale, failed approaches, open items, constraints.
3. Audit: bug hunt scoped to correctness, known unknowns, rationalized failures.
4. Write the handoff to a fixed template, one page, next action last or first.
5. Propose lessons with triggers; persist only on approval; supersede rather than append.
6. Workspace hygiene: commit by pathspec, push if cloud, stop daemons, redact.
7. Report in one line: path written, next action, what is unpushed or unverified.

## Sources

Public skills read in full: haacked/dotfiles `handoff`, sammcj/agentic-coding `handoff` (Pocock), paulingalls/xp-agents `xp-end-session`, navapbc/digital-service-orchestra `end-session`, REMvisual/claude-handoff, bpg/terraform-provider-proxmox `/done`, blamechris/chroxy `session-lifecycle`, etr/groundwork `handoff`, robertguss/claude-code-toolkit `handoff`, xajik/tasksquad `tsq-end-session-memory`, jellyrock/jellyrock `end-session`, alxyrgin/agent-forge `end-session`.

Catalogued from surveys: thenguyenvn90, NotThatRob, ao92265 playbook, sidorovanthon/handoff-prompt, thepushkarp/handoff, who96, Sonovore, hex/claude-sessions, qdhenry Claude-Command-Suite, tech1ee/claude-checkpoint, iannuttall/claude-sessions, edwilde gist, heyitworks Claude-Handover, accidentalrebel session-retrospective, affaan-m/ECC continuous-learning, claude-mem, developersdigest `/reflect`, ArtemXTech, obra/superpowers `finishing-a-development-branch`.

Anthropic: https://code.claude.com/docs/en/memory, https://code.claude.com/docs/en/hooks, https://code.claude.com/docs/en/context-window, https://code.claude.com/docs/en/skills, https://code.claude.com/docs/en/best-practices, https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents, https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents, https://platform.claude.com/docs/en/agents-and-tools/tool-use/memory-tool.

Papers: arXiv 2602.06948 (agentic overconfidence), 2604.01457 (verbalized confidence), 2605.29463 (memory confabulation), 2601.05504 (MINJA), 2603.11768 (SSGM), 2608.11242 (side-constraint loss in compaction), 2303.11366 (Reflexion), 2304.03442 (Generative Agents), 2305.16291 (Voyager). Chroma context rot: https://www.trychroma.com/research/context-rot.

Human handoffs: I-PASS (NEJM 2014, 23% fewer medical errors across 10,740 admissions, bundled with training), Patterson et al. 2004 high-consequence handoffs, Google SRE incident management, incident.io on-call guide, HBR pre-mortem, Walters et al. 2017 known unknowns. Other: Manus context engineering, Cognition "Don't build multi-agents", Letta memory blocks, Cline memory bank, Hermes handoff checklist.

Unverified: Voyager self-verification false-approval rate, DeepSWE 18% no-test submissions, cloud idle expiry duration, whether cloud auto memory ever syncs back.

## Gap analysis against the current skill

Read after the research above was written. `SKILL.md` at 137 lines, iteration 2.

### Already ahead of the field

- Verify state immediately before the report. Empirically load-bearing in iteration 1, and no public skill states it this sharply.
- Report, never act. Matches the consensus and prevents the baseline's auto-commit behaviour.
- Lessons gated hard, CLAUDE.md as proposal only, "day one developer" filter. Matches Anthropic's per-line test.
- Handoff carries decision rationale, a verification command, rot-overnight flags, a date and git ref stamp, and a `## Pick up here` anchor. Only three public skills have a verification command at all.
- Scale-to-session rule and "never fabricate activity" address the invented-progress failure directly.
- The two questions have no public equivalent.

### Gaps, ranked by expected payoff

1. **Question 1 uses the worst-calibrated elicitation.** Post-execution "how confident are you" is less calibrated than a bug hunt (arXiv 2602.06948). The current wording already demands specificity, which helps, but the framing is still self-rating. Reframe as a pre-mortem: "Assume the next session discovers this work was wrong. What broke, and which claim in this report was it hiding behind?" Keep the specificity bar. Add a known-unknowns line: what was never checked, stated as a list, not a feeling.
2. **No evidence classes on claims.** "What happened" reports outcomes without saying which were observed, inferred, or assumed. Hermes: the failure is that "nobody can tell which facts are verified." Tag each outcome: ran and saw output / inferred from code or docs / assumed. This also gives Question 1 its raw material.
3. **No rationalized-failures scan.** Nothing catches a failure that was waved off mid-session as "pre-existing", "flaky", or "unrelated". navapbc greps the conversation for those phrases and re-runs on a stashed baseline. Cheap to add as a Step 1 item; it is a state check, not prose.
4. **Standing constraints are not captured.** Rules the user stated mid-session ("don't touch the migration", "no em-dashes in this doc") survive compaction 17% of the time. The handoff should copy them verbatim under their own heading.
5. **Lessons lack a trigger requirement and a dedup step.** Free-form reflection stores wrong causes at high rates. Require every lesson to cite its trigger (the correction, the error text, the command that failed). Read the existing CLAUDE.md and auto memory index before proposing, so a lesson is not a duplicate or a contradiction (docs: contradictory rules get picked arbitrarily). Scoped edits are currently applied without approval; lessons derived from untrusted content (web pages, PR comments, tool output) should be proposal-only regardless of scope.
6. **Cloud sessions break "report, never act".** When the VM is reclaimed, unpushed commits and the working tree are gone, and auto memory written there is machine-local. The skill should detect a cloud session and either push to the session branch (already permitted by the global CLAUDE.md) or state in one line exactly what will be lost. Also: a chat-only handoff in a cloud session dies with the tab. Write the file.
7. **No length cap or pointers-over-prose rule for the handoff.** "Briefly" is not a cap. State one page, `file:line` over paraphrase, no diff or plan bodies, and link PRs and issues. Add a redaction line: never echo a secret value, name the env var.
8. **Failed approaches are folded into decisions.** "Alternatives rejected" covers design choices. Debugging dead ends (things tried that did not work, and why) are a separate list and are the section three authors call most valuable.
9. **No contingency.** I-PASS style: "if the verification command fails, the likely cause is X." One line per open thread.
10. **Question 2 has no escape valve.** Question 1 allows "name the strongest remaining assumption"; Question 2 says nothing about the case where the honest answer is small. Anthropic: a reviewer prompted to find gaps will report some even when the work is sound. Permit "nothing material; the closest is X" so the answer stays honest.
11. **The skill's own HANDOFF.md is stale.** Written 2026-08-05 against a PR that has since merged, sitting next to the skill. This is the staleness failure the research warns about. Either delete it or move session handoffs out of the skill directory and give them an explicit archive-on-read rule.

### Eval gaps

Current assertions test the two questions, git honesty, and handoff presence. None test: constraint capture, rationalized-failure detection, lesson trigger citation, secret redaction, handoff length, or cloud-session behaviour. Variance is unmeasured at one run per configuration; the baseline is closing the gap on blind spots, so new assertions should target the items above, where baselines have no reason to comply.

### Not recommended

- A `Stop` or `SessionEnd` hook to force the wrap-up. `SessionEnd` cannot run a model; `Stop` fires every turn. Keep this a skill.
- Moving lessons into CLAUDE.md automatically. Every tool surveyed that tried it added human approval back.
- A start-session counterpart with HEAD reconciliation. Useful, but the ref stamp already lets the next session do it manually; build it only if handoffs are being written to files often enough to go stale.
