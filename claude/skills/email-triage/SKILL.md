---
name: "email-triage"
description: "Triage Ian's Gmail inbox: classify what actually needs him, label everything, stage draft replies for the few that do, and learn from his corrections. Use when he asks to triage email, clear the inbox, run the triage pass, or set up recurring triage. Also handles first-time setup (labels and writing style guide)."
---

# Email Triage

Turn the inbox into three piles: needs Ian, waiting on others, and safe to ignore. Never send anything. Drafts are staged in Gmail Drafts for Ian to edit and send; everything else just gets labelled so the inbox itself shows the verdict.

Two hard rules that override everything else:

1. **Never send email.** `create_draft` and `reply`-as-draft only. No `send_message`, no `forward`. Confirming receipt, "thanks", anything — all drafts.
2. **Never archive, trash, or mark spam during triage.** Labels only. Ian decides what leaves the inbox until the accuracy log (below) shows weeks of clean verdicts; even then, ask before changing this.

## First-time setup

Run once, when the `triage/` labels don't exist yet (check with `list_labels`).

1. Create labels: `triage/action` (Ian must do or reply to something), `triage/waiting` (his thread, ball in someone else's court), `triage/fyi` (worth a skim, no response owed), `triage/noise` (newsletters, notifications, receipts, marketing), `triage/drafted` (a staged draft exists), and `triage/unsure`.
2. Build the style guide: pull ~50 recent sent messages across different recipients (`search_threads` with `in:sent`, skim full bodies with `get_thread`). Write `style-guide.md` next to this SKILL.md capturing: greeting and sign-off habits per audience (colleague, report, external, GPO volunteer), typical length, formality range, how he says no, how he asks for things, punctuation quirks. Quote a few real sentences as calibration examples. This file is the source of truth for every draft; regenerate it only when Ian asks.
3. Create `rules.md` next to this SKILL.md from the template at the bottom of this file.

## Triage run

1. Read `rules.md` first. It holds the learned sender/topic rules and every past correction; the rules there override the general heuristics below.
2. Fetch candidates: `search_threads` for `in:inbox -label:triage/action -label:triage/waiting -label:triage/fyi -label:triage/noise -label:triage/unsure`, newest first, up to ~40 threads. Already-labelled threads are done; this makes the run idempotent and cheap.
3. For each thread, read enough to judge: snippet is fine for obvious noise, but anything that might be `action` needs `get_thread` — the classification error that matters is missing a real ask, not over-reading.
4. Apply exactly one triage label per thread (plus `triage/drafted` when applicable). Genuinely can't tell → `triage/unsure`, never a guess.

### Classification heuristics

- **action**: a person asks Ian, by name or as the only plausible answerer, for a decision, review, reply, or task. Calendar invites needing a response. Deadlines that land on him.
- **waiting**: the latest message in a thread Ian started or last replied to is from him, or someone said "I'll get back to you".
- **fyi**: human-written, relevant, no ask. Threads where Ian is cc'd and the ask is addressed to someone else by name.
- **noise**: automated senders, newsletters, marketing, receipts, notification emails (GitHub, ClickUp, LinkedIn, etc.). Exception: an automated alert a rule in `rules.md` marks as urgent stays `action`.

### The cc problem

Cc'd threads that look like real work are the main noise source. A thread is only `action` for Ian when at least one of these holds; otherwise cc'd threads are `fyi`:

- The ask names him or is unambiguously in his lane (something only he owns).
- A direct question sits unanswered and every named addressee has gone quiet for 2+ days.
- A decision is about to be made that a rule in `rules.md` says he must weigh in on.

Before marking any cc'd thread `action`, check whether someone else already answered — read the whole thread, not the top message.

## Drafting

For each `action` thread where a reply is the action (not "go do a task"), stage a draft:

- Read the full thread and `style-guide.md`. Also pull the last 2-3 sent messages to this recipient and match that specific register — Ian writes differently to his manager, his reports, and volunteers.
- Draft the shortest reply that answers the actual ask. No invented commitments, dates, or facts; where a fact is needed that isn't in the thread, leave `[?: ...]` for Ian to fill rather than guessing.
- Save with `create_draft` as a reply on the thread, add `triage/drafted`.
- Skip drafting when the reply requires a decision only Ian can make and the draft would just be `[?]`s — label `action` and move on.

## Report

End every run with a compact summary: counts per label, then one line each for `action` and `unsure` threads (sender, subject, the ask, draft staged or not). Nothing per-item for `noise`/`fyi` beyond the count.

## Feedback loop

This is what keeps it accurate past week one. When Ian corrects a verdict ("that wasn't mine", "X is always urgent", "stop drafting to Y", or he relabels a thread in Gmail):

1. Append a dated entry to `rules.md` under Corrections: what was classified, what it should have been, and the generalized rule ("Emails from finance@ with 'approval' in subject → action", "Threads where I'm cc'd on hiring loops → fyi unless named").
2. When he heavily rewrites a staged draft, ask if the difference is style or substance; style differences go into `style-guide.md`.
3. On each run, if `rules.md` has 3+ corrections pointing the same way, propose collapsing them into one rule.

`rules.md` and `style-guide.md` live in the dotfiles repo, so on a machine with the repo checked out, commit changes to them on a feature branch when the session ends. In a cloud session without the repo, tell Ian the learned rule so he can add it.

## Recurring setup

When Ian asks to make this recurring: schedule a weekday task (suggest hourly during work hours) whose prompt is "Run the email-triage skill's triage pass. Setup is done; skip it." Unattended runs never draft to new external recipients they haven't seen in sent mail, and put anything ambiguous in `triage/unsure` rather than interrupting him.

## rules.md template

```markdown
# Email triage rules

## Standing rules
<!-- sender/topic rules, one bullet each; these override SKILL.md heuristics -->

## People
<!-- who Ian answers for, whose asks are always action, whose threads are never his -->

## Corrections
<!-- dated log: was → should-have-been → generalized rule -->

## Accuracy log
<!-- per run: date, counts, corrections received; review monthly -->
```
