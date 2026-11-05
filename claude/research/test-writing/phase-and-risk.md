# What to test, and how granularly, by phase and risk

Question: how should an engineer or an LLM decide which tests to write, and at what level, given the project's phase and where defects are likely and costly? Complaint being addressed: LLM-written tests are too granular for the phase and cover code that will never break. Access date for all URLs: 2026-10-07. Tags: **[E]** empirical, **[O]** practitioner opinion, **[S]** primary blocked, quote taken from a secondary source (named).

## Core findings

1. **Risk is a judgment about specific reasons, not a score.** Bach defines magnitude as "a joint function of the likelihood and impact of the problem", but recommends a three-level scale (normal, higher, lower), warns against "scales that appear more objective than they really are", and says "Risk analysis is a matter of evaluating factors that influence risk, not merely counting them." **[O]** Likelihood times impact matrices have documented ranking errors (Cox: range compression, rank reversal). **[E, S: search summary of Cox 2008]**
2. **Defects cluster, but the cluster is hard to pick in advance.** AT&T: first 20% of files by predicted faults held 83% of faults on average (Ostrand et al.). **[E, S: search summary]** A 100-repo replication found Pareto holds only if multi-file fixes count as multiple defects, and that "it is difficult to reliably identify the 'most fixed' 20% of files from basic metrics". **[E]** Treat the 80/20 as a prior, not a map.
3. **Recently changed code is where defects live; ownership matters.** Relative churn separated fault-prone from not fault-prone binaries "with an accuracy of 89.0 percent" while absolute churn was a poor predictor. **[E]** Changed-but-untested methods held 43% and 40% of field bugs in two releases while being 8% and 9% of methods. **[E, 33 bugs, authors call it too small to generalize]** More minor contributors meant more pre- and post-release failures in Windows Vista and 7. **[E]**
4. **A test is code with an upkeep cost; low-value tests are net negative.** Khorikov: "It's easy to create tests whose net value is close to zero or even is negative due to high maintenance costs." Google: "The ideal test is unchanging." **[O]** Snapshot testing studies name fragility as practitioners' main concern. **[E, S: search summary]** I found no measured figure for test maintenance as a share of total effort.
5. **Phase changes the value of a test.** Beck added tests to Max only after its first subscribers, and tests when "a test helps me validate more experiments per unit time". Hunt and Thomas: prototypes are disposable, tracer code is not. North: sketch, then "stabilise it, make it testable, introduce rigour". **[O]**
6. **Where the risk lives sets the level, not a shape.** Spotify found microservice complexity "is not within the service itself, but in how it interacts with others", so it skips implementation-detail tests. Fowler quotes Searls: the percentage debate "is a distraction"; the goal is tests that "only fail for useful reasons". **[O]**
7. **Agent-written tests have measurable weaknesses.** Agents add mocks in 36% of commits versus 26% for non-agents. **[E]** Changing agent test volume did not significantly change SWE-bench Verified outcomes; most tests were print-style probes. **[E, different setting from maintaining a suite]**
8. **Types and coverage are weak substitutes for judgment in both directions.** Types would have flagged 15% of sampled JavaScript bugs. **[E, S: search summary]** Coverage correlates low to moderately with effectiveness once suite size is controlled and "should not be used as a quality target". **[E]**

## A decision procedure

Steps marked **(ctx)** need project context the model lacks unless told.

1. **(ctx) Phase.** Explore (is the idea valid?), expand (it works, scaling), extract (stable, paying for itself). Source: Beck 3X; North. Explore: write no automated tests beyond one end-to-end smoke path (walking skeleton); expand: tests on what hurts; extract: full strategy below.
2. **(ctx) Blast radius.** Money, data loss, auth, or silent corruption: test. Visible and cheap to fix: skip. Source: Bach "Critical", "Upstream Dependency"; the "if this breaks silently" filter **[O]**.
3. **Name the behaviours changed, not the methods.** Google: "write a test for each behavior". One behaviour, one test.
4. **Score each behaviour with Bach's generic risks:** complex, new, changed, upstream dependency, critical, recent failure, third-party, buggy. Rate normal, higher, or lower; record the reason. **(ctx)** Hotspots and owner count come from git history (Tornhill; Bird).
5. **Drop what already cannot break.** No conditional logic (Fowler: no gain from trivial getters); framework or ORM behaviour; **(ctx)** anything the type system or schema already enforces (Gao: 15% only).
6. **Pick the level by where the risk sits.**
   - Pure logic, large input space, parsers, serializers: examples at the boundaries plus a property (round trip, invariant).
   - Behaviour crossing a boundary you control on both sides: contract or integration test; avoid mocking your own collaborators (Spotify; Khorikov).
   - **(ctx)** External API with unknown consumers: contract tests do not fit (Pact docs).
   - UI: test as the user uses it (Dodds).
   - Pipeline: data-quality checks on outputs plus transformation unit tests, one end-to-end run.
7. **Refactor test.** If an internal rewrite preserving behaviour would break the test, do not write it (Google, Khorikov, Beck "structure-insensitive"). Reject assertions on call order or private state, and large snapshots.
8. **Bugs.** Every bug fix gets a regression test at the lowest level that reproduces it (Fowler pyramid rule).
9. **Inherited code.** Characterization tests only around code about to change (Feathers). Do not backfill the rest.
10. **Stop rule.** Stop when the remaining fears are boredom-level (Beck) and "you are rarely hesitant to change some code for fear it will cause production bugs" (Fowler).
11. **Verify one test.** Break the code deliberately and confirm a test fails. Do not report coverage as the outcome (Inozemtseva).
12. **Write down skips.** One line per skipped risk and why.

## Evidence by topic

**Bach, risk-based testing.** "This is risk-based testing: 1. Make a prioritized list of risks. 2. Perform testing that explores each risk. 3. As risks evaporate and new ones emerge, adjust your test effort." Heuristic: "higher-risk items get twice the effort as normal items" (approximation). Admits explicit risk accounting is optional: "I've never been on a project where we felt the cost of rigorous analysis was justified." Heuristic Risk-Based Testing, STQE, Nov/Dec 1999, via mirror: https://www.fing.edu.uy/inco/cursos/ingsoft/pis/memoria/dvd01/experiencia2005/MUM/protest/library/808733.pdf **[O]**. HTSM v6.3 text not retrieved; description (project environment, product elements, quality criteria) from search summaries **[S]**.

**Black and ISTQB.** Black's tool multiplies likelihood (technical) by impact (business) into a risk priority number **[S: search summaries; rbcs-us.com unreachable]**. ISTQB principle 4: "A small number of modules usually contain most of the defects discovered during pre-release testing or is responsible for most of the operational failures." Principle 2: exhaustive testing impossible. https://astqb.org/istqb-foundation-level-seven-testing-principles/ **[O]**.

**Churn, ownership, hotspots.** Nagappan and Ball, ICSE 2005, Windows Server 2003: https://www.microsoft.com/en-us/research/wp-json/wp/v2/msr-research-item/151819 **[E]**. Bird et al., FSE 2011: "binaries with more minor contributors had more pre- and post-release failures in both versions of Windows." https://neverworkintheory.org/2011/09/05/dont-touch-my-code.html **[E, S]**. Eder, Hauptmann et al., "Did We Test Our Changes?", AST 2013 (CQSE, Munich Re, 340 kLOC C#, 14 months): 15% of methods changed, 34% untested; of changed methods only 44% and 45% tested; changed-untested bug probability 0.53% and 0.21%. https://wwwbroy.in.tum.de/publ/papers/AST13Hauptmann.pdf **[E]**. The "5x" figure is CQSE's later summary of this study, not in the paper: https://teamscale.com/test-gap-analysis **[S, vendor]**. Tornhill and Borg, "Code Red": 30,737 files, 39 codebases, "low quality code contains 15 times more defects"; https://arxiv.org/abs/2203.04374 **[E, vendor-affiliated]**. Hotspots "only make up 2-3% of the total code size" yet 25-70% of defects: https://codescene.com/blog/tech-debt-examples-prioritize-technical-debt-with-codescene **[O, vendor]**. Critique: Walkinshaw and Minku, ESEM 2018, https://research.birmingham.ac.uk/en/publications/are-20-of-files-responsible-for-80-of-defects **[E]**.

**Cost side.** Khorikov ch. 1: "Code is a liability, not an asset... Tests are code, too." Costs: refactoring the test, running it, false alarms, reading it. https://enterprisecraftsmanship.com/files/Unit-Testing-Chapter-1-Excerpt.pdf **[O]**. Google: "A brittle test is one that fails in the face of an unrelated change to production code that does not introduce any real bugs." https://abseil.io/resources/swe-book/html/ch12.html **[O]**. Hyrum's Law ("all observable behaviors of your system will be depended on by somebody", https://www.hyrumslaw.com/) cuts both ways: it explains why pinning observable behaviour feels safe, and why pinning internals that no consumer observes is waste **[O, my inference]**. Beck: "I get paid for code that works, not for tests, so my philosophy is to test as little as possible to reach a given level of confidence... If I don't typically make a kind of mistake... I don't test for it... carefully test code that we, collectively, tend to get wrong." https://news.ycombinator.com/item?id=13130039 **[S: Stack Overflow blocked]**. "Write tests until fear is transformed into boredom": TDD By Example **[S: search summary]**.

**Phase.** Beck on Max: "When I started Max I didn't have any automated tests for the first month" then "went back and wrote tests" (quoted in https://www.infoq.com/news/2009/06/test-or-not) **[S]**. Spike: "Most spikes are not good enough to keep, so expect to throw it away" **[S: search summary]**. Tracer bullets: "one thin line of execution goes end to end"; prototypes are not designed "to be long lasting code" (https://www.artima.com/articles/tracer-bullets-and-prototypes) **[O]**. Walking skeleton: "thinnest possible slice of real functionality that we can automatically build, deploy, and test end-to-end" (Freeman and Pryce) **[S: search summary]**. North: https://gojko.net/2011/11/10/dan-north-at-oredev-embrace-uncertainty/ **[S: live blog]**. Feathers: characterization test means assert anything, watch it fail, "change the expected to the actual" (https://daedtech.com/characterization-tests/) **[S]**.

**Granularity.** Fowler on solitary versus sociable: "If talking to the resource is stable and fast enough for you then there's no reason not to do it in your unit tests." https://martinfowler.com/bliki/UnitTest.html **[O]**. Spotify: https://engineering.atspotify.com/2018/01/testing-of-microservices **[O]**. Property-based testing: Jane Street interviews, 30 people, "main strengths lie in testing complex code", "most uses fall into a relatively small number of high-leverage idioms", weaknesses are writing properties and generators; round-trip properties 11 of 30. https://cis.upenn.edu/~bcpierce/papers/icse24-pbt-in-practice **[E]**. Anthropic agent: 56% valid bugs, 86% valid among top-scored reports; limitation "If the code makes an implicit assumption, only the library maintainers can decide what the correct property to test is." https://www.anthropic.com/research/property-based-testing **[E]**. Contract tests: Pact is good where "the consumer and provider are both under active development" and not for "APIs where the consumers cannot be individually identified (eg. public APIs)". https://docs.pact.io/getting_started/what_is_pact_good_for **[O]**. Data pipelines: Thoughtworks lists source, flow, contract, component, unit, and data-quality tests, https://www.thoughtworks.com/insights/blog/testing/testing-data-pipelines **[O]**.

**Agents.** Hora and Robbes, MSR 2026, 1.2M commits, 2,168 repos: 23% of agent commits touch tests versus 13% for non-agents; they recommend "guidance on mocking practices in agent configuration files." https://andrehora.github.io/pub/2026-msr-agents-over-mocked-tests.pdf **[E]**. Chen et al. 2026: https://arxiv.org/abs/2602.07900 **[E]**. 
**Published skip heuristics.** Fowler: coverage is "a useful tool for finding untested parts" and 100% "would smell of someone writing tests to make the coverage numbers happy." https://martinfowler.com/bliki/TestCoverage.html **[O]**. Metz: assert incoming queries and commands, ignore outgoing queries, never test private methods (https://speakerdeck.com/skmetz/magic-tricks-of-testing-railsconf) **[S: search summary]**. "If this breaks silently, what happens?" filter for Claude Code users, March 2026: https://dev.to/ramon_galego/what-to-tell-claude-code-to-test-and-what-to-skip-3foo **[O]**.

## Signals of over-testing

- Test names mirror method names (`testFoo`), one per method.
- Mocks of the project's own classes; assertions on call counts or order.
- Assertions restate the implementation (same constants, same formula).
- Getter, setter, DTO, or config-wiring tests with no branching.
- Large snapshots updated in bulk without review.
- A refactor with unchanged behaviour fails more than one test.
- Tests added during explore phase for code rewritten within weeks.
- Test-to-code ratio high in files with no churn, no recent bugs, and low blast radius.

## Signals of under-testing

- Hotspot files (high churn, many authors) with no tests.
- Changed lines in a diff with no test executing them (test gap).
- Bug fixes merged without a regression test.
- Money, auth, permissions, or data-deletion paths covered only by happy-path tests.
- Boundary inputs (empty, zero, maximum, unicode, time zones) untested in parsers, serializers, and calculations.
- Integration boundaries (external API, database, queue) exercised only through mocks that were never checked against the real thing.
- Stable, expanded-phase product with no end-to-end smoke test.
- Engineers hesitate to change a module "because it might break something".

## Implications for a Claude Code test-writing skill

- **Ask or infer the phase first.** Read CLAUDE.md for a stated phase; otherwise ask once. Default to "expand" when unknown, and say so.
- **Infer hotspots from git.** For example `git log --since=6.months --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20`, plus distinct authors per file. Rank by churn relative to size (Nagappan), not absolute churn.
- **Require a risk line per test.** Each proposed test states the behaviour, the failure it catches, and the blast radius. Tests without one are not written.
- **Ask what the types and framework enforce.** Read tsconfig strictness, schema validators, and ORM constraints; skip behaviours they already guarantee.
- **Ban or gate mocks of internal collaborators.** Put the rule in CLAUDE.md (Hora and Robbes recommend exactly this); prefer sociable tests and real boundaries.
- **Default outputs by diff.** For a bug fix: one regression test. For a new pure function: boundary examples plus one property. For glue code: nothing, with a stated reason.
- **Allow "no tests needed" as a valid answer** with the written skip list, so omission is visible rather than silent.
- **Final check:** break the code once to confirm a test fails; do not report coverage.

## Open questions

- No measured share of effort spent on test maintenance was found; the "net negative" claim rests on opinion and fragility surveys.
- No study measures how often LLM-written tests ever fail for a real reason; the "tests that never break" complaint is plausible but unquantified. A mutation-score or never-failed-in-N-months audit on this repo would measure it.
- Churn and ownership studies are binary- or file-level on large Microsoft systems; transfer to small repos or solo projects is unproven.
- No agreed, checkable definition of phase exists; explore-to-expand has no signal an agent can read from the repo (deploys? users? release tags?).
- Judgment calls: I treated Bach's three-level scale as the scoring method and did not adopt likelihood-times-impact numbers; I placed contract tests at boundaries both teams control; the 12-step procedure is my synthesis and is untested.
