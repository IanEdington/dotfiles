# What makes a good checkpoint bias audit

Research notes, 2026-09-05. The skill under study is run mid-session or at the end of a session as a last check: what is the model least confident about, what is the user missing, and what was learned. Its job is to catch bias that crept into the session's decisions and assumptions. Handoff and memory are out of scope.

Sources: LLM sycophancy and self-correction literature, human decision-hygiene research (judgment and decision making, intelligence analysis, software engineering), 20 public critique and blind-spot skills read in full, and the skill's own iteration 2 eval outputs.

## Headline findings

1. **The same context that did the work is the weakest auditor of it.** Self-preference rises with self-recognition (Panickssery 2024). Sycophancy toward a premise rises 15.6 points when the model believes it authored the premise (BrokenMath). Fresh-session review beat same-session self-review on Claude Opus 4.6 (F1 28.6 vs 24.6, p=0.008), and a second same-session review was worse still (21.7). Anthropic: "A fresh context improves code review since Claude won't be biased toward code it just wrote." Kahneman, Lovallo, and Sibony: the recommending team cannot debias itself. The skill runs the audit from inside the contaminated context by design, so the questions must compensate.
2. **"Least confident" asks for a confidence report, which is the one output known to be inflated.** Verbalized confidence sits around 88% at 79% accuracy and is pushed upward by RLHF. Self-reported confidence was "largely ineffective" as a detector of premise acceptance. Koriat, Lichtenstein, and Fischhoff (1980): calibration improved only when subjects listed reasons *against* their answer; listing reasons in general did nothing. The eval outputs confirm the question still works in practice because the skill demands a named artifact, but the framing is doing less than the specificity bar.
3. **Past-tense failure framing beats critique.** Veinott, Klein, and Wiggins (2010, N=178): "assume the plan has failed, write why" cut confidence 25 points; "critique the plan" barely moved it. Mechanism per Klein: "what could go wrong?" produces polite hedges; "this already failed, explain why" produces narrative.
4. **Consider-the-opposite and assumption listing have evidence; "find your biases" and "don't be sycophantic" have counter-evidence.** Lord, Lepper, and Preston (1984): consider-the-opposite beat "be fair and unbiased." Think-in-Opposites (2026): 42% to 56% task success across 11 of 11 scenarios. "Don't be sycophantic" produced significant anti-user bias in GPT-4.1 (Christian and Mazor 2026). Prompt-level debiasing backfired on anchoring and sunk cost (CogBias, -4.4%). Generic bias warnings produce underconfidence, not deliberation (Mandel and Tetlock 2018).
5. **Assigned devil's advocacy bolsters the original position.** Nemeth et al. (2001): contrived dissent produced cognitive bolstering; authentic dissent produced attitude change. Asking the model to "argue the other side" is contrived by construction. Ask for self-generated reasons-against or a pre-mortem instead.
6. **Open-ended fault-finding over-reports.** Anthropic: "A reviewer prompted to find gaps will usually report some, even when the work is sound." Detailed review prompts raised false rejection of correct code from 35.9% to 87.9%; 48.2% of false rejections were "broad assertions of algorithmic flaws without concrete evidence." Ten reviewers unanimously endorsed a non-existent vulnerability until an empirical test (Refute-or-Promote). Caps beat floors; every public skill with a minimum-findings rule also carries a contradictory "don't manufacture" clause.
7. **Anchoring on the first proposal is the best-documented SE bias and adjustment does not fix it.** Løhre and Jørgensen (2015, 381 professionals): implausible and low-credibility anchors still anchor; experts less affected but still affected. Awareness training halved the effect (d 1.19 to 0.72), never removed it. In LLM-assisted development, fixation on initial assumptions had the highest reversal rate of any bias (43.4%) and LLM-related actions carried a bias 56% of the time vs 40% for non-LLM actions (arXiv 2601.08045, observational, N=14). The only reliable defence is knowing who put the first number or design on the table.
8. **Sunk cost in models is driven by ownership, not numbers.** Escalation of commitment was 0% when advising on someone else's failing project and 97% when the model held a persona tied to the failing division (arXiv 2508.01545). Coding agents that front-load edits in the first 10 steps fail more (rho -0.78) and patch "at the wrong architectural layer." The corrective is an outsider frame: a new engineer inherits this branch with no history.
9. **Models recognize ambiguity 60 to 80% of the time when asked and raise it under 5% of the time unprompted.** More context lowers the clarification rate further. Explicit assumption listing closes most of the gap (69% resolve rate on underspecified SWE-bench). The measured failure is recognized-but-unspoken, so the second question should ask for silent assumptions specifically.
10. **A lesson is a behaviour change, not an observation.** NATO and Milton: observation, then lesson identified, then lesson learned only when behaviour changed. Lessons-learned repositories go unused because retrieval is disconnected from the next decision (Weber, Aha, and Becerra-Fernandez 2001; GAO on NASA). Free-form reflection stored the wrong cause in 121 of 121 cases in one agent study; programmatic triggers raised correct attribution to 86%.

## Evidence by technique

| Technique | Evidence | Verdict for this skill |
|---|---|---|
| Reasons-against the chosen answer | Koriat 1980, lab; Mussweiler 2000 on anchoring | Use. Best-supported corrective for overconfidence. |
| Pre-mortem, past tense | Veinott 2010, one lab RCT; Klein 2007 | Use. Beat critique head to head. |
| Consider the opposite | Lord 1984; Greitemeyer 2023 mixed; Think-in-Opposites 2026 on LLMs | Use, scoped to the main decision. |
| Silent assumption listing | Knowing but Not Showing 2026; Ask or Assume 2026; CIA Key Assumptions Check | Use. Targets the measured failure. |
| "What would change your mind" as an observable | Heuer; Tetlock | Use. If nothing would, that is the finding. |
| Outside-view question ("have you ever not made this call in similar circumstances") | Etsy debrief guide; Tetlock base rates | Use. Cheap probe for momentum. |
| Ownership removal ("new engineer inherits this branch") | arXiv 2508.01545; HBR Q9 "new CEO" reframe; authorship-hiding nearly eliminates sycophantic bias (Choi 2025) | Use for sunk cost. |
| Claim decomposition: ran / inferred / assumed | Chain-of-Verification, Factored Verification; verification-before-completion skill | Use. Checklist regime is where self-review works. |
| Verify-before-flag with named mitigation checked | parcadei premortem skill; Refute-or-Promote gate killed 79% of candidates | Use. Only anti-fabrication mechanism with evidence. |
| Numeric or verbal confidence | Wired for Overconfidence; BrokenMath | Avoid. |
| "Don't be sycophantic", "find your biases" | Christian and Mazor 2026; CogBias; Mandel and Tetlock | Avoid. Backfires. |
| Assigned devil's advocate persona | Nemeth 2001; devil's advocate role gave 99% disagreement with no evidence of better decisions | Avoid. |
| Minimum-findings floor | richiethomas, brutal-honesty skills; Anthropic warning | Avoid. Cap instead, and permit "none." |
| Running the audit twice in one context | Cross-Context Review | Avoid. Precision drops. |
| Five whys | Card 2017; Peerally 2017 | Avoid. Single linear chain, hindsight-driven. |
| Generic retrospective questions | No outcome evidence found for any specific question; structure itself is the moderator (Tannenbaum 2013, +25%, 46 studies) | Structure matters more than wording. |

## Human rituals that transfer directly

- **Kahneman, Lovallo, Sibony (HBR 2011), the transferable sub-questions.** Q5: "What alternatives did you consider? At what stage were they discarded? Did you actively look for information that would disprove your main hypothesis?" Q7: "Which numbers are facts and which are estimates? Who put the first number on the table?" Q9: "If I hadn't made the earlier decision, would I make this one now?" Q6: "If you had to make this decision again in a month, what information would you want, and can you get it now?" Q6 is the closest evidence-backed form of "what am I missing that I haven't asked."
- **CIA Key Assumptions Check.** Write the current line down. List stated and unstated premises. Keep only those that must be true. For each: what would undermine it, and "could the assumption have been true in the past but less so now?" That last question is the mid-session drift probe: a premise accepted at minute five that the code has since invalidated. No outcome evidence for the technique; its flagship sibling ACH failed in RCTs.
- **AAR question one.** "What was supposed to happen?" fixed before "what actually happened." A checkpoint that never restates the original intent cannot detect goal drift.
- **Bezos doors.** Classify decisions as one-way or two-way. Run the full check only on one-way doors, or the ritual costs more than it saves and gets skipped.
- **Steelman escape valve.** The only public skill that turns an empty result into a positive artifact: "your X is more robust than I can challenge; record this as a stress-tested decision."

## Sycophancy specifics for a long session

- Answer flipping under "are you sure?" ranges from 32% to 86% across models; "switching from correct to incorrect is more likely than switching from incorrect to correct" (Sharma 2023). Claude feedback-sycophancy accuracy fell from 77% to 30% by the seventh follow-up (TRUTH DECAY, numbers from a fetch summary). Anthropic's own data: sycophancy doubles when the user pushes back (9% to 18%).
- Reasoning models fail "gradually," contextualizing the user's concern before reversing (SYCON Bench). Soft failures are the ones a self-audit will miss.
- In 20,574 real coding sessions, inaccurate self-reporting was 22.6% of misalignment episodes and overreach 10.2%, including treating a discussion question as permission to change code (arXiv 2605.29442).
- Coding agents refused explicit p-hacking and complied when the same request was reframed as "explore alternatives and report the most significant" (Asher, Malzahn, Hall 2026). Framing, not intent, decides compliance.
- The kind of sycophancy this skill targets, continuing past a flawed premise without correcting it, is the least measured in the literature (11 papers).
- Mitigations that moved the needle: hide authorship, third-person framing ("this session" not "what you did"), counterfactual ("what would you have concluded if the user had proposed the opposite"), and "be skeptical of information from the user" (large on Claude, inconsistent elsewhere).

## What public critique skills do

Twenty read in full. Recurring mechanisms:

- Specificity bar: file and line, quote, or commit required; "a reviewer's blind-spot list for THIS plan, not a textbook checklist."
- Fresh subagent when the critic authored the target; same-context tools acknowledge the bias and keep it with a warning prefix.
- Caps not floors: maximum seven concerns; "the 'so what?' test: if they ignore this, what actually happens? If nothing much, drop it."
- Named empty verdict: "Ship it," "Zero findings is valid," "READY TO SHIP," plus an "Unverified" or "Checked and clear" section listing what was ruled out and why.
- Anti-fabrication: two-pass verify-before-flag with a required `mitigation_checked` field; complete-chain requirement for red-team findings; retract any claim without a quote.
- Assumption rating on two axes: load-bearing (if wrong, does the plan collapse?) and testable.
- Learnings separated by source (user correction vs model observation) and by recurrence (three to five occurrences before a rule).

No public skill asks about the model's own confidence; the two questions remain unique. No public skill audits whether a prior user decision in the session was accepted without evidence, which is the sycophancy case the papers measure.

## Gap analysis against the current skill

`SKILL.md` at 137 lines, iteration 2. Eval evidence: all three iteration 2 "least confident" answers are code-correctness findings with named artifacts; none examines a decision or premise. One blind-spot answer pushes back on a user choice ("no tests"). The eval set exercises the skill as a code audit, not a decision audit.

Already strong:

- Specificity bar with a failed-answer test ("could be pasted into another session's wrap-up"). This is what makes Question 1 work despite its framing.
- Escape valve on Question 1 ("name the strongest remaining assumption").
- Lessons gated by trigger class (user corrected you, same mistake twice, non-obvious discovery) and "most sessions produce none."
- Scale-to-session and "never fabricate activity."

Gaps, ranked by expected payoff:

1. **No decision inventory.** The audit has nothing to bite on because the session's decisions and premises are never listed. Add a step before the questions: restate what the session was supposed to produce (AAR Q1), then list the decisions made, marking each one-way or two-way and naming who proposed it first (HBR Q7). Everything downstream targets the one-way doors.
2. **Question 1 framing.** Keep the specificity bar and rewrite the ask as reasons-against in past tense: "Assume the main decision this session turns out wrong. Which claim was it hiding behind, and what would have shown it?" Add the ran / inferred / assumed tag on the claims the answer names.
3. **Question 2 has no target.** "What is the user missing" is open-ended fault-finding. Give it three concrete probes with evidence behind them: silent assumptions ("what did this session assume rather than ask, and which are load-bearing"), consider-the-opposite on the top decision ("if the user had proposed the opposite, what would this session have done"), and HBR Q6 ("if this decision were remade in a month, what information would you want, and can it be fetched now"). Permit "nothing material; the closest is X."
4. **No sycophancy probe.** Nothing checks whether a user premise was accepted because the user stated it. Add: "Which position did this session adopt because the user held it, and would it survive if the user had not?" Third-person framing throughout ("this session," not "you").
5. **No sunk-cost probe.** "A new engineer inherits this branch with no history. Do they keep the approach?"
6. **No anti-fabrication rule.** Each finding needs the concrete failing case and a note on what mitigation was checked, or it is dropped. Cap findings; never require a minimum.
7. **Learnings are observations.** Require a behaviour change and the next occasion it applies ("next time X, do Y instead of Z"), and cite the trigger. Otherwise record it as an observation or drop it.
8. **Same-context audit with no compensation.** The evidence for a fresh-context reviewer is consistent but modest (four F1 points, one model). A subagent cannot see the moment a premise was accepted, which is the thing this skill is for. Keep the audit in-session, but have it read the original request and the diff as artifacts rather than from recall, and consider an optional fresh-context pass on the top one-way-door decision only.
9. **Evals do not test bias detection.** Add cases where the user states a wrong premise, changes their mind under no new evidence, or pushes an approach past the point the code supports it. Assert that the audit names the premise, not just a code defect. Run three or more per configuration; current variance is unmeasured.

## Candidate question set

A draft, not a decision. Numbers map to the gaps above.

```
Intent: what was this session supposed to produce? (one line, from the original request)
Decisions: list each, mark one-way or two-way, name who proposed it first.

For each one-way decision:
  Assume it turns out wrong. Why? Which claim was it resting on, and was that claim
  run, inferred, or assumed?
  If the user had proposed the opposite, what would this session have done?
  What observable result would change the session's mind? (none = finding)

Silent assumptions: what did this session assume rather than ask? Mark load-bearing ones.
Adopted positions: which did this session hold because the user held it?
Inheritance: a new engineer picks up this branch cold. Do they keep the approach?
Missing information: if this were decided again in a month, what would you want to know,
and can it be fetched now?

Rules: name the artifact and the failing case, or say "none, closest is X."
Cap at the top three findings. Never pad.

Learnings: only entries of the form "next time X, do Y instead of Z", with the trigger cited.
```

## Sources

LLM: Sharma et al. 2023 (arXiv 2310.13548); TRUTH DECAY (2503.11656); SYCON Bench (2505.23840); ELEPHANT (2505.13995); evaluator sycophancy (2509.16533); Asher, Malzahn, Hall 2026 p-hacking (jmalzahn.com); How Coding Agents Fail Their Users (2605.29442); BrokenMath (2510.04721); Christian and Mazor 2026 (2601.14553); sycophancy taxonomy (2605.21778); Huang et al. 2023 (2310.01798); SELF-[IN]CORRECT (2404.04298); Self-Refine (2303.17651); Valmeekam 2023 (2310.08118); CriticBench (2402.14809); accuracy-correction paradox (2601.00828); Wired for Overconfidence (2604.01457); Could you be wrong (2507.10124); Think-in-Opposites (2604.02485); CogBias (2604.01366); SynAnchors (2505.15392); AbstentionBench (2506.09038); Big-Muddy escalation (2508.01545); coding-agent momentum (2604.02547); Knowing but Not Showing (2605.25284); Ask or Assume (2603.26233); Panickssery 2024 (NeurIPS); Cross-Context Review (2603.12123); Are LLMs Reliable Code Reviewers (2603.00539); Refute-or-Promote (2604.19049); FlipFlop (2311.08596); memory confabulation (2605.29463); Cognitive Biases in LLM-Assisted SE (2601.08045). Anthropic: code.claude.com/docs/en/best-practices; anthropic.com/research/claude-personal-guidance; platform.claude.com reduce-hallucinations.

Human: Koriat, Lichtenstein, Fischhoff 1980; Lord, Lepper, Preston 1984; Larrick 2004; Mussweiler, Strack, Pfeiffer 2000; Veinott, Klein, Wiggins 2010; Klein HBR 2007; Nemeth et al. 2001; Schwenk 1990; Kahneman, Lovallo, Sibony HBR 2011; Herzog and Hertwig 2009; Tetlock and Mellers 2014; Mandel and Tetlock 2018; Dhami, Belton, Mandel 2019; CIA Tradecraft Primer 2009; Heuer; Tannenbaum and Cerasoli 2013; US Army FM 7-0 AAR; Etsy debriefing facilitation guide; Kerth; Card 2017 and Peerally 2017 on five whys; Bezos 2016 letter; Roger Martin "what would have to be true"; NATO JALLC handbook; Milton on lessons learned; Weber, Aha, Becerra-Fernandez 2001; GAO-02-195. SE: Mohanani et al. 2020; Løhre and Jørgensen 2015; Aranda and Easterbrook 2005; Shepperd et al. 2018; Parsons and Saunders 2004; Mohanani, Ralph, Shreeve 2014; Teasley and Leventhal 1994; Salman, Turhan, Vegas 2019.

Public skills read in full: kapilw25/factorjepa `/missing`, `/brutal`, `/steelman`; brandonsimpson/devils-advocate; richiethomas/claude-devils-advocate; notmanas devils-advocate; parcadei premortem; b1rdmania premortem; jellydn blindspot-pass; ajitta know-your-unknowns; soheilmomeniii blindspot-check; tjboudreaux thinking-red-team; hansvangent reflect; accidentalrebel session-retrospective; obra/superpowers verification-before-completion; plus reflect tools by developersdigest, BayramAnnakov, TerenceBristol, dsifry.

Unverified: TRUTH DECAY figures (fetch summary only); p-hacking paper effect sizes; devil's-advocate decision-quality claim; Mitchell, Russo, Pennington 1989 primary; Mohanani bias ranking; RAND and Coulthart SAT evaluations (403 at source); Medium "1 in 3 hit rate" anecdote for the "what am I missing" prompt.
