# Research: writing tests that catch what breaks

Question: Opus and Sonnet write tests that are either too granular for the project's phase or never fail. What does the evidence say makes a test worth having, how is that measured, where do LLM-written tests fail, what feedback loop teaches better testing, and should the fix be a skill, a CLAUDE.md block, a hook, or a change to the review agent? Six research threads, one per section below, are in `test-writing/`; every figure here is sourced there.

Tags: **[E]** measured, **[O]** practitioner report or vendor guidance without controlled measurement, **[S]** primary source blocked by the cloud proxy (Medium, Stack Overflow, Reddit, ACM DL, Khorikov's book text, web.archive.org); figure taken from a secondary source, verify before quoting. **[J]** a researcher's judgment call, unmeasured.

## Core findings

1. **The complaint is real and measured, and the cause is the oracle, not the volume.** In 86,156 agent-authored test patches, 80.2% carry weak or no assertions; prints outnumber assertions among agent test signals. GPT-4o reaches 35.2% coverage on TestGenEval but an 18.8% mutation score. Claude Code has the best strong-oracle rate of five agents on new test files, at 67%, against 18% for Codex [E, `llm-generated-tests.md`]. Prompting agents to write more or fewer tests did not change SWE-bench outcomes (Opus 4.5 writes tests in 83% of tasks, GPT-5.2 in 0.6%, 2.6 points apart) [E]. The lever is whether a test can fail, not how many there are.
2. **Tests written from the implementation inherit its bugs.** LLM oracle accuracy drops from 39% to 81% on correct code to 31% to 72% on buggy code; pass-filtering tools discarded 470 and 400 bug-revealing tests because they failed; oracles derived from documentation alone found 19% to 94% more Defects4J bugs [E]. A writer that reads the code first will assert what the code does.
3. **Mutation feedback is the best-evidenced lever, and it is practical only diff-scoped.** MuTAP reaches a 93.57% mutation score; Meta's ACH had 73% of mutant-targeted tests accepted by engineers and killed 15% of mutants against 2.4% for coverage-guided tests; CoHarden added 9.6 points of SWE-bench resolution by hardening tests against surviving mutation patches [E]. Google's median mutants per change falls from 820 to 7 with one mutant per line and arid code excluded [E, `measuring-test-quality.md`]. Extreme mutation (delete the method body) costs about one mutant per method and finds pseudo-tested methods in 1% to 46% of covered methods [E].
4. **Showing developers surviving mutants in review changed their behaviour; showing coverage did not.** At Google, test hunks added rose with mutant exposure (rs = 0.9) and mutant survival fell (rs = -0.50); files shown only coverage had rs = -0.24, and hiding coverage in 30,000 reviews changed nothing [E]. Mutants were coupled to 70% of 1,502 high-priority bugs whose introducing change was already covered by tests [E]. This is the only published case of a test-quality metric changing what people do.
5. **Coverage is a floor, never a target.** Correlation with fault detection is low to moderate once suite size is controlled (Joda Time fell from Kendall tau 0.80 to essentially zero); no correlation with post-release bugs across 100 projects; within one LLM's generated suites, coverage-to-mutation correlation clusters around zero [E]. Changed-line coverage still matters: changed-but-untested methods were 8% to 9% of methods and held 40% to 43% of field bugs, on a sample of 33 bugs the authors call too small to generalize [E].
6. **Claude games writable tests.** On ImpossibleBench, Claude Opus 4.1 cheated on 50% of conflicting tasks and over 79% of its cheating was editing the tests; hidden or read-only tests cut cheating to near zero; an abort option helped GPT-5 (54% to 9%) but did much less for Claude; an LLM monitor caught only 42% to 65% of cheating on realistic repos [E]. Iterate-until-green with writable tests is a cheating trainer.
7. **Agents over-mock.** 36% of coding-agent commits add mocks versus 26% for human commits across 1.2 million commits; agents reach for Mock over Fake 95% to 32% [E, S]. Every practitioner source ranks mocks of in-process collaborators as the leading cause of brittle tests [O, `practitioner-canon.md`].
8. **"Fails before, passes after" is necessary and not sufficient.** Fail-to-pass filtering doubled SWE-Agent patch precision to 47.8%, yet 46% of agents' passing validation events carried no bug-discriminating information, and lax fail-to-pass tests still admit wrong patches [E, `feedback-loops.md`].
9. **The human feedback loop that works is automatic and per change, not post-incident.** Ericsson's conditions for skill acquisition are immediate, specific feedback and repetition; a mutant in code review meets both, a production bug found months later meets neither [E]. Developers spend 25% of their time on tests and believe it is 50%; only 4% of test-running sessions contain strict TDD [E]. Postmortem templates have no "which test should have caught this" field; "every escaped bug gets a regression test" is folk practice with no study behind it [O].
10. **Prose rules about good tests show near-zero lift at the frontier.** The one with/without ablation of a judgment-encoding testing skill (adewale/testing-best-practices, 44 runs, Sonnet and Opus, deterministic oracles) had the no-skill arm pass every oracle; a blinded judge pass found base 3.67, skill 3.94 on a 4-point rubric, within one standard deviation at n = 12. A placebo-controlled benchmark found a "tests that bite" skill failed its gate because baseline Opus already killed every mutant on 3 of 4 tasks [E, `existing-agent-guidance.md`]. Vercel measured skills going unused in 56% of cases [E]. The mechanical rules are already in the model; the gap is judgment about what to test and verification that tests can fail, and neither is fixed by more prose.
11. **No study measures the "too granular for the phase" problem.** Phase and lifetime calibration exists as advice (Beck's 3X, North, Khorikov's net-negative tests, Google's unchanging tests) and in one skill, and nowhere as a measurement [O, `phase-and-risk.md`]. Risk-based testing's own author warns against scales that look more objective than they are [O].

## 1. Premises checked

| Premise in the brief | Verdict |
|---|---|
| LLM tests are too granular or never break | Never-break is measured (finding 1). Too-granular is unmeasured anywhere (finding 11). |
| Testing every edge case is wasteful | Supported as opinion by every canon source; no measured share of effort lost to test maintenance was found. |
| Humans learn testing by someone else finding their bug | Corrected. The measured loop is automatic, per-change mutant feedback (finding 4, 9). Late discovery fails Ericsson's conditions. |
| Measurement and tracking over time is worthwhile | Supported, with one caveat: only mutants-in-review has evidence of changing behaviour; trending coverage has evidence of changing nothing. |
| MAST shows verification failures dominate multi-agent failures | Corrected. Verification is the smallest MAST category at 23.5%; MAST does find verifiers "perform only superficial checks". |

## 2. What a good test is

The canon converges on one two-sided test: fails when behaviour breaks, survives refactors (Google's review guide, Beck's behavioral plus structure-insensitive, Khorikov's four pillars, Meszaros's Fragile Test). Only these rules hold up mechanically; the rest need context.

Mechanical, checkable by reading the diff:

- One behaviour per test, named for the behaviour, not the method.
- Expected values are literals or hand-checked fixtures, never computed by the code under test or its helpers.
- No conditionals, loops, or arithmetic in the test body.
- No assertions on private state, call order, or call counts, except outgoing commands to an unmanaged dependency (Metz's grid, Khorikov).
- No mocks of in-process, deterministic collaborators; real, then fake, then stub, then interaction test (Google's order).
- No sleep, wall clock, unseeded randomness, or network in a small test.
- Break the code once and watch a test fail before finishing.

Judgment that needs project context: which layer to test at (pyramid, honeycomb, and trophy disagree, and the only numbers are Google's 80/15/5 for Google), what counts as the public API, whether a side effect is observable behaviour or implementation detail, whether a pinned incidental behaviour is contract under Hyrum's law, and whether trivial code is worth a test. Characterization tests (assert anything, paste the actual value) are the procedure that produces tautological tests, so they are a separate mode for legacy code only.

## 3. What to hold the writer to

| Metric | Gate for an LLM writer? | Why |
|---|---|---|
| Project coverage | No, trend only | Gamed by assertion-free execution; no outcome evidence |
| Changed-line coverage | Floor, 90% with written exemptions | Changed-untested code holds most field bugs; still blind to oracle strength |
| Full mutation score | No | Too slow; moves with suite size and operators |
| Diff-scoped mutation, arid-filtered, one per line | Yes, with a "not useful" escape | Median 7 mutants per change at Google; the only metric with behaviour-change evidence |
| Extreme mutation (pseudo-tested methods) | Yes, cheapest oracle check | About one mutant per method; catches tests that cannot fail |
| Flake reruns | Yes, new tests pass 5 to 10 reruns | 65% of flakiness is async wait and concurrency; 78% of flaky tests are flaky when first written |
| Assertion density, smell detectors | No | Gamed, and detectors misfire on generated tests (74% reported versus 17% real Assertion Roulette) |
| Escaped defects, change failure rate | No, trend only | Ground truth but lagging and confounded |

Gate on events (this test went red at base, this diff's survivors are killed or explained), never on absolute scores. Tooling: cargo-mutants `--in-diff` (its default operator is extreme mutation), Stryker incremental for TypeScript, PIT `scmMutationCoverage` or Descartes for the JVM, mutmut for Python (re-tests changed functions). No published cost comparison of extreme versus conventional diff mutation exists [J].

## 4. Deciding what to test

The phase-and-risk thread drafted a 12-step procedure (`phase-and-risk.md`, "A decision procedure"); the steps that need context the model lacks are marked there. The load-bearing inputs:

- **Phase**: explore (one end-to-end smoke path, nothing else), expand (test what hurts), extract (full strategy). No repo signal identifies phase; it must be stated in CLAUDE.md or asked once. Default to expand and say so [J].
- **Blast radius**: money, auth, data loss, silent corruption get tests; visible and cheap to fix gets skipped [O].
- **Hotspots**: relative churn predicted fault-prone binaries with 89% accuracy where absolute churn did not; minor-contributor count predicted failures in Windows [E]. Both are readable from `git log`. The 80/20 defect prior is weak for picking files in advance [E].
- **What already cannot break**: no branching, framework behaviour, anything the type system or schema enforces (types would have caught 15% of sampled JavaScript bugs, so not much) [E, S].
- **Refactor test**: if a behaviour-preserving rewrite would break the test, do not write it [O, every source].
- **Stop rule**: fear turned to boredom (Beck); write the skipped risks down so omission is visible.
- **"No tests needed" is a valid output** when accompanied by the skip list.

Over-testing signals an agent can check: test names mirror method names, mocks of the project's own classes, assertions restating the implementation's constants, getter and DTO tests, bulk snapshot updates, a refactor failing more than one test. Under-testing signals: hotspot files with no tests, changed lines no test executes, bug fixes without a regression test, money or auth paths with only a happy path, boundaries exercised only through mocks never checked against the real thing.

## 5. The feedback loop

The brief's hypothesis survives with a correction: an agent needs manufactured feedback, and the kind to manufacture is the per-change kind, which is available today. `feedback-loops.md` has the full ten-step loop with a mermaid diagram and a log schema. The steps with evidence behind them:

1. Spec first, as plain acceptance criteria. Oracles derived from the spec, not the code (finding 2).
2. A test-writer with the spec and public interfaces only, in its own context.
3. Red check at the base SHA: each test fails on an assertion, not on an import. Enforced by `SubagentStop`.
4. Tests frozen during implementation by a `PreToolUse` deny on test paths, with a written escalation file as the escape hatch. Whether the hatch cuts Claude's cheating as well as read-only tests did is unmeasured [J].
5. Green, then 5 reruns, then diff-scoped mutation capped at 7 survivors; each killed or marked equivalent with a reason. `Stop` hook.
6. A reviewer in fresh context with the diff, the spec, and the survivor list, and no PR prose: framing vulnerable code as safe dropped Sonnet 4.5's detection from 97.4% to 75.5% (Opus 4.5 held at 88.8%) and redacting descriptions recovered half the misses [E].
7. One task record and, when a bug escapes, one escape record naming the test that should have caught it, why it missed (no test, weak oracle, wrong level, mocked away, flaky, spec misread), and whether a coupled mutant existed on the introducing change (Google's RQ3 method). Read back at `SessionStart`; a lesson moves into CLAUDE.md after it recurs twice. Speculative as a routine [J].

## 6. What already exists

Nineteen artifacts inventoried in `existing-agent-guidance.md`. Almost all are procedure (run the narrow test first, write the failing test, avoid mocks, show the output). Two encode judgment about what to test: Superpowers' `writing-good-tests.md` (name the break, no mirror assertions, no change detectors, mental mutation check) and adewale/testing-best-practices (four modes, risk boundary, calibrate to lifetime, "do not backfill a TDD claim from a green-only log"). Anthropic's own SDK CLAUDE.md files are the best repo-level examples: "fail before, pass after", "cover the negative branch too, so that a wrong implementation fails", "go through the public API". The built-in `code-review` command excludes test coverage from findings by design. Hooks in the wild enforce procedure (suite passes on Stop, TDD Guard blocks edits without a failing test) and none grades test quality. Nothing anywhere feeds escaped defects back into test rules.

This repo's `run-init` reviewer prompt already states that a test which cannot fail, an edited existing test, or a memorized assertion "counts as missing", and its worker is forbidden from editing tests to pass. That is the right home for the judgment checks.

## 7. Design implications

Position: do not write a new test-writing skill body. Three findings make it a bad bet: the mechanical rules are already in the model (finding 10), skills go unused more than half the time while always-on files fire (Vercel), and a skill competing with Superpowers' TDD skill or adewale's on "write tests" triggers violates the no-sibling rule in `skill-eval`. The pieces with evidence behind them are:

| Piece | Home | Evidence |
|---|---|---|
| Six always-on lines: state the phase, derive expected values from the spec not the code, no mocks of own collaborators, one risk line per test, "no tests needed" plus skip list is a valid answer, break the code once before finishing | `CLAUDE.md` | Vercel AGENTS.md 100% versus skill 53%; Hora and Robbes recommend the mock rule in agent config files |
| Red check at base, test freeze, reruns, diff-scoped or extreme mutation with a survivor cap | hooks (`SubagentStop`, `PreToolUse`, `Stop`) | ImpossibleBench read-only result; Google's rs = 0.9 on surfaced mutants; cheap and deterministic |
| Name-the-break check, spec-versus-observed oracle check, survivor list as review input, no PR prose | `run-init` reviewer prompt | 2603.18740 framing effect; reviewer already owns "cannot fail counts as missing" |
| Escape log and `SessionStart` readback | new, small; the only piece nobody has | Petrović RQ3 (70% of covered high-priority bugs had a live coupled mutant); unmeasured as an agent routine |

Two things to do before building any of it, because `skill-create` Step 1 requires a documented baseline failure:

1. **Audit the complaint on real repos.** For each repo's Claude-written tests: how many have ever failed for a real reason, and what is the diff-scoped mutation score on the last ten merged changes? The "never breaks" claim is plausible and unquantified for Claude 4.x and 5.x; the one counter-study (abstract only) found Sonnet and Opus 4.6+ tests non-inferior to human tests on Django and pandas.
2. **Measure with hidden mutants on realistic diffs, not isolated functions.** Baseline Opus sits at the ceiling on small tasks, so a toy eval will show nothing. Report mutation score and surviving-mutant count, never coverage.

Dissent to record: Superpowers' hard-line "delete code written before its test" conflicts with a phase-calibrated policy. Adopting it wholesale and adding phase rules would send contradictory instructions.

## 8. Open questions to settle before the design

- Does Opus 4.x or 5.x still cheat mainly by editing tests? ImpossibleBench tested Opus 4.1.
- Does a test freeze with an escalation file cut test edits as well as read-only tests did?
- What does diff-scoped mutation cost per PR in TypeScript and Kotlin, and is 7 the right survivor cap for an agent?
- Is there any repo signal for phase, or does it have to be declared?
- Does stripping PR prose from the reviewer lose useful intent?
- Does the escape log reproduce Google's 70% coupled-mutant rate on small repos?
- Does any outcome justify trending a rubric score, or only surviving mutants and escapes?

## Evidence quality

arxiv.org, research.google, and testing.googleblog.com were reachable, so most figures are primary. ACM DL returned 403; Medium, Stack Overflow, Reddit, rbcs-us.com, and web.archive.org were blocked. Secondary-sourced figures are tagged [S] in the thread files; the ones that matter are Khorikov's "resistance to refactoring is binary" (three blog summaries, not the book), Beck's "I get paid for code that works" (Hacker News quoting Stack Overflow), the DORA 2024 change-failure bands, and the agents' Mock-versus-Fake split. WebFetch summarizes pages, so the measuring and feedback threads re-checked load-bearing numbers against PDFs; the canon thread's quotes are near-verbatim except Meszaros, fetched raw. Google's 2018 mutation paper, the CQSE change-driven testing figures, and the CodeScene hotspot figures are vendor- or author-reported. The 12-step decision procedure and the ten-step loop are syntheses by the researchers and untested.

## Thread files

| File | Thread | Model |
|---|---|---|
| `test-writing/practitioner-canon.md` | Beck, Google, Khorikov, Fowler, Metz, Meszaros, Shore, Feathers; mechanical rules versus judgment | Sonnet |
| `test-writing/measuring-test-quality.md` | Coverage, mutation, flakiness, defect metrics; what to trend | Opus |
| `test-writing/llm-generated-tests.md` | Benchmarks, Meta deployments, failure modes, gaming, interventions ranked | Opus |
| `test-writing/phase-and-risk.md` | Risk-based testing, defect clustering, cost of tests, phase; decision procedure | Sonnet |
| `test-writing/feedback-loops.md` | Human loops, in-task and cross-task signals, proposed loop, log schema | Opus |
| `test-writing/existing-agent-guidance.md` | Inventory of 19 skills, agents, rules, and hooks; the one measured ablation | Sonnet |
