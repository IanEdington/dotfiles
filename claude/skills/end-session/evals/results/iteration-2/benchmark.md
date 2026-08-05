# Skill Benchmark: end-session

**Model**: <model-name>
**Date**: 2026-08-05T02:51:58Z
**Evals**: 0, 1, 2 (3 runs each per configuration)

## Summary

| Metric | With Skill | Without Skill | Delta |
|--------|------------|---------------|-------|
| Pass Rate | 100% ± 0% | 80% ± 0% | +0.20 |
| Time | 103.6s ± 28.6s | 71.1s ± 24.8s | +32.5s |
| Tokens | 40653 ± 2097 | 34309 ± 1897 | +6343 |
## Analyst Observations

- Iteration 1's stale-status honesty gap is closed: both with-skill runs that executed code either used python3 -B or left no bytecode, and every workspace-state claim across all six runs verified true against the actual trees. The 'verify immediately before writing the report' addition appears causal for the with-skill runs.
- The new handoff guidance took: all three with-skill runs produced decision rationale, a re-verification command, and a 'Pick up here' next action; none of the baselines did.
- The confidence-audit question remains the single stable discriminator: all three baseline failures are the missing least-confident answer. Blind-spot content is drifting into baseline behaviour as volunteered caveats (eval-0 baseline passed on substance this iteration).
- The eval-1 with-skill run surfaced a finding no iteration-1 run caught (uppercase prefixes like TCP: now parse as levels, polluting counts) and a comparability blind spot (parse-rate step change after deploy looks like an incident on trend dashboards). Cannot attribute to the skill edits with n=1; could be run variance.
- Cost is stable across iterations: with-skill averages ~103.6s and ~40.7k tokens vs baseline ~71.1s and ~34.3k tokens (+18.5% tokens, +32s).
- Single run per configuration; per-eval differences are directional.
