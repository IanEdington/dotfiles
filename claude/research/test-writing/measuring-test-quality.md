# Measuring test quality: what each metric predicts and what to trend

Which test-quality metric can an LLM test writer and a review agent be held to, what does the empirical record say each metric predicts about fault detection, and which metrics should a team trend to see whether test quality improves across a project? All sources accessed 2026-10-07.

## Core findings

1. **Coverage is a weak target once suite size is controlled.** Inozemtseva and Holmes (31,000 suites, five Java systems up to 724,000 LOC) found "a low to moderate correlation between coverage and effectiveness when the number of test cases in the suite is controlled for"; for Joda Time, Kendall τ fell from 0.80 to 0.85 to "essentially zero". Kochhar et al. (100 Java projects) found "an insignificant correlation" between coverage and post-release bugs at project level and none at file level. **[E]** [1][2]
2. **The size-control debate is unresolved, so treat coverage as a floor.** Gopinath et al. (1,254 projects) found statement coverage predicts mutation kills across projects (R² = 0.9392). Chen et al. argue the random-selection method behind finding 1 "is flawed" and conclude "mutation-based test selection is most effective when employed after coverage has exhausted its usefulness". **[E]** [3][4]
3. **Mutants are coupled to real faults.** Just et al.: coupling for 73% of 357 real faults. Google: mutants coupled to 70% (1,043 of 1,502) of high-priority bugs. Papadakis et al. counter that correlations are "weak when controlling for test suite size", yet top-ranked suites by mutation score still detect significantly more faults. **[E]** [5][6][7]
4. **Surfacing mutants changed developer behaviour; surfacing coverage did not.** At Google, test hunks added during review had a median of 1 for mutation versus 0 for coverage; test hunks rose with mutant exposure (rs = 0.9) but not coverage exposure (rs = −0.24); mutant survivability fell with exposure (rs = −0.50). Hiding coverage in 30k reviews found "no evidence that showing code coverage during code review improves coverage". **[E]** [6][8]
5. **Mutation testing is only usable diff-scoped and filtered.** Google's median mutants per changelist: 820 (all operators), 77 (one per line), 7 (one per line, arid nodes excluded). Suppression cut unproductive mutants from 85% to 11%; 82% of mutants with feedback were labelled productive. **[E]** [9]
6. **Coverage hides unasserted code.** Pseudo-tested methods (covered, but no test fails when the body is removed) averaged 11.41% of covered methods under unit tests and 35.48% under system tests; Vera-Pérez et al. found them in all 21 projects (1% to 46%), though fewer than 30% of a 101-method sample merited a new test. **[E]** [10][11]
7. **Flakiness erodes trust in red builds.** Google: "about 1.5% of all test runs" flaky, "almost 16% of our tests have some level of flakiness", and "about 84% of the transitions we observe from pass to fail involve a flaky test". Luo et al.: 45% async wait, 20% concurrency; 78% of flaky tests are flaky when first written. **[E]** [12][13]
8. **LLM-written suites break the usual correlations within a model.** Across 8,268 LLM-generated suites on Defects4J, intra-model coverage-to-mutation correlations "cluster tightly around zero"; inter-model, mutation score to real-bug detection was r = 0.863. Coverage measured on buggy code "is not informative of whether the generated tests detect that bug". **[E]** [14]

## Metric comparison

| Metric | What it measures | Predicts fault detection? | Cost | Gaming risk | Gate for an LLM test writer? |
|---|---|---|---|---|---|
| Project coverage | Code executed by any test | Low to moderate after size control [1]; not post-release bugs [2] | Low | High: no-assert execution | **No.** Trend only |
| Changed-line coverage | Execution of the diff | Changed-untested code holds most field bugs [15] | Low | High | **Partial.** Floor, not sufficient |
| Full mutation score | Oracle strength, whole codebase | 73% / 70% coupling [5][6]; weak after size control [7] | Very high | Medium: change-detector tests | **No.** Too slow |
| Diff-scoped mutation | Oracle strength on changed lines | Behaviour change and coupling at Google [6][9] | Moderate (median 7 mutants per change) | Medium | **Yes**, with a "not useful" escape |
| Extreme mutation (pseudo-tested) | Whether any test notices a method's effects vanishing | Pseudo-tested methods have lower mutation scores [11] | Low (about one mutant per method) | Low | **Yes.** Cheapest oracle check |
| Checked coverage | Statements feeding checked values | "More sensitive than mutation testing" [16] | High; no mainstream tooling | Low | **No.** No tooling |
| Assertion count and coverage | Oracle quantity | Assertion coverage: τ 0.88 to 0.91 with mutation score on sampled suites [17] | Trivial | Very high | **No.** Review hint only |
| Test smells | Test design patterns | Smelly tests: production code "71% more likely to contain defects" [18]; detectors misfire on generated tests [19] | Low | Medium | **No.** Noisy |
| Flaky rate (PFS) | Nondeterminism | Masks real failures [12] | Low with rerun history | Low | **Yes.** New tests must pass reruns |
| Escaped defects, change failure rate | Delivery outcome | Ground truth but lagging and confounded | Low, slow | Low | **No.** Too lagging |

## Coverage

- Inozemtseva & Holmes, ICSE 2014: coverage "should not be used as a quality target"; decision and MC/DC coverage added no insight over statement coverage. Effectiveness was measured with mutants. **[E]** https://www.cs.ubc.ca/~rtholmes/papers/icse_2014_inozemtseva.pdf
- Ivanković et al., ESEC/FSE 2019: coverage for one billion lines daily; Google "does not enforce any code coverage thresholds across the entire codebase"; voluntary levels are project 60/75/90% with changelist 70/80/90%; safety-critical projects use mutation testing. **[E]** https://homes.cs.washington.edu/~rjust/publ/google_coverage_fse_2019.pdf
- Google Testing Blog 2020: 60% "acceptable", 75% "commendable", 90% "exemplary"; "per-commit coverage goals of 99% are reasonable, and 90% is a good lower threshold". **[O]** https://testing.googleblog.com/2020/08/code-coverage-best-practices.html
- Kochhar et al. 2017 **[E]** https://www.microsoft.com/en-us/research/publication/code-coverage-and-post-release-defects-a-large-scale-study-on-open-source-projects/ ; Gopinath et al. 2014 **[E]** https://agroce.github.io/icse14.pdf ; Chen et al. 2020 **[E]** https://rahul.gopinath.org/resources/ase2020/chen2020revisiting.pdf

## Mutation testing

- Theory: competent programmer hypothesis (real faults are small deviations from correct code) and coupling effect (tests that detect simple faults detect complex ones; Offutt, TOSEM 1992).
- Just et al., FSE 2014: 357 faults, 230,000 mutants; 17% of faults coupled to no mutant, 10% need new or stronger operators. **[E]** https://homes.cs.washington.edu/~rjust/publ/mutants_real_faults_fse_2014.pdf
- Petrović & Ivanković, ICSE-SEIP 2018: mutants surfaced in code review, about 6,000 engineers, about 30% of diffs with coverage. Its 75% usefulness rate came via Beller et al. (Facebook); PDF mirrors failed. **[S]** https://research.google/pubs/state-of-mutation-testing-at-google/
- Petrović et al., TSE 2021: 24,000+ developers, 760,000 changes, about 17 million mutants generated, 2 million reported; arid-node heuristics lifted productivity "from about 15% to 80%", later 89%. **[E]** https://homes.cs.washington.edu/~rjust/publ/practical_mutation_testing_tse_2021.pdf
- Petrović et al., ICSE 2021: 14,730,562 mutants over 662,584 changes; reviewers' fix-request rate on mutants declines with exposure (rs = −0.34); over 90% of lines have a mutant majority fate of 100%, which justifies one mutant per line. **[E]** https://homes.cs.washington.edu/~rjust/publ/mutation_testing_practices_icse_2021.pdf
- Beller et al. (Facebook, 2021): over half of 15,000+ pattern-based mutants survived; "almost half" of 26 developers would act on the mutant shown. **[E]** https://arxiv.org/pdf/2010.13464
- Foster et al. (Meta ACH, FSE Companion 2025): LLM writes targeted mutants, then tests that kill them; 9,095 mutants, 571 tests, 73% accepted by engineers; LLM equivalent-mutant detector precision 0.79, recall 0.47. **[E]** https://arxiv.org/pdf/2501.12862
- Tooling: PIT incremental analysis (marked experimental) reuses results when class and killing test are unchanged; Stryker's incremental example reused 3,731 results and ran 234; mutmut "only re-tests mutants in functions whose source changed"; cargo-mutants `--in-diff` "tests only mutants that overlap with regions changed in the diff", and its FnValue operator replaces whole function bodies, which is extreme mutation. cosmic-ray documents no diff mode. **[O]** https://pitest.org/quickstart/incremental_analysis/ , https://stryker-mutator.io/docs/stryker-js/incremental/ , https://mutmut.readthedocs.io/en/latest/ , https://mutants.rs/in-diff.html

## Flaky tests

- Micco, Google 2016: "It is quite common to ignore legitimate failures in flaky tests due to the high number of false-positives." **[E]** https://testing.googleblog.com/2016/05/flaky-tests-at-google-and-how-we.html
- Luo et al., FSE 2014: 201 commits, 51 projects; 24% of fixes changed the code under test, and 94% of those fixed a real bug, so deleting flaky tests discards signal. **[E]** https://huang.isis.vanderbilt.edu/cs8395/paper/flakytest.pdf
- Meta PFS, 2020: probability a test fails when it could have passed on the same code, estimated by Bayesian inference from existing runs; trended per test; deteriorating tests file tickets and lose eligibility for change-based selection; baseline "well below 1 percent" for unit tests, up to 10% for some end-to-end frameworks. **[E]** https://engineering.fb.com/2020/12/10/developer-tools/probabilistic-flakiness/
- Palomba & Zaidman's "54% of flaky tests contain a test smell" (ICSME 2017) is reported as withdrawn for analysis errors; avoid it. **[S]** (search-result summary; publisher notice not checked)

## Defect-based metrics

- Eder et al. (CQSE), AST 2013, 14 months at Munich Re: only 44% and 45% of changed methods were tested per release; changed-untested methods held 43% and 40% of field bugs. Only 23 and 10 bugs; the authors call this "too small to derive generalizable results". **[E]** https://www.cqse.eu/publications/2013-did-we-test-our-changes-assessing-alignment-between-tests-and-development-in-practice.pdf
- Juergens & Pagano, "Change-Driven Testing" (2019): "over 70% of the reported field bugs" traced to untested changes, which are "five times more likely to contain mistakes" (citing a CQSE whitepaper). Vendor-authored. **[O]** https://teamscale.com/hubfs/Publications/2019-change-driven-testing-springer-english.pdf
- DORA 2024 change failure rate: elite 5%, high 20%, medium 10%, low 40%. Delivery outcome, not attributable to tests. **[S]** (Octopus Deploy summary) https://octopus.com/blog/2024-devops-performance-clusters
- Test-to-fix ratio, escaped-defect rate, and time-to-detect: no study found linking them to test quality.

## Other proposals

- Checked coverage (Schuler & Zeller, ICST 2011): statements whose values reach an oracle, via dynamic slicing; seven projects. **[E]** https://www.st.cs.uni-saarland.de/publications/files/schuler-icst-2011.pdf
- Assertions (Zhang & Mesbah, FSE 2015): 6,700 suites, 24,000 assertions; assertion count "strongly correlates" with effectiveness. **[E]** https://people.ece.ubc.ca/amesbah/resources/papers/fse15.pdf
- Test smells: Spadini et al. (ICSME 2018, 221 releases, 10 systems) found smelly tests more change- and defect-prone. Panichella et al. (EMSE 2022) hand-labelled generated tests: Grano et al.'s tool reported Assertion Roulette in 74% of EvoSuite tests versus 17% on manual validation. **[E]** https://pure.tudelft.nl/ws/files/46651094/main.pdf , https://pure.tudelft.nl/ws/portalfiles/portal/137994226/s10664_022_10207_5.pdf
- Productive Coverage (Google, ICSE-SEIP 2024) flags only uncovered code resembling tested or production-hot code. **[E]** https://homes.cs.washington.edu/~rjust/publ/productive_coverage_icse_2024.pdf

## What to trend over a project and why

The only published evidence that surfacing a metric changed outcomes is Google's mutation data (finding 4); coverage display alone did not move coverage [8]. Trend, in priority order:

1. **Surviving productive mutants per merged change** (diff-scoped, arid-filtered, one per line). Goal is a falling trend, not zero. Also trend the "not useful" rate.
2. **Pseudo-tested methods in changed code.** Cheap, few false positives, catches assertion-free tests.
3. **Changed-line coverage**, gated at 90% with documented exemptions. Trend project coverage only for regressions.
4. **Flakiness**: PFS, or failed-then-passed-on-rerun rate per test on the same commit.
5. **Escaped defects with a test-gap label**: per production bug, record whether the faulty line was uncovered, pseudo-tested, or covered with a surviving mutant. This shows which metric failed.

Do not trend whole-codebase mutation score: it moves with suite size and operator choice [7] and is too costly per commit.

## Implications for a Claude Code test-writing skill and a review agent

- Gate the writer on changed-line coverage of 90% or more, zero pseudo-tested methods in changed code, and no surviving diff-scoped mutant without a written "not useful" reason. Coverage alone is gamed by assertion-free tests.
- Extreme mutation is the practical cheap gate: about one mutant per method, low gaming risk, and aimed at weak oracles. Use Descartes on the JVM and cargo-mutants on Rust; for JS/TS and Python, approximate it by restricting Stryker or mutmut to changed files. Judgement call: I found no published cost benchmark of Descartes against PIT's default engine.
- Diff-scoped conventional mutation is a practical second tier in CI on the PR, not in the agent's inner loop; Google's median of 7 mutants per change shows cost is bounded once arid code (logging, configuration, collection capacities) is suppressed.
- The review agent should post surviving mutants as review comments and reject change-detector tests written to kill unproductive mutants (Google's example: asserting `ArrayList` capacity).
- LLM tests derived from current code inherit its bugs [14]. The skill should derive assertions from the spec, issue, or docstring, and the reviewer should check at least one assertion per test against that source rather than observed output.
- Require new tests to pass repeated reruns (for example 10) and ban sleeps and real clocks: async wait and concurrency cause 65% of flakiness [13].
- Do not gate on assertion density or smell detectors: both are gamed or misfire on generated tests [19].

## Open questions

- No causal evidence yet that coverage reduces bug introduction; Schulte & Fraser's 2026 registered report (arXiv 2602.03585) has no results.
- Whether Google's behaviour change transfers to an LLM author, which does not learn across changes unless survivors are fed back.
- Extreme mutation versus arid-filtered diff mutation on the same changes: no head-to-head study found.
- Whether Zhao et al.'s finding holds outside Java and Defects4J.

## References

[1] Inozemtseva & Holmes 2014. [2] Kochhar et al. 2017. [3] Gopinath et al. 2014. [4] Chen et al. 2020. [5] Just et al. 2014. [6] Petrović et al. 2021 (ICSE). [7] Papadakis et al. 2018, https://coinse.github.io/publications/pdfs/Papadakis2018hi.pdf. [8] Ivanković et al. 2024. [9] Petrović et al. 2021 (TSE). [10] Niedermayr et al. 2016, https://arxiv.org/pdf/1611.07163. [11] Vera-Pérez et al. 2019, https://arxiv.org/pdf/1807.05030. [12] Micco 2016. [13] Luo et al. 2014. [14] Zhao, Zhou & Cohen 2026, https://arxiv.org/html/2607.22880. [15] Eder et al. 2013. [16] Schuler & Zeller 2011. [17] Zhang & Mesbah 2015. [18] Spadini 2018 (FSE doctoral symposium summary of the ICSME study). [19] Panichella et al. 2022.
