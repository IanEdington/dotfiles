# Provenance

This skill is vendored third-party code, not authored in this repo. Nothing
here is local work, so treat the whole directory as replaceable: to update,
drop in a newer upstream copy wholesale rather than patching files
individually, and update this note in the same commit.

| | |
| --- | --- |
| Upstream | Anthropic `skill-creator`, exact source URL not recorded at import |
| Vendored | 2026-08-01, from a tarball supplied by the repo owner |
| Upstream file dates | 2026-07-24 (tarball member mtimes) |
| Tarball MD5 | `e7656f662412d0c457ba944884a32e30` |
| Licence | Apache 2.0, see `LICENSE.txt` |
| Local changes | None. Files are byte-identical to the tarball. |

## Version

Upstream ships no version number and this copy has no upstream ref to diff
against, so the tarball hash and the 2026-07-24 file dates above are the only
handle on which revision this is. If a later import needs a real comparison,
record the source URL and commit SHA at that point.

## Licence notes

`LICENSE.txt` is the stock Apache 2.0 text with the appendix boilerplate
unfilled, so it names no copyright holder, and the bundle carries no `NOTICE`
file or per-file copyright headers. Apache 2.0 section 4 obligations on
redistribution are therefore satisfied by keeping `LICENSE.txt` alongside the
code, which this directory does. This matters only if the skill is ever
redistributed beyond this dotfiles repo.
