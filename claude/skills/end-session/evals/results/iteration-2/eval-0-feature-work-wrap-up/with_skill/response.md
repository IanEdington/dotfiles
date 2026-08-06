Added `top_errors(lines, n=3)` to `src/log_parser.py`. It reuses `parse_line`, counts messages only for lines whose level is exactly `ERROR`, and returns `Counter.most_common(n)`, a list of `(message, count)` tuples. Smoke-tested inline (not committed as a test, per your request): correct ordering, `n=1` truncation, and `[]` on empty input.

## Session wrap-up

### What happened
- Added `top_errors(lines, n=3)` to `src/log_parser.py` (9 lines). Same style as `level_counts`: iterate, `parse_line`, count into a `Counter`, then `most_common(n)`.
- Verified behaviour with a throwaway inline script against synthetic log lines, including unparseable garbage lines (skipped silently, matching existing behaviour).

### Least confident about
I only validated against synthetic single-line logs. Two things I did not verify against the ops team's real logs:
- Multi-line entries. `LINE_RE` drops continuation lines, so an ERROR followed by a stack trace counts once with only its first line as the message. The traceback lines are silently discarded, same as `level_counts` today, but for `top_errors` the message text matters and I never confirmed real entries are single-line.
- I assumed the level token is exactly `ERROR`. `FATAL`, `CRITICAL`, or `ERR` variants are excluded, and I have no evidence about which your logs actually use.

### What you're probably missing
`top_errors` keys on the exact message string. Real error messages usually embed variable parts (request IDs, durations, hostnames), so "db timeout after 512ms" and "db timeout after 730ms" count as two distinct errors, fragmenting counts and making the "top" list misleading on production logs. If your messages are not stable strings, you will want normalization (strip numbers/IDs) before this function is trustworthy. Worth checking against one real log file before anyone relies on it.

Smaller footgun: `top_errors` and `level_counts` each fully consume their input. If anyone extends `report.summary` to call both on the same generator (e.g. a file handle), the second call silently gets nothing and returns empty. Pass a list, or read the file twice.

### Workspace state
- `src/log_parser.py` modified, uncommitted, on `main` (only change; `git diff --stat`: 1 file, +9).
- No remote configured on this repo, so nothing to push.
- Working tree otherwise clean; the smoke test wrote no bytecode or temp files into the repo.
- To commit: `git add src/log_parser.py && git commit -m "Add top_errors to log_parser"`

### Lessons to persist
None this session. Short, single-function change; no corrections or non-obvious project discoveries worth a CLAUDE.md line.

### Handoff
- Outcome: `src/log_parser.py` gained `top_errors(lines, n=3)` returning `[(message, count), ...]` for the n most common ERROR messages. Uncommitted on `main`.
- Decisions: reused `parse_line` and matched the existing `level_counts` loop style rather than adding a separate ERROR regex; exact-string message counting, no normalization (user asked for a quick job). No tests, at the user's explicit request.
- Open threads: commit is pending; message normalization and multi-line log handling are known gaps, deliberately deferred.
- To verify: from the repo root run `python3 -c "import sys; sys.path.insert(0,'src'); from log_parser import top_errors; print(top_errors(['t ERROR a','t ERROR a','t ERROR b','t INFO x']))"` and expect `[('a', 2), ('b', 1)]`.
- Pick up here: commit `src/log_parser.py`, then decide whether `top_errors` needs message normalization by running it against one real ops log file.
