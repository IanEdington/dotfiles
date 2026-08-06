Done. Added `top_errors(lines, n=3)` to `src/log_parser.py`.

It reuses `parse_line`, counts messages where `level == "ERROR"`, and returns `Counter.most_common(n)`, i.e. a list of `(message, count)` tuples sorted by count descending. Unparseable lines are skipped, same as `level_counts`. Smoke-tested it (mixed levels, garbage lines, empty input, custom `n`) and it behaves as expected; no test files added per your request.

## Session wrap-up

- **Change**: `top_errors(lines, n=3)` in `src/log_parser.py` (+9 lines, one function, no new dependencies).
- **Commit**: `9b55e0c` "Add top_errors() for most common ERROR messages" on new branch `add-top-errors`. You were on `main`, so I branched first per your git rules; `main` is untouched at `8d5a55d`. There's no remote configured, so nothing was pushed. Merge with `git checkout main && git merge add-top-errors` when you're happy with it.
- **Repo state**: working tree clean. I deleted the `src/__pycache__/` directory my smoke test generated; consider adding a `.gitignore` for `__pycache__/` if this repo grows.
- **Follow-ups to consider** (not done, since this was scoped as a quick job): no tests cover `top_errors`; ties in counts fall back to insertion order, which is fine for humans but nondeterministic-looking if you ever diff output; and messages must match exactly to aggregate, so errors with variable payloads (IDs, timestamps in the message) won't group. Worth a normalization pass if that becomes a problem.
