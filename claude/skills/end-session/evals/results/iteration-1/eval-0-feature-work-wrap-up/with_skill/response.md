Added `top_errors(lines, n=3)` to `src/log_parser.py`. It reuses `parse_line`, counts messages where level is exactly `ERROR`, and returns `Counter.most_common(n)` as a list of `(message, count)` tuples. Smoke-tested it inline: correct ordering, `n=1` truncation, and empty input returning `[]`.

## Session wrap-up

### What happened
- Added `top_errors(lines, n=3)` to `src/log_parser.py` (9 lines), matching the existing `level_counts` style.
- No tests written, per your request. I did run a one-off smoke test with synthetic lines, which passed.

### Least confident about
Message-equality as the grouping key in `top_errors`. I count raw `msg` strings, so errors with variable parts ("db timeout for request 8f3a" vs "db timeout for request 9c2b") count as separate messages. If your real logs interpolate ids, durations, or hostnames into error messages, `top_errors` will surface the most literally-repeated string, not the most common error class, and the true top error can be missing from the result entirely. I never ran it against a real log file from this project because the repo contains none.

### What you're probably missing
`top_errors` and `level_counts` each iterate `lines` independently. If you pass a generator or an open file object and call both, the second call silently returns empty because the iterator is exhausted. Nothing in the module guards against this. Either document that callers must pass a list, or refactor both functions to share one parsing pass. Also worth knowing: multi-line entries such as stack tracebacks do not match `LINE_RE`, so continuation lines are silently dropped by every function in this module, not just the new one.

### Workspace state
- `src/log_parser.py`: modified, uncommitted, on `main`.
- `src/__pycache__/`: untracked, a byproduct of my smoke test. There is no `.gitignore` in this repo.
- No git remote is configured, so nothing to push and no PR to open.
- To commit: `git add src/log_parser.py && git commit -m "Add top_errors to log_parser"`. Consider `echo "__pycache__/" > .gitignore` while you are at it.

### Lessons to persist
None this session. Short task, no corrections, nothing non-obvious about the project surfaced.

### Handoff
- Outcome: `log_parser.py` now has `parse_line`, `level_counts`, and `top_errors`. Only `top_errors` changed this session.
- Open threads: the change is uncommitted; no tests exist for the module (deliberately deferred); the generator-exhaustion and message-normalization issues above are unaddressed.
- First action next time: commit the change, then decide whether `top_errors` should normalize messages (for example, strip trailing digits/hex tokens) before counting; that decision changes the function's contract, so make it before anyone depends on the current output.
