# How `level_counts` handles malformed and lowercase-level lines

Everything hinges on the regex at the top of `src/log_parser.py`:

```python
LINE_RE = re.compile(r"^(?P<ts>\S+) (?P<level>[A-Z]+) (?P<msg>.*)$")
```

`parse_line` strips the line, tries a full-anchored match, and returns `None` on failure. `level_counts` only increments the counter when `parse_line` returns a dict (`if parsed:`), so:

## Malformed lines

Silently skipped. Any line that does not match `<non-whitespace ts> <UPPERCASE level> <message>` with single literal spaces fails the regex, `parse_line` returns `None`, and the line contributes nothing to the counter. No exception, no warning, no "UNKNOWN" bucket. Lines that fail include:

- Missing fields, e.g. a bare message or a level with no timestamp
- Multiple spaces or tabs between fields (the separator is exactly one space)
- A level-only line like `2024-01-01 INFO` — the space before `msg` is mandatory, and `strip()` removes any trailing space, so a line with an empty message can never match
- Empty or whitespace-only lines

The one leniency is `line.strip()`: leading/trailing whitespace (including the trailing newline) is tolerated before matching.

## Lowercase level names

Treated exactly like malformed lines, i.e. silently dropped. `[A-Z]+` matches uppercase ASCII only and no `re.IGNORECASE` flag is set, so `2024-01-01 info started` fails to match entirely. Mixed case fails too: for `Info`, `[A-Z]+` matches `I` but the required space after the level is not next, so the whole match fails. There is no normalization step, so lowercase levels are not counted under their uppercase equivalents; they vanish.

## Consequences worth knowing (not changing anything, as requested)

- `sum(level_counts(lines).values())` can be less than the number of input lines, and the caller cannot tell "no ERROR lines" apart from "every line was malformed". If these logs ever mix producers (some emit `warn`/`Info`), those lines are silently lost, which could mask real error volume.
- If you ever want visibility, cheap options would be a dropped-line count or case normalization, but as it stands the behaviour is: parse strictly, drop silently.

# Session wrap-up

- **What happened:** Read-only review of `src/log_parser.py` to answer how `level_counts` treats malformed and lowercase-level lines. No code was modified.
- **Repo state:** Clean working tree on `main` at `8d5a55d` ("initial logtool"). Nothing staged, committed, or pushed.
- **Open follow-ups:** None required. If you pick this up later, candidate next steps are: tests pinning down the silent-drop behaviour, an optional case-insensitive mode, or surfacing a count of unparsed lines.

That closes out the session for today.
