---
name: skill-create
description: Write a new Claude Code skill (SKILL.md plus bundled files) from a documented gap, then measure it. Use when the user wants to create, write, draft, or scaffold a skill, turn a workflow from this conversation into a skill, or capture repeated instructions as a reusable skill. Also use for a rewrite that changes what a skill does. For judging or fixing an existing skill without redesigning it, use skill-eval instead.
---

# skill-create

A skill earns its place by holding something the model cannot derive and firing when it should. Most bad skills fail one of those before a line of the body is written, so this workflow front-loads the checks and writes the body last. The rubric is `../skill-eval/references/checklist.md`; read it once now.

## Step 1: Prove the gap

Run the headline task with no skill, in a fresh subagent, exactly as the user would ask it. Write down the specific failures: wrong tool, missed convention, wrong format, skipped step. Save them to `<workspace>/gap.md`.

No failures means no skill. Say so and stop. The user may still want the workflow recorded, and the right home is then `CLAUDE.md` or a doc, not a skill.

## Step 2: Choose the home

| The knowledge is needed | Home |
|---|---|
| On every task in the repo | `CLAUDE.md` / `AGENTS.md` |
| Every time an event happens, no judgment | hook (`update-config`) |
| On a nameable request or recurring routine | skill (continue) |

Check the installed roster for an overlapping skill. If one exists, extend it or replace it; never add a sibling that shares its triggers.

## Step 3: Write the description first

Third person. What it does, then when to use it, in the words the user will actually type: the slash name, file types, tool names, the recurring event, casual synonyms. Add one clause naming the nearest thing it should not fire for. Budget is 1,024 characters; spend most of it on triggers.

Write the trigger queries now, while the description is fresh: 8 to 10 should-fire in the user's voice, 8 to 10 near-miss should-not, saved to `<workspace>/queries.json` in the format `../skill-eval/scripts/trigger_eval.py` expects.

## Step 4: Write the body

Target about 1,000 tokens. Every line should change a decision the no-skill run got wrong in Step 1; if a line does not map to a failure in `gap.md`, cut it. Then:

- One default path with an escape hatch, never a menu.
- Numbered steps; exact commands where the sequence is fragile, direction where it is not.
- A "done when" line: the verifiable end state.
- A validator to loop against where output quality matters (script, or a checklist file the skill reads).
- Reference material in files linked one level deep from `SKILL.md`, each over 100 lines opened with a table of contents. Mark each file *run* or *read*.
- Fully qualified MCP tool names.

Install it where it will live (`~/.claude/skills/<name>/` via dotfiles, or the repo's `.claude/skills/`).

## Step 5: Measure

Run `skill-eval` Steps 3 and 4 against the installed skill: trigger rate against the real roster, then three with/without evals built from `gap.md`. Cost is roughly 60 `claude -p` calls plus six subagent runs; say so before starting.

## Step 6: Iterate

One change per iteration, re-measured. Recall under 70% → rewrite the description and re-run `trigger_eval.py --description "<candidate>"`. Lift near zero → the body is not addressing the gap; go back to `gap.md`, do not add more text. Token ratio over 1.5x with small lift → cut.

Done when: recall ≥ 70% on should-fire, false positives ≤ 30% on near-misses, positive lift on all three evals, and the body still maps line-for-line to `gap.md`. Record the numbers in `<workspace>/report.md` so the next review has a baseline.
