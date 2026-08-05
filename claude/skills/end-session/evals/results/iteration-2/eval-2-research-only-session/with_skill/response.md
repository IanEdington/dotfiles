## How `level_counts` handles malformed and lowercase lines

`level_counts` (src/log_parser.py:14) delegates all parsing to `parse_line`, which strips the line and matches it against:

```python
LINE_RE = re.compile(r"^(?P<ts>\S+) (?P<level>[A-Z]+) (?P<msg>.*)$")
```

`parse_line` returns `None` on any non-match, and `level_counts` skips those via `if parsed:`. So both cases collapse into the same behaviour:

- **Malformed lines are silently dropped.** No exception, no warning, no "unknown" bucket, no count of how many were skipped. I verified by running the code: `'garbage line without structure'`, `''`, and `'ERROR no timestamp'` all return `None` and contribute nothing to the Counter.
- **Lowercase (and mixed-case) levels are treated as malformed.** `[A-Z]+` matches uppercase ASCII only and there is no `.upper()` normalization anywhere. `'... info msg'` and `'... Info msg'` both fail the match entirely (the regex can't take just the `I` because a literal space must follow the level), so they are silently excluded rather than counted under `INFO`.

Two side effects worth knowing, both confirmed by execution:

- Any uppercase token in the second position counts as a level: `'2024-01-01 TODO fix this'` produces `Counter({'TODO': 1})`. The regex validates shape, not vocabulary.
- A line with a level but no message (`'2024-01-01T00:00:00 WARNING'`) is dropped, because the regex demands a literal space after the level and `.strip()` removes any trailing one. That is arguably a bug rather than a design choice.

Net: the function optimizes for never crashing, at the cost of silently undercounting whenever the input drifts from the exact `ts LEVEL msg` single-space format.

## Session wrap-up

### What happened
Read-only analysis of `level_counts` and `parse_line` in src/log_parser.py, verified by executing the module against nine edge-case lines (lowercase, mixed case, missing timestamp, missing message, empty string, leading whitespace, fake level). No code was changed.

### Least confident about
The parsing claims above are all verified by execution, so the strongest remaining assumption: I claimed the separator must be a single ASCII space, meaning tab-delimited or column-aligned (multi-space) logs would be dropped wholesale. That follows from the literal `' '` in `LINE_RE`, but I never ran a tab- or double-space-separated line through it. If your real logs are tab-delimited, check that case first.

### What you're probably missing
`level_counts` cannot distinguish "this log has no ERROR lines" from "this log's format doesn't match the regex at all". If a producer emits lowercase levels, tabs, or a slightly different timestamp shape, you get a plausible-looking Counter that silently omits everything, with zero signal. If these counts feed anything decision-making (alerting, dashboards), the cheap fix is to also count skipped lines and expose that number; a zero-match rate is the tell that the format drifted. The empty-message drop is the other trap: `'... WARNING'` with no message text vanishes from the counts.

### Workspace state
Clean. `main` at 8d5a55d ("initial logtool"), no uncommitted changes, no untracked files (I ran the verification with `python3 -B`, so no `__pycache__` was left behind), no stash, nothing to push.

### Lessons to persist
None this session. A short read-only Q&A; nothing rose to CLAUDE.md level.

### Handoff
Nothing is mid-flight; the repo is untouched. If the next session acts on this analysis, the first concrete step is: "Add tests to src/log_parser.py capturing current behaviour (malformed skipped, lowercase skipped, level-with-empty-message skipped, TODO counted as a level), then decide whether to normalize case with `.upper()`, make the trailing message optional, and return or log a skipped-line count." To re-confirm the behaviour before trusting this summary, run the module against those same edge-case lines with `python3 -B`.
