# install-doc-memory

A Claude Code skill that installs a docs-as-shared-memory system into any
GitHub repo: version-controlled docs as the durable memory shared by humans
and agents, a doc-map-driven **Doc Sync** PR check that fails pull requests
changing mapped code without its docs, calendar-driven freshness reviews with
a weekly overdue-docs issue, and two repo skills (**doc-sync**, **doc-review**)
for the write and review paths.

Its sibling, `../update-doc-memory/`, brings an already-installed repo up to
`../CHANGELOG.md`'s current version without clobbering repo-specific content.

## Use

This directory lives at `~/.claude/skills/install-doc-memory/` via the
`claude` dotfiles symlink, so in any repo tell Claude to "install the doc
memory system" (or invoke `/install-doc-memory`). `SKILL.md` is the install
procedure; `files/` holds the generic artifacts it copies in. Everything
repo-specific (the doc map, the docs themselves, the CLAUDE.md index) is
written during install; installed repos carry a `doc-memory-version` stamp
in `docs/README.md` frontmatter that `update-doc-memory` compares against
`../CHANGELOG.md`.

Manual install: follow the steps in `SKILL.md` by hand; every file in
`files/` is copy-pastable as-is.

## Evolving the system

Change the files in `files/`, append a `../CHANGELOG.md` entry with
migration notes, and bump `doc-memory-version` in `files/docs-README.md`.
Installed repos catch up by running `/update-doc-memory`.

## Design notes

- Capture is enforced at the PR gate, not by editor hooks: the merge gate
  covers humans, shell edits, and every agent, and cannot be bypassed by
  tooling choice.
- Review is calendar-driven because most memory docs assert external facts
  (vendor APIs, regulations) whose staleness never shows up in a repo diff.
- `docs/doc-map.tsv` is the single source of truth; the check, the skills,
  and humans all read the same file.
