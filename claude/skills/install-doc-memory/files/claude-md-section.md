<!-- Add this section to the target repo's CLAUDE.md (and symlink AGENTS.md
to CLAUDE.md if the repo has no AGENTS.md). Also add these two lines to the
repo's commands section, if it has one:

scripts/check-doc-sync.sh [<base>]    # did mapped code change without its docs?
scripts/check-doc-freshness.sh        # list overdue memory-doc reviews
-->

## Docs are shared memory

Version-controlled docs are how humans and agents share context across
ephemeral sessions. **`docs/README.md` describes the system; read it before
changing how docs work.** The working rules:

- **Before working in an area, read its docs.** `docs/doc-map.tsv` maps code
  areas to their docs; load only what the task needs.
- **After changing behaviour in a mapped area, update its docs in the same
  PR.** The Doc Sync check fails any PR that changes a mapped area without
  touching its docs; the **doc-sync** skill gives the guided path, and the
  `docs-not-needed` label overrides the check when a change genuinely has no
  doc impact.
- **Docs are reviewed on a schedule.** Frontmatter (`last-reviewed`,
  `review-interval-days`) drives a weekly workflow issue and
  `scripts/check-doc-freshness.sh`. To clear an overdue doc, run the
  **doc-review** skill.
