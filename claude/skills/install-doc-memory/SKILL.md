---
name: install-doc-memory
description: Install the docs-as-shared-memory system into the current repo. Version-controlled docs become durable memory for humans and agents, enforced by a doc-map-driven Doc Sync PR check, scheduled freshness reviews, and doc-sync/doc-review skills. Use when asked to set up shared memory, doc sync, doc freshness, or an agent knowledge base for a repository.
---

# install-doc-memory: set up docs-as-shared-memory in a repo

Installs a self-contained system where version-controlled docs are the shared
memory of a repo: a `docs/doc-map.tsv` maps code areas to their docs, a PR
check fails any pull request that changes a mapped area without touching its
docs, frontmatter drives calendar-based freshness reviews, and two repo skills
(doc-sync, doc-review) give agents the guided write and review paths. The
installed `docs/README.md` documents the whole system for its new home.

Requirements: a git repo hosted on GitHub with Actions enabled. The scripts
are POSIX-ish bash and need only git and awk.

## Package layout

```
files/scripts/check-doc-sync.sh        capture check (PR + local)
files/scripts/check-doc-freshness.sh   review-overdue check (CI + local)
files/workflows/doc-sync-check.yml     Doc Sync PR check
files/workflows/doc-freshness.yml      weekly overdue-review issue
files/claude-skills/doc-sync/          repo skill: fold a change into docs
files/claude-skills/doc-review/        repo skill: full review of one doc
files/docs-README.md                   template for docs/README.md
files/claude-md-section.md             section to add to the repo's CLAUDE.md
files/doc-map.tsv                      empty map with format header
```

## Install steps

1. **Preflight.** Confirm you are at the root of a git repo with a GitHub
   remote. Note the default branch. Check for collisions before writing:
   existing `docs/README.md`, `docs/doc-map.tsv`, `.claude/skills/doc-sync/`,
   `.claude/skills/doc-review/`, or workflows with the same file names. If any
   exist, stop and ask how to reconcile instead of overwriting.
2. **Copy the mechanical files** from this skill's `files/` directory:
   - `files/scripts/*.sh` → `scripts/` (keep the execute bit;
     `chmod +x scripts/check-doc-*.sh`);
   - `files/workflows/*.yml` → `.github/workflows/`;
   - `files/claude-skills/doc-sync/` and `files/claude-skills/doc-review/` →
     `.claude/skills/`;
   - `files/doc-map.tsv` → `docs/doc-map.tsv`.
3. **Write the doc map.** Read the repo's layout and propose rules: one line
   per code area, tab-separated, mapping the area's code globs to its doc path
   or glob, with a third-column hint naming the doc(s) that usually take the
   update. Map only areas that have (or are getting) docs; an unmapped area is
   simply unenforced. Confirm the rules with the user before committing.
4. **Create `docs/README.md`** from `files/docs-README.md`, replacing the
   `TODAY` placeholder in the frontmatter with today's date (UTC). If the
   repo keeps docs somewhere other than `docs/`, adjust the paths here, in
   the map, and in both scripts consistently.
5. **Create or organize the memory docs.** For each mapped area, docs live in
   `docs/<area>/`. Prefer a few single-purpose docs over one long one; the
   standard set is a design doc, an integrations doc, a decision log, and an
   open-questions doc, but only create what the area actually needs. Add the
   two-line freshness frontmatter (`last-reviewed: <today>`,
   `review-interval-days: <n>`) to every memory doc: 30 to 60 days for
   fast-moving content, about 90 for design docs, 180 for stable reference.
6. **Wire the index.** Add the section from `files/claude-md-section.md` to
   the repo's `CLAUDE.md` (create a lean one if the repo has none), including
   the two command lines if the CLAUDE.md has a commands section. Add a
   knowledge-base list to CLAUDE.md: one line per memory doc saying when to
   load it. If the repo has no `AGENTS.md`, symlink it to `CLAUDE.md`.
7. **Verify.** `bash -n` both scripts; run `scripts/check-doc-freshness.sh`
   (expect exit 0 on fresh frontmatter). Test the sync check on a throwaway
   branch: commit a touch to a mapped code area, expect exit 1 with a hint;
   touch the mapped doc, expect exit 0; delete the branch.
8. **Deliver.** Commit on a feature branch and open a PR. In the PR body,
   note that the `docs-not-needed` label (Doc Sync override) does not exist
   until someone creates it or first applies it, and the `doc-review` label
   is created automatically by the weekly workflow. If Doc Sync should be
   blocking, remind the user to mark the check required in branch protection.

## Customization points

Adjust during install if asked; otherwise install as shipped:

- **Writing conventions** in the two repo skills and `docs-README.md`
  (spelling, punctuation, format rules) are a style choice; keep them
  consistent across all three files if changed.
- **Review intervals** and the weekly cron in `doc-freshness.yml`.
- **Label names** (`docs-not-needed`, `doc-review`); if renamed, update the
  workflow(s), `docs-README.md`, the doc-sync skill, and the CLAUDE.md
  section together.

## Hard rules

- This skill is the canonical source. Do not fork per-repo variants of the
  scripts or workflows; improve the skill and re-port.
- Enforcement stays at the PR gate. Do not reintroduce per-editor hooks
  (Stop/PostToolUse) as the enforcement mechanism; they miss shell edits,
  humans, and other tools, and they nag every turn.
