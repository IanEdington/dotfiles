---
name: update-doc-memory
description: Bring a repo's installed doc-memory system up to the bundle's current version. Use when the doc-memory bundle has changed and the current repo carries an older install (an older doc-memory-version in docs/README.md frontmatter, or no stamp at all).
---

# update-doc-memory: migrate an older install

The doc-memory system is installed into repos by the sibling
**install-doc-memory** skill and evolves only in this bundle. This skill
applies what changed since a repo's install without clobbering the
repo-specific content the system holds (the doc map, the memory docs, the
CLAUDE.md index).

Sources, relative to this skill's directory:

- `../install-doc-memory/files/`: the current canonical files;
- `../CHANGELOG.md`: versioned changes, each with migration notes.

## Ownership rule

- **Skill-owned (overwrite from the bundle):** `scripts/check-doc-sync.sh`,
  `scripts/check-doc-freshness.sh`, both workflows, and the doc-sync and
  doc-review repo skills. Repos may deviate only at the documented
  customization points (label names, writing conventions, cron); those are
  re-applied on top of the new files, not preserved by keeping old ones.
- **Repo-owned (migrate by hand, never overwrite):** `docs/README.md`,
  `CLAUDE.md`, `docs/doc-map.tsv`, and every memory doc. These hold
  repo-specific content; apply the changelog's migration notes to them.

## Steps

1. **Find the installed version.** Read `doc-memory-version` from the repo's
   `docs/README.md` frontmatter. No key means the install predates
   versioning: infer the version by comparing the repo's files against the
   changelog entries, oldest first, and say what you inferred.
2. **List pending entries.** Every `../CHANGELOG.md` entry newer than the
   installed version, oldest first. None means the repo is current; stamp
   the version if missing (step 6) and stop.
3. **Detect local customizations** before touching skill-owned files: diff
   each against the bundle copy and note deliberate deviations at the
   documented customization points. Anything else that diverges is drift;
   flag it in your reply rather than silently keeping or discarding it.
4. **Overwrite skill-owned files** with the bundle copies, then re-apply the
   customizations from step 3. Keep the execute bit on the scripts.
5. **Migrate repo-owned files** by applying each pending entry's migration
   notes in order. Do not bump `last-reviewed` anywhere: an update is not a
   review.
6. **Stamp the version.** Set `doc-memory-version` in the repo's
   `docs/README.md` frontmatter to the bundle's current version (the newest
   changelog entry), adding the key if missing.
7. **Verify.** `bash -n` both scripts; run `scripts/check-doc-freshness.sh`;
   parse both workflow files. If `check-doc-sync.sh` itself changed, re-run
   the install skill's throwaway-branch test: commit a touch to a mapped
   code area (expect exit 1 with a hint), touch the mapped doc (expect exit
   0), then delete the branch.
8. **Deliver.** Commit on a feature branch and open a PR whose body lists
   the versions applied, the customizations re-applied, and any drift
   flagged in step 3.
