# Practitioner canon: what separates a good test from a bad one

**Question.** What does the practitioner canon (Beck, Google, Khorikov, Fowler and the pyramid family, Metz, Meszaros, Shore, Feathers, code-review guides) say distinguishes a good test from a bad one, which of those judgments can be encoded mechanically for an LLM that writes tests, and which need human context?

Access date for every URL: 2026-10-07. Quotes were returned by WebFetch's summarizing model, so treat wording as near-verbatim, not guaranteed verbatim, except where I fetched raw HTML with curl (xunitpatterns.com).

## Core findings

1. A good test fails when behaviour breaks and only then. Both halves matter: false positives (fails on refactor) destroy trust, false negatives (passes on broken code) destroy value. **[O]** Beck, Google, Khorikov, Meszaros agree.
2. Assert on observable outputs or state through the public API, not on calls between internals. Google, Khorikov, Shore, Meszaros ("Overspecified Software"), and Metz all converge on this. **[O]**
3. Mocks and interaction assertions are the single most-cited source of brittle tests. Real implementation beats fake beats stub beats mock (Google); mocks only for unmanaged out-of-process dependencies (Khorikov); mock only outgoing commands (Metz). **[O]**
4. Test setup may change with structure, but the assertion shouldn't (Google TotT). Setup that is rewritten on every refactor signals coupling. **[O]**
5. Readability beats DRY in tests: complete, concise, no logic, one behaviour per test, failure message that names expected and actual. **[O]**
6. Pyramid, honeycomb, and trophy disagree on the ratio of unit to integration tests, but agree that tests resembling real usage give more confidence and that mocking everything buys speed at the cost of confidence. **[O]**
7. The only measured data in this canon is Google's: flake rate around 0.15% and "as you approach 1% flakiness, the tests begin to lose value". Everything else is experience reports. Coverage and mutation scores of LLM-generated suites are only reliable proxies when the code under test is assumed bug-free (Zhao et al.). **[E]**
8. No source gives an operational test for "behaviour" versus "implementation detail" that doesn't need domain context. Khorikov's definition (below) is the closest. **[O]**

## Kent Beck, Test Desiderata

Properties, verbatim definitions: isolated ("same results regardless of the order"), composable ("test different dimensions of variability separately and combine the results"), deterministic, fast, writable ("cheap to write relative to the cost of the code being tested"), readable ("invoking the motivation for writing this particular test"), behavioral ("If the behavior changes, the test result should change"), structure-insensitive ("should not change their result if the structure of the code changes"), automated, specific ("the cause of the failure should be obvious"), predictive ("if the tests all pass, then the code under test should be suitable for production"), inspiring. https://testdesiderata.com/ **[O]**

Beck's own tradeoff statements: "Optimize the value of your tests by choosing how to tradeoff among various valuable properties"; "Making tests more predictive of production behavior makes them slower"; "Sometimes (and this is the magic), properties only seem to interfere. You can use composability to make tests faster and more predictive." Same URL. **[O]**

Behavioral and structure-insensitive together are the definition of a non-brittle test, and they only conflict when the structure is part of the behaviour. Beck's Medium essay returned 403, so claimed conflicts beyond the three above (behavioral vs structure-insensitive, composable vs writable, and others) come from third-party skill pages and my inference, not Beck. **[S]**

## Google (Software Engineering at Google, chapters 11 to 13; Testing Blog; eng-practices)

- "the ideal test is unchanging: after it's written, it never needs to change unless the requirements of the system under test change." https://abseil.io/resources/swe-book/html/ch12.html
- Test via public APIs: "make calls against its public API rather than its implementation details." Same URL.
- "With state testing, you observe the system itself to see what it looks like after invoking with it. With interaction testing, you instead check that the system took an expected sequence of actions." Same URL.
- "A behavior is any guarantee that a system makes about how it will respond to a series of inputs while in a particular state"; write a test per behaviour, not per method; given/when/then naming. Same URL.
- DAMP: "A little bit of duplication is OK in tests so long as that duplication makes the test simpler and clearer." Logic means "operators, loops, and conditionals"; keep it out of tests. "A test is complete when its body contains all of the information a reader needs." Same URL.
- Brittle: "a brittle test is one that fails in the face of an unrelated change to production code that does not introduce any real bugs." Same URL.
- Doubles, order of preference: real implementation, fake, stub, interaction test. "Interaction testing should be avoided when possible: it leads to tests that are brittle because it exposes implementation details." Legitimate uses: no way to assert state, or call count matters (for example caching). https://abseil.io/resources/swe-book/html/ch13.html
- Sizes are resource constraints: small tests run in one process with no sleep, I/O, or blocking calls; medium allow localhost; large allow multiple machines. Scope is separate: narrow, medium, large. Target "80% ... narrow-scoped unit tests ... 15% medium-scoped integration tests ... 5% end-to-end". Beyoncé rule: "If you liked it, then you shoulda put a test on it". Flake rate "hovers around 0.15%". https://abseil.io/resources/swe-book/html/ch11.html **[E]** for the figures
- Hyrum's Law: "With a sufficient number of users of an API, it does not matter what you promise in the contract: all observable behaviors of your system will be depended on by somebody." https://www.hyrumslaw.com/ Implication: tests that pin incidental behaviour (ordering, message text, call sequence) turn it into contract. **[O]**, the link to tests is my inference.
- TotT change-detector tests: mock heavily, assert on calls, break on any internal change. https://testing.googleblog.com/2015/01/testing-on-toilet-change-detector-tests.html **[O]**. TotT behaviour: "Test setup may need to change if the implementation changes ... but the actual test itself typically shouldn't". https://testing.googleblog.com/2013/08/testing-on-toilet-test-behavior-not.html
- TotT state vs interaction concedes a place for interaction tests (a welcome email is sent, simulating failures hard to reach through state). https://testing.googleblog.com/2013/03/testing-on-toilet-testing-state-vs.html **[O]**
- Code review guide: "Will the tests actually fail when the code is broken? If the code changes beneath them, will they start producing false positives?" "Does each test make simple and useful assertions?" "Don't accept complexity in tests just because they aren't part of the main binary." "Tests do not test themselves." https://google.github.io/eng-practices/review/reviewer/looking-for.html

## Khorikov, Unit Testing Principles, Practices, and Patterns

- Four pillars: protection against regressions, resistance to refactoring, fast feedback, maintainability. https://talon.one/blog/how-to-asses-the-value-of-a-unit-test **[S]** (secondary summary; book text not reachable, chapter PDF is chapter 1 only)
- First three are a CAP-style tradeoff: "we can't maximize all of them at the same time." Resistance to refactoring is binary, so it is the one to never trade away; the live tradeoff is protection versus speed. https://notesbylex.com/four-pillars-of-good-unit-tests and https://dzx.fr/blog/unit-testing-principles-practices-patterns/ **[S]**. The phrase "non-negotiable" is dzx.fr's paraphrase ("score a 0, so it is worthless"), not a verified Khorikov quote.
- Styles ranked by resistance to refactoring: output-based first, state-based second, communication-based worst because "the collaborations the SUT goes through in order to achieve its goal are not part of its public API." https://enterprisecraftsmanship.com/posts/styles-of-unit-testing/ (Khorikov's blog, primary)
- Observable behaviour: "What a controller saves in a private database is an implementation detail. What a controller writes to a message queue consumed by other applications is an observable behavior." Mocks only for unmanaged dependencies (external APIs, message buses). https://dzx.fr/blog/unit-testing-principles-practices-patterns/ **[S]**
- Skip trivial code: low complexity and few collaborators. Same URL **[S]**

## Fowler, Vocke, Spotify, Dodds

- Pyramid: "many more low-level UnitTests than high level BroadStackTests"; UI-driven tests are "brittle, expensive to write, and time consuming to run." https://martinfowler.com/bliki/TestPyramid.html (2012; predates honeycomb and trophy)
- Practical Test Pyramid: "Test for observable behaviour instead"; "Push your tests as far down the test pyramid as you can"; "If a higher-level test spots an error and there's no lower-level test failing, you need to write a lower-level test"; "If it becomes awkward to use real collaborators I will use mocks and stubs generously." https://martinfowler.com/articles/practical-test-pyramid.html
- Fowler on doubles: sociable by default; "I don't treat using doubles for external resources as an absolute rule." https://martinfowler.com/bliki/UnitTest.html
- Spotify honeycomb: "Having too many unit tests in Microservices ... restricts how we can change the code without also having to change the tests." Focus on integration tests, few implementation-detail tests, "even fewer Integrated Tests (ideally none)." https://engineering.atspotify.com/2018/01/testing-of-microservices/ **[O]**
- Dodds trophy: "Write tests. Not too many. Mostly integration." (attributed to Guillermo Rauch); static analysis at the base; "stop mocking so much stuff." https://kentcdodds.com/blog/write-tests **[O]**

## Metz, Magic Tricks of Testing

Slides (primary): https://speakerdeck.com/skmetz/magic-tricks-of-testing-railsconf. Grid of message origin by type:

| Message | Rule |
|---|---|
| Incoming query | Assert what it returns |
| Incoming command | Assert direct public side effects |
| Sent to self | Do not test; break only if it saves money in development |
| Outgoing query | Do not test or expect it |
| Outgoing command | Expect it is sent (mock), unless side effects are stable and cheap |

"Be a minimalist. Test. Everything. Once. Test the interface. Trust collaborators." **[O]**. The rule is mechanical only if the LLM can classify each call as query or command reliably, which usually works.

## Meszaros, xUnit Test Patterns (curl on xunitpatterns.com, raw text)

Fragile Test: "fails to compile or run when the SUT is changed in ways that do not affect the part the test is exercising"; four sensitivities: interface, behaviour, data, context. Overspecified Software: "tests describe how the software should do something, not what it should achieve ... characterized by the extensive use of Mock Objects." Remedy: "Use the Front Door First". http://xunitpatterns.com/Fragile%20Test.html

Smells most common in machine-written tests:

- Eager Test and Assertion Roulette: "hard to tell which of several assertions ... caused a test failure." http://xunitpatterns.com/Assertion%20Roulette.html
- Conditional Test Logic, including Production Logic in Test: expected values computed with `i+j`-style logic inside loops. http://xunitpatterns.com/Conditional%20Test%20Logic.html
- Obscure Test: Mystery Guest (cause and effect split across files), General Fixture, Irrelevant Information, Hard-Coded Test Data, Indirect Testing. http://xunitpatterns.com/Obscure%20Test.html
- Erratic Test and Slow Tests (time, randomness, network). http://xunitpatterns.com/Test%20Smells.html

## Shore and Feathers

- Shore, Testing Without Mocks: mock-style tests "tend to 'lock in' your dependencies, which makes structural refactorings difficult" and "have to be supplemented with broad tests." Replacement: narrow sociable tests plus Nullables ("production code with an 'off' switch"). Cost: "The patterns require you to modify your production code." https://www.jamesshore.com/v2/projects/nullables/testing-without-mocks **[O]**
- Feathers, characterization tests: "document your system's actual behavior, not check for the behavior you wish your system had." Start with a test named "x", dummy expected value, run, paste actual. Seams not covered in the fetched page. https://michaelfeathers.silvrback.com/characterization-testing **[O]**. Risk: this procedure is exactly how an LLM produces tautological tests, so it is only legitimate for legacy code with no spec.

## Where sources disagree

| Issue | Position A | Position B |
|---|---|---|
| Unit vs integration weighting | Google, Fowler: 80/15/5 pyramid | Spotify, Dodds: integration-heavy |
| Interaction tests | Google: avoid; Khorikov: only unmanaged deps | Metz: mock outgoing commands; Mockists: default |
| Mocks at all | Shore: none, use Nullables | Fowler: use when awkward |
| DRY in tests | Google: DAMP | Meszaros: Test Code Duplication is a smell (resolved by helpers that keep the test complete) |
| Private/internal classes | Metz, Vocke: don't test | Google TotT: test implementation-detail classes when complex |
| Test and implementation coupling | Google: unchanging tests | Khorikov: ranks styles instead of banning any |

## Rules an LLM test writer could follow mechanically

- Name each test for one behaviour; one logical assertion group per test.
- No conditionals, loops, or arithmetic that mirrors production code in the test body; use literal expected values.
- Never assert on private members, call order, or call counts of collaborators, except for outgoing commands to unmanaged dependencies.
- Do not mock the unit's own collaborators that are in-process and deterministic; use real ones or a fake.
- Inline all values that determine the outcome in the test; avoid Mystery Guest fixtures and irrelevant fixture detail.
- No sleeps, wall-clock reads, unseeded randomness, or network in small tests.
- Failure message states expected, actual, and parameters.
- Before finishing: mutate the code (flip a condition, drop a call) and confirm a test fails. Mechanical to run, and the closest proxy for the "would this fail if behaviour broke?" family.
- Characterization tests: label them as such in the name.

## Judgment calls that need context

- Which layer to test at (pyramid vs honeycomb), and what counts as the public API.
- Whether a collaborator is an unmanaged dependency, and whether a side effect is observable behaviour or implementation (Khorikov's database vs message queue example needs domain knowledge).
- Fake vs real vs Nullable when the real one is slow.
- Whether an outgoing command's side effects are "stable and cheap" enough to assert directly (Metz's exception).
- Whether trivial code is worth a test.
- Whether a pinned incidental behaviour (error text, ordering) is contract under Hyrum's Law.
- Whether the expected value in a characterization test is correct or merely current.

## Implications for a Claude Code test-writing skill

- Lead with the two-sided check from the Google review guide: fails when behaviour breaks, survives refactors. Make the model state, per test, which behaviour it pins.
- Put a short banned-pattern list first (private access, call-order asserts, logic in tests, mirror-the-implementation expected values); these are checkable by reading the diff.
- Include Metz's grid and Google's double hierarchy as a lookup, and require the model to name the dependency category before it reaches for a mock.
- Require a mutation-style self-check (break the code, see the test fail) as a verification step, since passing tests written by the same model that wrote the code prove little.
- Keep layer choice out of the skill body or give it as a project-level default read from the repo's existing tests; the canon has no consensus.
- Treat characterization tests as a separate mode with its own warning.

## Open questions

- No source measures how much brittleness comes from mocks versus other causes; claims are experience reports.
- Khorikov's book text was not directly reachable; "binary" and the CAP analogy are from summaries and should be checked against chapter 4 before quoting.
- Beck's Medium essay was blocked; any tradeoff beyond predictive-vs-fast is unsourced.
- Evidence on LLM-written tests specifically (smells, tautology rates) was not found in primary form; Zhao et al. (https://arxiv.org/abs/2607.22880) covers coverage and mutation correlation only, abstract read, not the paper.
- Judgment call: I treated Google's 80/15/5 as an empirical target; the book presents it as a guideline from Google's own practice.
