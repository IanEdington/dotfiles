# Existing test-writing guidance for coding agents

**Question.** What test-writing guidance already exists for coding agents (Anthropic docs and built-ins, community skills and agents, Cursor and AGENTS.md conventions, harness behaviour, hooks), what does it tell the model to do, and is any of it measured? The reader is deciding whether to write a new Claude Code test-writing skill, extend a review agent, or adopt an existing skill. Research date 2026-10-07. Tags: **[E]** measured, **[O]** opinion or vendor guidance without measurement, **[S]** primary source blocked, quote from a secondary source.

## Core findings

1. **[O] Anthropic's guidance treats tests as a verification signal, not as a craft.** The current [best-practices page](https://code.claude.com/docs/en/best-practices) has a section "Give Claude a way to verify its work" and only three test-specific instructions: "avoid mocks", "write a failing test that reproduces the issue, then fix it", and a Writer/Reviewer split ("have one Claude write tests, then another write code to pass them"). It warns that chasing every reviewer finding yields "tests for cases that can't happen". The older "write tests, commit; code, iterate, commit" and "avoid mock implementations" passages are no longer on that page. **[S]** I could not fetch the original 2025 post (archive blocked); the TDD wording I saw came from search-result summaries, not the post.

2. **[O] The built-in code review deliberately ignores test quality.** `anthropics/claude-code` `plugins/code-review/commands/code-review.md` lists as false positives "General code quality concerns (e.g., lack of test coverage, general security issues) unless explicitly required in CLAUDE.md". Extending that command to judge tests would contradict its high-signal design. The built-in `security-review` text was not retrievable (raw GitHub 404), so unverified.

3. **[E] Agent-written tests are weaker than their pass/fail status suggests.** [SWE Atlas](https://arxiv.org/html/2605.08366v1) test-writing: frontier models pass mutation checks about 40 to 45% of the time, and 10 to 15 points less on a rigour rubric; agents often write assertions that pass on mutated code. [SWE-Mutation](https://arxiv.org/abs/2605.22175): 36.15% detection for the best of seven LLMs; realistic mutants cut detection from 71.04% to 39.81%. [Over-mocking study](https://arxiv.org/abs/2602.00409): 36% of agent commits add mocks versus 26% for non-agents. [Rethinking agent-generated tests](https://arxiv.org/html/2602.07900v2): Claude Opus 4.5 writes tests in 83% of tasks, GPT-5.2 in 0.6%, resolution 74.4% versus 71.8%, no significant outcome change when prompts push test-writing up or down, and prints outnumber assertions (25 to 5.16). Counter-evidence: [a Django and pandas study](https://arxiv.org/abs/2608.15188) (abstract only read) finds Sonnet and Opus 4.6+ tests non-inferior to human-written ones on three fault-injection protocols. Baseline quality differs by model generation, which matters for any skill's expected lift.

4. **[E, weak] The only with/without measurements are small and conflict.** [mavka-ai/unit-tests-skills](https://github.com/mavka-ai/unit-tests-skills): one Spring Petclinic target, 12 injected mutants, Claude killed 5 without the skill and 10 with it (Codex 5 and 11); single run, authors' own benchmark, all suites at 100% branch coverage. A [placebo-controlled benchmark on dev.to](https://dev.to/sjh9714/i-benchmarked-claude-code-skills-against-a-placebo-and-half-of-mine-failed-4okk) (496 runs, hold-out tests) found its "tests-that-bite" skill failed the gate because baseline Opus already killed every mutant on 3 of 4 tasks. [Vercel's eval](https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) is the template but not about tests: skill default 53% (equal to baseline), skill with explicit instruction 79%, AGENTS.md index 100%, skill never invoked in 56% of cases. Trigger reliability can dominate content quality.

5. **[O] Procedure dominates; judgment is rare.** wshobson `test-automator` and VoltAgent `test-automator` and `qa-expert` are capability catalogues ("Self-healing test automation with tools like Testsigma", "Test coverage > 90% achieved", "Flaky tests < 1%"); they never say what not to test. wshobson mentions "mutation testing" as a capability, not a step. Superpowers' TDD skill is strict procedure plus rationalization defences. Two artifacts do encode judgment: Superpowers' newer `writing-good-tests.md` and `adewale/testing-best-practices`.

6. **[E] Repos mostly give agents commands, not taste.** [Ardic, Olsthoorn, Zaidman](https://azaidman.github.io/publications/ardicSCAM2026.pdf), 300 repos with agent guidance files: test commands 249 (83%), test strategy 156 (52%), mentality 144 (48%), coverage 71 (23.7%), avoidance 57 (19%), mocking 52 (17.3%), concrete example tests 39 (13%). Their conclusion: files "expose testing infrastructure" but rarely make expectations about good tests explicit. [Gloaguen et al.](https://arxiv.org/abs/2602.11988) find context files do not generally improve success and add over 20% inference cost. The best large-repo test sections I found are Anthropic's own SDK `CLAUDE.md` files (quoted below). Next.js, Supabase, and Cloudflare `AGENTS.md` files say almost only how to run tests and where helpers live.

7. **[O] Hooks enforce procedure, never quality.** Stop hooks that run the suite and block on failure are common (see inventory); Claude Code supports blocking via exit code 2 or `decision: "block"` on `Stop` and `TaskCompleted`. [TDD Guard](https://github.com/nizos/tdd-guard) blocks implementation edits without a failing test using an LLM validator with rules like "Only one test at a time" and "must fail for the RIGHT reason". No measurement of any hook's effect on test quality was found. Hooks cannot judge whether the failing test is worth having.

8. **[O] Harnesses run tests; none grade the tests agents write.** Aider: `--test-cmd` with `--auto-test`, retries on non-zero exit. SWE-agent default prompt: "Create a script to reproduce the error", rerun it, "Think about edgecases", then delete the script and revert any test files. Copilot coding agent: instructions describe how to "build, test and validate". SWE-bench-style grading uses hidden tests, so test quality is never scored. Devin and OpenHands: no primary guidance retrieved.

## Inventory

| Artifact | Type | What it instructs | Judgment on what to test? | Measured? | Link |
|---|---|---|---|---|---|
| Claude Code best practices | doc | Give a runnable check; avoid mocks; failing repro test | partly | no | [link](https://code.claude.com/docs/en/best-practices) |
| code-review plugin | skill | Do not flag missing coverage | yes (negative) | no | [link](https://raw.githubusercontent.com/anthropics/claude-code/main/plugins/code-review/commands/code-review.md) |
| anthropics/skills `webapp-testing` | skill | Playwright scripts, server helper, recon-then-act | no (tooling) | no | [link](https://github.com/anthropics/skills/tree/main/skills/webapp-testing) |
| Superpowers `test-driven-development` | skill | Iron law: no production code without a failing test; verify red; delete code written first | no (procedure) | no (pressure-tested by subagents, [author's account](https://blog.fsck.com/2025/10/09/superpowers/)) | [link](https://github.com/obra/superpowers/blob/main/skills/test-driven-development/SKILL.md) |
| Superpowers `writing-good-tests.md` | skill reference | Name the break; no mirror assertions; no change detectors; mutation check | yes | no | [link](https://github.com/obra/superpowers/blob/main/skills/test-driven-development/writing-good-tests.md) |
| Superpowers `verification-before-completion` | skill | No success claim without fresh command output; regression test must be seen failing | partly | no | [link](https://github.com/obra/superpowers/blob/main/skills/verification-before-completion/SKILL.md) |
| adewale/testing-best-practices | skill | Four modes; risk boundary; calibrate to lifetime; red evidence versus green evidence | yes | partly [E]: 44 ablation runs, mutation-seeded oracles, author's own | [link](https://github.com/adewale/testing-best-practices) |
| mavka-ai/unit-tests-skills | skill | Branch-based INCLUDE/EXCLUDE criteria, Given-When-Then (Java) | partly | yes [E], single run | [link](https://github.com/mavka-ai/unit-tests-skills) |
| wshobson `test-automator`, `tdd-orchestrator` | agent | Capability lists; TDD cycle metrics | no | no | [link](https://github.com/wshobson/agents) |
| VoltAgent `test-automator`, `qa-expert` | agent | Checklists with coverage and flake targets | no | no | [link](https://github.com/VoltAgent/awesome-claude-code-subagents) |
| FlorianBruniaux `test-writer` | agent | Plan happy path, edge, error, integration; AAA | no | no | [link](https://github.com/FlorianBruniaux/claude-code-ultimate-guide/blob/main/examples/agents/test-writer.md) |
| anthropic-sdk-python / -typescript `CLAUDE.md` | rule | Fail-before/pass-after; negative branch; public API only; tripwire tests | yes | no | [py](https://github.com/anthropics/anthropic-sdk-python/blob/main/CLAUDE.md), [ts](https://github.com/anthropics/anthropic-sdk-typescript/blob/main/CLAUDE.md) |
| Next.js `AGENTS.md` | rule | Mandatory `pnpm new-test` generator; `retry()` not `setTimeout` | partly | no | [link](https://github.com/vercel/next.js/blob/canary/AGENTS.md) |
| Supabase, Cloudflare `AGENTS.md` | rule | Commands; narrowest test first; skip credentialed E2E | no | no | [supabase](https://github.com/supabase/supabase/blob/master/AGENTS.md), [cf](https://github.com/cloudflare/workers-sdk/blob/main/AGENTS.md) |
| openai/codex `AGENTS.md` | rule | insta snapshots for UI, whole-object `assert_eq`, per-crate test commands | partly | no | **[S]** via [Vaughan](https://codex.danielvaughan.com/2026/05/03/anatomy-production-agents-md-openai-codex-repository-case-study/); raw file 404 |
| TDD Guard | hook | Block edits without a failing test; one test at a time | no (procedure) | no | [link](https://github.com/nizos/tdd-guard) |
| Stop-hook test gate | hook | Run suite, `decision: "block"` on failure, check `stop_hook_active` | no | no | **[S]** via [shiplight](https://www.shiplight.ai/api/blog/claude-code-hooks/raw) snippet |
| Cursor test rules | rule | Framework, layout, AAA, naming, one example test | no | no | **[S]** via [qaskills](https://qaskills.sh/blog/cursor-rules-test-generation-patterns) |

## What the instructions have in common

- Run the narrowest test first, then the suite.
- Write the failing test first and watch it fail (TDD Guard, Superpowers, Anthropic SDK files, adewale).
- Avoid mocks, assert on public behaviour (Anthropic docs, Superpowers, Anthropic SDK files).
- Name the framework, file layout, and an example test.
- Show evidence of the run before claiming done.

## What none of them address

| Dimension | Coverage |
|---|---|
| Deciding what not to test | Only Superpowers `writing-good-tests.md` ("No change detectors", constructors and getters earn tests only when they validate or cause side effects) and adewale. Everything else says "comprehensive" or sets coverage targets. |
| Matching granularity to project phase | Only adewale ("Throwaway probes ... may need only a smoke check or no tests"; walking skeleton for new services). Superpowers lists prototypes as exceptions to "ask your human partner". |
| Confirming the test can fail | Well covered by procedure (verify red). Superpowers `verification-before-completion` adds revert-the-fix then confirm red. Gap: tests added after the code, where red cannot be observed. adewale: "do not backfill a TDD claim from a green-only log". |
| Mutation or held-out verification | Superpowers: a mental "mutation check". adewale: survivor triage references and mutation-seeded eval oracles. No skill runs a mutation tool by default or uses held-out tests. Only evals use them. |
| Learning from escaped defects | Absent from every artifact reviewed. adewale mentions "high coverage but escaping bugs" as a trigger for its mutation reference, but nothing feeds production defects back into test rules. |

## Best passages to reuse

**Superpowers `writing-good-tests.md` (gate function):**

```
BEFORE writing the test body:
  Name the production change that would make this test fail.

  Cannot name one            → redesign around an observable behavior
  "The source text changed"  → run the artifact and assert its effects
  Only intentional decisions → change detector; test the behavior
                               that depends on the decision

  Confirm the expected value is derived without the code under test.
  IF it reuses the code's logic or helpers:
    Replace it with a literal or hand-checked fixture
```

**anthropics/anthropic-sdk-python `CLAUDE.md`, Tests:** "**Fail before, pass after.** A behaviour change comes with a test that fails before it and passes after. Cover the negative branch too, so that a wrong implementation fails." and "**Go through the public API.** Mock HTTP with `respx` or an `httpx2.MockTransport`, and assert on the wire request and headers. Don't use `MagicMock` or call private methods, because those tests keep passing when the wire behaviour breaks."

**adewale/testing-best-practices `SKILL.md`:** "Do not give every artifact the same test plan. Reusable libraries, parsers, payment/auth/security boundaries, migrations, and code that will be refactored deserve stronger regression/property/contract coverage. Throwaway probes, one-off research scripts, or generated exploration may need only a smoke check or no tests if the user accepts that lifecycle."

## Implications for a Claude Code test-writing skill

- **Adopt or extend before writing.** Judgment-encoding content already exists in `writing-good-tests.md` and `adewale/testing-best-practices`. A new skill sharing "writing tests" triggers with either, or with Superpowers' TDD skill, violates the no-sibling rule. Install one, then add only the delta (below) as a reference file or a CLAUDE.md block.
- **Extend the review agent, not a skill, for test quality.** The dotfiles `run-init` reviewer and worker prompts already say a test "that cannot fail ... counts as missing" and forbid editing existing tests to pass. Adding the name-the-break gate and mirror-assertion check there reuses an existing trigger and gives a second-context check, which Anthropic recommends. Do not touch the built-in `code-review` (it excludes coverage by design).
- **The delta no existing artifact covers:** a phase and lifetime rule (adewale has it, Superpowers does not), tests-after-code handling (red unobservable, so require a revert-the-fix check), and a defect-to-test feedback loop (nobody has it). Those three justify a thin addition; a full new skill does not.
- **Put the always-on rules in CLAUDE.md, not only a skill.** Vercel's result (skill ignored 56% of the time, AGENTS.md index 100%) is the closest evidence; keep it to a handful of lines per the "would removing this cause mistakes" test.
- **Measure before shipping.** Use the placebo plus baseline design from the dev.to benchmark with hidden mutants. Current Opus may already sit at the ceiling on small tasks, so use realistic repos and report mutation score, not coverage. Expect little lift on isolated functions.
- **Hooks only for the cheap, deterministic part.** A Stop or TaskCompleted hook that runs the suite is sound; do not try to enforce test quality with a hook, since TDD Guard shows the only available mechanism is another LLM judge, unmeasured.
- **Decision (judgment call):** extend, do not write new. A dissenting consideration: Superpowers' hard-line "delete the code" rule conflicts with a lifetime-calibrated policy, so adopting Superpowers' TDD skill wholesale and adding calibration would send contradictory instructions.

## Open questions

- Does Superpowers' `writing-good-tests.md` change test quality? No measurement found; adewale's 44-run ablation scorecard (`skill-development/evals/scorecard.md`) was not read, and its arms appear to be skill versions, not no-skill.
- Does the 2608.15188 non-inferiority result hold on a private codebase with weaker existing tests? Only the abstract was read.
- What do Devin and OpenHands instruct about tests? No primary source retrieved.
- Was the 2025 "write tests, commit; code, iterate, commit" section removed or moved? The current page lacks it; the original was not retrievable.
- The `security-review` command's treatment of tests was not verified.
