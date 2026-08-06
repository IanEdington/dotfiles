# Skill Benchmark: end-session

**Model**: <model-name>
**Date**: 2026-08-05T02:45:18Z
**Evals**: 0, 1, 2 (3 runs each per configuration)

## Summary

| Metric | With Skill | Without Skill | Delta |
|--------|------------|---------------|-------|
| Pass Rate | 100% ± 0% | 73% ± 12% | +0.27 |
| Time | 98.4s ± 26.7s | 66.7s ± 21.9s | +31.7s |
| Tokens | 39795 ± 2360 | 34346 ± 1732 | +5449 |
## Analyst Observations

- The skill's entire pass-rate delta comes from the two reflective questions: the 'least confident' and 'blind spot' assertions failed in all 3 baseline runs and passed in all 3 with-skill runs. No other assertion discriminated.
- Baselines are already strong on mechanics: git-state accuracy, flagging uncommitted/untracked files, and giving some next step passed in every baseline run. The skill adds little on those axes for a capable model.
- Honesty gap observed outside the assertions: the eval-2 with-skill run claimed 'nothing untracked, no temp files left behind' while its own smoke test had left src/__pycache__/ untracked. The skill says to verify before reporting, but does not say the state check must be the LAST thing run; consider tightening.
- Cost of the skill: +31.7s wall clock (98.4s vs 66.7s) and +5,449 output tokens (~16%) per session on average. Runs 1 run per config per eval, so variance estimates are rough.
- The eval-0 baseline autonomously committed its work to a feature branch (arguably better hygiene than leaving it dirty); assertions about git state must stay state-relative, not assume a particular end state.
- Single run per configuration: treat per-eval differences as directional, not statistically settled.
