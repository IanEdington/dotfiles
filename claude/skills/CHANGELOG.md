# doc-memory changelog

Each entry records a change to the doc-memory system together with the
migration an already-installed repo needs. The installed version is stamped
as `doc-memory-version` in a repo's `docs/README.md` frontmatter; the
**update-doc-memory** skill applies every entry newer than a repo's stamp,
oldest first. Every change to `install-doc-memory/files/` must append an
entry here and bump the version in `files/docs-README.md`.

## v4 (2026-07-18): as-of dating and in-doc contradiction repair

- Files: `files/docs-README.md` (Writing conventions),
  `files/claude-skills/doc-sync/SKILL.md`,
  `files/claude-skills/doc-review/SKILL.md`.
- External facts now carry an as-of date and source. doc-sync dates them at
  capture; doc-review refreshes the date on re-verification, and its step 3
  now compares claims to each other, collapsing appended updates into one
  current claim even when both copies are individually unverifiable.
- Migration: add the "Date external facts" paragraph to the repo's
  `docs/README.md` Writing conventions; refresh both repo skills from the
  bundle. Existing external facts pick up as-of dates as they come up for
  review; no bulk pass needed.

## v3 (2026-07-09): version stamping and the update skill

- Bundle: added `update-doc-memory/`, this changelog, and the
  `doc-memory-version` frontmatter key in `files/docs-README.md`.
- Migration: add `doc-memory-version: 3` to the repo's `docs/README.md`
  frontmatter, and add a sentence to its porting section noting that older
  installs are brought up to date with the update-doc-memory skill.

## v2 (2026-07-09): first-mention linking convention

- Files: `files/docs-README.md` (Writing conventions),
  `files/claude-skills/doc-sync/SKILL.md`,
  `files/claude-skills/doc-review/SKILL.md`.
- Migration: add the "Link on first mention" paragraph to the repo's
  `docs/README.md` Writing conventions; refresh both repo skills from the
  bundle (doc-review step 4 now treats unlinked mentions as missing
  content, and both conventions sections gain the linking rule).

## v1 (2026-07-08): initial system

- Docs as shared memory indexed from `CLAUDE.md`; `docs/doc-map.tsv` as the
  single source of truth; the Doc Sync PR check
  (`scripts/check-doc-sync.sh` + workflow) with the `docs-not-needed`
  override; calendar freshness (`last-reviewed` frontmatter,
  `scripts/check-doc-freshness.sh`, weekly `doc-review` issue workflow);
  the doc-sync and doc-review skills; the `AGENTS.md` symlink.
- Migration: none (initial install).
