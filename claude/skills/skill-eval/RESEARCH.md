# Research: what makes an agent skill actually work

Question: across Anthropic, Microsoft, NVIDIA, OpenAI, Vercel, and Google, what does the evidence say separates a skill that lifts agent performance from one that does nothing? Findings drive the `skill-eval` skill and how skills in this dotfiles repo and `personal-assistant` are written, scoped, and tested.

## Core finding

Two independent failure modes, and most bad skills fail at the first one.

1. **Retrieval failure**: the skill never fires. Vercel measured the agent ignoring an available skill in 56% of eval cases, producing exactly zero lift over baseline (https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals).
2. **Content failure**: the skill fires but carries nothing the model didn't already have. SkillsBench found agent-self-generated skills land *below* the no-skill baseline (−8.1 to −11.5 pp) while curated skills on the identical setup gain +18.2 to +24.8 pp (https://arxiv.org/abs/2602.12670).

The corollary the Reddit post gets right: a skill earns its keep only when it holds knowledge the model cannot derive — a private API, a repo's conventions, a regulated procedure. That is why SkillsBench's domain spread runs from +4.5 pp (software engineering, where the model already knows) to +51.9 pp (healthcare, where it doesn't).

## 1. The measured lifts, and why they disagree

| Source | Measured | Headline |
|---|---|---|
| SkillsBench (87 tasks, 8 domains) | Curated skills vs none | 33.9% → 50.5% pass, +16.6 pp (https://arxiv.org/abs/2602.12670) |
| NVIDIA SkillEvaluator (300+ verified skills, 2 harnesses) | With/without arms, 5 dimensions | Correctness +41, Discoverability +40, Effectiveness +39, Efficiency +35, Security +1 (https://developer.nvidia.com/blog/evaluating-ai-agent-skill-performance-with-nvidia-skillevaluator/) |
| Microsoft SkillOpt (52 settings) | Optimized skill vs hand-written | +15–25 pp absolute; SpreadsheetBench 41.8 → 80.7 (https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/) |
| Vercel (Next.js 16 APIs) | Skill vs AGENTS.md | Baseline 53%, skill 53%, skill + explicit instruction 79%, AGENTS.md docs index 100% (https://vercel.com/blog/agents-md-outperforms-skills-in-our-agent-evals) |

The spread is not noise, it is selection. NVIDIA's +41 is measured over skills that passed its own quality gates and were written for products the model has no training data on. Vercel's 0 is measured over a skill competing with a model that already writes passable Next.js. Read any single number as "lift for skills of this kind, in this domain", never as "lift from skills".

Two findings survive across all four: **smaller models with skills approach larger models without them** (SkillsBench), and **harness matters less than domain fit** (NVIDIA: per-product variation +2 to +46, exceeding the Claude Code vs Codex gap of 34 vs 29).

## 2. Size: the consistent, counterintuitive result

Every source that varied length found comprehensive documentation is worse than compact procedure.

- SkillsBench 1.1: standard-length +21.5 pp, compact +19.0 pp, **comprehensive +0.7 pp** (https://www.skillsbench.ai/blogs/skillsbench-1-1).
- SkillsBench: skills with at most three modules beat larger bundles; 2–3 skills loaded (+19.0) beat 4+ (+10.1).
- SkillOpt, optimizing freely in text space, converged on a **median final skill of ~920 tokens**, most files carrying one to four accepted edits. OfficeQA gained +39 points from a *single* edit.
- Anthropic: SKILL.md body under 500 lines, everything else in linked files (https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices).

The mechanism is that a skill's job is to change a decision, not to be a manual. A reference dump dilutes the few lines that flip behaviour. SkillOpt's phrasing is the best test: the learned content reads "like a seasoned practitioner's advice", and it captured "general workflow logic, not just harness-specific recipes".

## 3. Triggering is a separate engineering problem from content

The 56% miss rate is the single largest source of wasted skill work, and it is addressed at the description, not the body.

Anthropic's rules, all aimed at discovery:
- Only `name` and `description` are preloaded; everything else costs nothing until read.
- Description must carry **what it does AND when to use it**, in **third person** ("Processes Excel files and generates reports", never "I can help you…"). Inconsistent POV degrades selection because the text is injected into the system prompt.
- Pack it with the literal trigger terms a user would type (file extensions, tool names, synonyms). 1,024 char budget; spend it.
- Claude under-triggers by default, so descriptions should be pushy about their triggers.

NVIDIA makes discoverability a scored dimension in its own right (baseline 42 → 82 with skills) and scores both halves: fires when relevant, **stays silent when not**. Semantic overlap between skills is flagged as a defect, because two skills covering the same ground make selection worse.

Vercel's conclusion is the structural one: for knowledge needed on *every* task in a repo, don't make the agent decide at all. Put it in always-on context (AGENTS.md / CLAUDE.md). Reserve skills for **vertical, user-triggered workflows** — a migration, a report format, an expense claim — where there is a clear moment that names the skill. This directly predicts which of personal-assistant's skills are safe: `/monthly-tech-update` and `/expense-report` have explicit triggers; a passive "writing style" skill is better as always-on prose in CLAUDE.md or a style guide the orchestrator always reads.

## 4. What belongs in the body

Anthropic's guidance, in rough order of leverage:

- **Assume the model is smart.** Cut any sentence explaining a concept rather than your specifics. Their example: 50 tokens of `pdfplumber` usage beats 150 tokens explaining what a PDF is.
- **Match degrees of freedom to fragility.** Open field (code review) → high freedom, general direction. Narrow bridge (a migration that must run in one sequence) → exact command, "do not add flags".
- **One default, with an escape hatch.** Never list four libraries.
- **Workflows as numbered steps with a copyable checklist** for anything multi-step.
- **Feedback loops**: run validator → fix → repeat. The validator can be a script or a checklist document; the loop is what raises quality.
- **Verifiable intermediate outputs** for batch or destructive work: plan → validate the plan file → execute → verify.
- **Examples over description** where output style matters (input/output pairs).
- **Consistent terminology**; pick one word for a thing and never vary it.
- **No time-sensitive text** ("before August 2025…"); put superseded material in a collapsed "old patterns" section.
- **References one level deep from SKILL.md.** Nested references get partially read (`head -100`), so the agent silently acts on incomplete information. Any reference file over 100 lines gets a table of contents at the top for the same reason.
- **Scripts over generated code** for deterministic steps: more reliable, and executing a script costs only its output in tokens. Say explicitly whether a file is to be *run* or *read*.
- **Fully qualified MCP tool names** (`Gmail:search_threads`), or the agent fails to find the tool when several servers are loaded.
- **Solve, don't defer**: scripts handle their own errors instead of failing into the agent's lap. No unexplained constants.

## 5. How the labs say to test

All four converge on the same experiment: same task, same model, same harness, one arm with the skill and one without, and diff the outputs. Nothing else measures a skill.

- **Anthropic**: build evaluations *before* writing the skill. Run the task with no skill, record the specific failures, write three scenarios targeting them, baseline, then write the minimum text that passes. Test on Haiku, Sonnet, and Opus, since a skill that suits Opus may under-specify for Haiku. Then the A/B authoring loop: Claude A writes the skill, Claude B (fresh instance) uses it on real work, observed failures go back to Claude A.
- **NVIDIA SkillEvaluator**: tiered — deterministic quality gates and semantic-overlap detection first, synthetic eval-set generation, then live with/without runs scored on the five dimensions. Their own retrospective conclusion is that **eval dataset design, not the skill text, was the differentiator between teams** (https://github.com/NVIDIA/SkillEvaluator).
- **SkillOpt**: validation-gated edits (an edit is adopted only if it improves held-out performance), bounded edit budgets, and a rejected-edit buffer; ablating that buffer lowers scores everywhere, so negative results have to be retained, not just discarded (https://github.com/microsoft/SkillOpt).
- **Efficiency is a real cost, and measured**: one NVIDIA skill raised token usage by 120.3%. A skill that is correct but doubles token spend is a net loss on routine work.
- Academic follow-on: Skill Coverage proposes a test-adequacy metric, asking whether a suite exercises a skill's distinct execution paths at all rather than just reporting pass rates (https://arxiv.org/pdf/2606.20659).

## 6. Cross-vendor: the same idea under other names

| Vendor | Artifact | Position |
|---|---|---|
| Anthropic | Skills (`SKILL.md`) | Model-invoked, progressive disclosure, filesystem-backed (https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) |
| OpenAI / Codex | `AGENTS.md` + skills | AGENTS.md for durable always-on repo rules (setup, test, standards); skills for repeated packaged workflows. Prompts framed as Goal / Context / Constraints / Done-when (https://developers.openai.com/codex/guides/agents-md, https://developers.openai.com/codex/learn/best-practices) |
| Vercel | AGENTS.md docs index | Empirically prefers always-on over model-invoked for framework knowledge |
| Google | Gems | Persona + task + context + format, plus an uploaded knowledge base that takes priority over general knowledge; guidance is to keep each Gem narrow rather than omnibus (https://support.google.com/gemini/answer/15235603) |

Google's Gems guidance is consumer-grade and evidence-free next to the rest, but it lands on the same two rules: one Gem per job, and attach the documents the model can't know. OpenAI's contribution is the explicit "Done when" clause — a verifiable end state — which none of the skill guides state as plainly and which is the cheapest way to make a skill self-checking.

## 7. Practical rules this implies

1. Before writing: run the task with no skill and write down the *specific* failures. If there are none, don't write the skill.
2. If the knowledge applies to every task in the repo, it is always-on context, not a skill. Skills are for named, triggered workflows.
3. Spend the description budget on triggers, in third person, with the literal words a user would type.
4. Target ~1,000 tokens of procedure in the body. Push reference material into one-level-deep files with a ToC.
5. Encode only what the model can't derive: your IDs, your conventions, your sequences, your formats.
6. Give every skill a "done when" and, where possible, a validator to loop against.
7. Measure with/without on three real tasks before trusting it, and re-measure token cost, not just correctness.
8. Never let an agent write its own skill unreviewed; that is the one configuration measured as worse than no skill at all.

## 8. What community practice adds, and where it contradicts the evidence

Community round-ups of Claude skills (the largest hubs being https://github.com/BehiSecc/awesome-claude-skills, https://github.com/travisvn/awesome-claude-skills, and https://github.com/hesreallyhim/awesome-claude-code) are directories, not evidence: no with/without arms, no baselines, self-selected reporting from people who kept the skills that worked for them. Treat their rankings as hypotheses. Their aggregate verdict, however, lines up with the measured work:

| Community claim | Evidence status |
|---|---|
| Skills solving one specific problem win | Confirmed: SkillsBench's ≤3-module result, NVIDIA's overlap penalty |
| Vague "makes Claude smarter" skills fail | Confirmed: the content-failure mode, section 1 |
| Skills that try to do too much fail | Confirmed: comprehensive documentation at +0.7 pp |
| Dev-focused skills are the highest quality | Contradicted as a value claim: software engineering is the *lowest*-lift domain (+4.5 pp), because the model already knows. High quality, low marginal value |
| Doc-site-to-skill generators are the most useful category | Unresolved, and the riskiest claim here |

That last one is the important disagreement. Auto-generating a skill from a documentation site is exactly the configuration SkillsBench measured as worse than no skill at all: machine-authored, comprehensive rather than procedural, and optimized for coverage instead of for the few lines that change a decision. The underlying instinct is right — a private internal framework the model has never seen is precisely the high-lift case from section 1 — but the output should be treated as *reference material* bundled one level deep behind a hand-written SKILL.md, not as the skill. The generated corpus is the appendix; a human still has to write the procedure and the trigger.

Two operational notes from community practice that the lab sources don't cover:

- **Hooks are the deterministic complement to skills.** A skill has to be selected; a hook fires on an event. Anything that must happen every time (lint gates, notifications, TDD enforcement) is a hook or always-on context, never a skill. This is the same boundary Vercel drew in section 3, arrived at independently.
- **The commonest failure is installation, not authoring**: wrong directory structure, skills not enabled in project settings, breakage on update. Worth ruling out before concluding a skill "doesn't work" — which is itself indistinguishable from the 56% non-invocation problem without checking whether the skill fired at all.

The sharpest criticism in that thread is worth keeping: the skills architecture shifts the burden of performance onto the user, and creates a closed loop where poor output is blamed on insufficient configuration rather than on the system. The defence against it is section 5 — if a skill cannot show lift on a with/without run against three real tasks, it is configuration debt, and deleting it is the correct move.
