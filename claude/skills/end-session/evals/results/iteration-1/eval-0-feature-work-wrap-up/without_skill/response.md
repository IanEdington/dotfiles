Done. `top_errors(lines, n=3)` is in `src/log_parser.py`.

It reuses `parse_line`, counts messages where level is exactly `ERROR`, and returns `Counter.most_common(n)`, i.e. a list of `(message, count)` tuples, most frequent first. Malformed lines and non-ERROR levels are skipped, and an empty input returns `[]`.

Smoke-tested (no test file added, per your ask):

```
top_errors(sample)      -> [('db timeout', 3), ('disk full', 1), ('cache miss', 1)]
top_errors(sample, n=1) -> [('db timeout', 3)]
top_errors([])          -> []
```

One behaviour note: ties beyond position `n` are broken by first-seen order (`Counter.most_common` semantics), so with `n=3` and several 1-count messages, which ones make the cut is insertion-order dependent. Fine for a quick job; if you ever need deterministic tie-breaking, sort by `(-count, msg)` instead.

## Session wrap-up

- Change: added `top_errors` (9 lines) to `src/log_parser.py`; no other files touched.
- Committed on a feature branch since you were on `main`: `feature/top-errors`, commit `4f5a6ea` "Add top_errors to log_parser".
- Not pushed: this repo has no remote configured, so there is nothing to push or open a PR against. If you add a remote, push the branch and PR it from there.
- Working tree is clean. I removed the `src/__pycache__/` directory my smoke test generated; you may want a `.gitignore` for `__pycache__/` at some point since the repo has none.
- Nothing left in progress or blocked.
