---
name: skill-eval
description: Evaluate an existing Claude Code skill and return a verdict (keep, fix description, fix body, or delete) backed by measurement. Use when the user asks whether a skill is worth keeping, why a skill is not triggering or not helping, to audit, benchmark, grade, or review a SKILL.md, to check a skill against the research checklist, or to measure a skill's lift and trigger rate. Not for writing a new skill from scratch; use skill-creator or write it by hand, then run this.
---

# skill-eval

Produce a verdict on one installed skill. Two independent things can be wrong: it never fires, or it fires and adds nothing. The workflow gates on the cheap checks first and only spends tokens on measurement for a skill that has earned it.

Read `references/checklist.md` once at the start. It is the rubric for every step below; `RESEARCH.md` holds the evidence behind it and is only needed when a verdict is contested.

## Step 1: Gate A, should this be a skill at all

Answer each checklist section A item from the skill's files and, where needed, one quick no-skill run of its headline task. Stop here with a verdict if any fails:

| Failure | Verdict |
|---|---|
| Nothing the model cannot derive | delete |
| Knowledge every task in the repo needs | move to `CLAUDE.md` |
| Must run on every event, not on request | move to a hook |
| Another installed skill overlaps | merge or delete one |

Stopping here is the normal outcome for a bad skill. Do not proceed to measurement to "give it a chance".

## Step 2: Static review, sections B to D

Score sections B, C, and D against the files. Record each unchecked box with a one-line fix. Note the body's line count and rough token count. Do not fix anything yet; a static pass is a list of hypotheses that Step 3 and Step 4 confirm or refute.

## Step 3: Trigger rate against the real roster

Write 8 to 10 should-trigger and 8 to 10 should-not-trigger queries to `<workspace>/queries.json`, formatted per `scripts/trigger_eval.py`. Should-trigger queries must be substantive tasks in the user's own words, with file names, context, and casual phrasing; one-line requests rarely trigger any skill and test nothing. Should-not queries must be near misses that share vocabulary with the skill; obviously unrelated queries are wasted runs.

Run from the project root where the skill is installed, so it competes with every other skill the user has:

```bash
python <this-skill>/scripts/trigger_eval.py \
  --skill-path <path-to-skill> --eval-set <workspace>/queries.json \
  --project-root <repo> --runs 3 --json <workspace>/trigger.json
```

Cost: queries x runs `claude -p` calls (about 60). Say so before running. To test a rewritten description without editing the file, pass `--description "<candidate>"`; the script swaps it in for the run and restores the original.

Recall below 70% on should-trigger means the description is the problem regardless of anything else. False positives above 30% mean the description over-claims.

## Step 4: Lift, with and without

Write three eval tasks from the gate A failures, each a real task the user would give, with 3 to 6 verifiable assertions. Save as `<workspace>/<eval-name>/eval.json`:

```json
{"prompt": "...", "assertions": ["..."], "files": []}
```

For each eval, spawn two subagents in the same turn, one told to use the skill (give it the path) and one with no mention of it. Both save outputs to `<workspace>/<eval-name>/<arm>/outputs/` and a transcript to `<arm>/transcript.md`. When each finishes, write `total_tokens` and `duration_ms` from its completion notice to `<arm>/timing.json`; that data is not available later.

Grade every arm with a fresh subagent that reads `agents/grader.md`. Then:

```bash
python <this-skill>/scripts/lift_report.py <workspace>
```

## Step 5: Verdict

Combine into one table and a verdict, in this order of precedence:

1. Gate A failed → the Step 1 verdict.
2. Recall under 70% → **fix description**. Propose the rewrite, re-run Step 3 with `--description`, and report both numbers.
3. Lift within a few points of zero, or negative → **fix body** if the static review found concrete gaps, otherwise **delete**; the model already does this.
4. Token ratio above 1.5x with small lift → **fix body**, cut to the lines that changed the decision.
5. Otherwise → **keep**, and record the numbers so the next review can compare.

Report the trigger table, the lift table, the unchecked checklist boxes with fixes, and the verdict. Write it to `<workspace>/report.md` and give the user the verdict line first.

## Files

- `references/checklist.md`: the rubric (read at start).
- `RESEARCH.md`: evidence behind the rubric (read only when a verdict is contested).
- `scripts/trigger_eval.py`: run; measures triggering against the installed roster.
- `scripts/lift_report.py`: run; turns graded runs into a lift table.
- `agents/grader.md`: prompt for grading subagents (read by them, not by you).
