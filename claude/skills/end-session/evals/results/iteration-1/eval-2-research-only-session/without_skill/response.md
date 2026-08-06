# How `level_counts` handles malformed and lowercase-level lines

Everything hinges on the regex at `src/log_parser.py:4`:

```python
LINE_RE = re.compile(r"^(?P<ts>\S+) (?P<level>[A-Z]+) (?P<msg>.*)$")
```

**Malformed lines: silently dropped.** `parse_line` strips the line and matches it against `LINE_RE`; on no match it returns `None` (lines 8-11). `level_counts` only increments when `parse_line` returns a dict (`if parsed:` on line 18), so any line that doesn't fit the `<timestamp> <LEVEL> <message>` shape (empty lines, missing fields, wrong separators) contributes nothing. No error, no warning, no "unparsed" bucket. The total across all counts can therefore be less than the number of input lines with no visible signal.

**Lowercase levels: treated exactly like malformed lines.** The level group is `[A-Z]+`, uppercase ASCII only, and there's no case normalization anywhere (no `.upper()`, no `re.IGNORECASE`). So `2024-01-01 info disk full` fails the match and is dropped. Mixed case like `Info` also fails: the regex would match the leading `I` but then requires a space, and `n` follows, so the whole match fails. Lowercase levels aren't miscounted or normalized; they simply vanish.

Two caveats worth knowing, since both behaviours are implicit rather than designed-in:

- There's no whitelist of valid levels. Any all-uppercase second token counts, so `2024-01-01 FOO bar` happily creates a `FOO` bucket. "Malformed" only means "fails the shape", not "isn't a real level".
- Because dropping is silent, this function can't distinguish "no ERROR lines" from "the ERROR lines were formatted in a way we couldn't parse". If that matters for your use case, counting rejects would be a small, useful change, but per your request I've changed nothing.

# Session wrap-up

- **What happened**: read-only investigation of `parse_line`/`level_counts` in `src/log_parser.py`. No files were modified.
- **Repo state**: clean working tree on `main` at `8d5a55d` ("initial logtool"), no uncommitted changes, no stashes, nothing to push.
- **Open threads for next time (optional)**: decide whether unparseable lines should be counted or logged, and whether level matching should be case-insensitive with a known-level whitelist.

Nothing else pending. Have a good evening.
