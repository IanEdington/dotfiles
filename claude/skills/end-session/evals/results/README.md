# Eval run results

Evidence from the skill-creator test loop that produced this skill, kept
so future sessions can see exactly what the skill changed and judge
regressions against real prior outputs. Runs are from 2026-08-05 on the
claude-fable-5 model, one run per configuration per eval.

## Layout

- `iteration-1/`: initial SKILL.md draft.
- `iteration-2/`: after folding in community research and the
  verify-before-reporting fix (see HANDOFF.md for what changed and why).
- Each `iteration-N/<eval>/<config>/` holds:
  - `response.md`: the executor's full user-facing response, including
    its session wrap-up. The primary evidence.
  - `grading.json`: per-assertion verdicts with cited evidence, plus
    verified claims and eval feedback.
  - `timing.json`: wall clock and token usage for the run.
- `iteration-N/benchmark.{json,md}`: aggregates plus analyst
  observations. The observations are the most useful summary; read those
  first.

Configs: `with_skill` was pointed at SKILL.md and told to follow it;
`without_skill` got an identical prompt with no skill. Both ran against a
fresh sandbox seeded by `../sandbox/seed.sh` (with `--dirty` for eval 1).

## Headline numbers

| Iteration | With skill | Baseline | Skill cost |
|---|---|---|---|
| 1 | 15/15 assertions | 11/15 (73%) | +32s avg, +16% tokens |
| 2 | 15/15 assertions | 12/15 (80%) | +32s avg, +18% tokens |

Every baseline assertion failure in both iterations was a missing answer
to one of the two reflective questions, almost always the confidence
audit. Baselines handled git-state reporting and next steps well without
help. Treat per-eval differences as directional: n=1 per configuration.

## Reproducing

Grading was done against these assertions (see `../evals.json`) with
programmatic git-state verification of each sandbox after the run. The
interactive review viewers (review.html) were session artifacts and are
not committed; regenerate with skill-creator's
`eval-viewer/generate_review.py` against a reconstructed workspace if
needed.
