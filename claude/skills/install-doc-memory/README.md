# install-doc-memory

A Claude Code skill that installs a docs-as-shared-memory system into any
GitHub repo: version-controlled docs as the durable memory shared by humans
and agents, a doc-map-driven **Doc Sync** PR check that fails pull requests
changing mapped code without its docs, calendar-driven freshness reviews with
a weekly overdue-docs issue, and two repo skills (**doc-sync**, **doc-review**)
for the write and review paths.

## Use

Symlink or copy this directory to `~/.claude/skills/install-doc-memory/`,
then in any repo tell Claude to "install the doc memory system" (or invoke
`/install-doc-memory`). `SKILL.md` is the install procedure; `files/` holds
the generic artifacts it copies in. Everything repo-specific (the doc map,
the docs themselves, the CLAUDE.md index) is written during install.

Manual install: follow the steps in `SKILL.md` by hand; every file in
`files/` is copy-pastable as-is.

## Design notes

- Capture is enforced at the PR gate, not by editor hooks: the merge gate
  covers humans, shell edits, and every agent, and cannot be bypassed by
  tooling choice.
- Review is calendar-driven because most memory docs assert external facts
  (vendor APIs, regulations) whose staleness never shows up in a repo diff.
- `docs/doc-map.tsv` is the single source of truth; the check, the skills,
  and humans all read the same file.
