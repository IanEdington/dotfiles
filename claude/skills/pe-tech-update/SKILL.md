---
name: "pe-tech-update"
description: "Draft the monthly Technology & Innovation Update for the Green Party of Ontario's Provincial Executive (PE). Use whenever Ian mentions the monthly PE tech update, the board tech update, the monthly technology report, the technology & innovation update, the tech department update, or wants to prepare/draft/write anything of that shape. Handles the full workflow — pulling data from Gmail, Google Drive, Slack, GitHub, and Google Calendar for the target month and synthesizing it into a one-page, non-technical, board-appropriate markdown report in the established GPO template."
---

# PE Tech Update

Prepare the monthly Technology & Innovation Update for the Green Party of Ontario's Provincial Executive. The audience is volunteer board members with no technical background — the report should read like a briefing, not an engineering log.

## Workflow

### 1. Confirm the month

Default to the most recently completed calendar month. If the current date is early in a month, the user probably means the month that just ended. If ambiguous, ask.

### 2. Pull source data in parallel

Batch these searches in a single turn — they take time and don't depend on each other.

- **Gmail** (`search_threads`): `after:YYYY/MM/01 before:YYYY/[MM+1]/01 (tech OR Qomon OR CiviCRM OR GVote OR Canopy OR data OR migration OR launch OR website OR co-op OR volunteer OR ...)` — add topic keywords likely to matter that month.
- **Google Drive** (`search_files`): `modifiedTime > 'YYYY-MM-01T00:00:00Z' and modifiedTime < 'YYYY-[MM+1]-01T00:00:00Z' and owner = 'me'` with `excludeContentSnippets: true` and `pageSize: 25` to avoid truncation.
- **Slack** (`slack_search_public_and_private`): Run several targeted searches, one per major theme — `Qomon`, `Canopy`, `security incident`, `by-election`, etc. Each with `after:YYYY-MM-01 before:YYYY-MM-31` and `response_format: concise`. Broad single-query searches often return "no results" — narrow, topical queries work better.
- **GitHub** (`search_pull_requests`): `org:gpo is:pr created:YYYY-MM-01..YYYY-MM-31` with `fields: ["number","title","state","user","created_at","closed_at","repository_url","html_url"]` and `perPage: 100`. If the GitHub MCP is not connected, ask the user to run these `gh` commands and paste output:
  ```bash
  gh search prs --owner gpo --created YYYY-MM-01..YYYY-MM-31 --limit 300 \
    --json repository,number,title,state,createdAt,closedAt,author \
    --jq '.[] | "\(.repository.nameWithOwner) #\(.number) [\(.state)] \(.closedAt // .createdAt | .[0:10]) — \(.title) — @\(.author.login)"'
  ```
  Note: `gh search prs` doesn't expose `mergedAt`, only `closedAt`.
- **Google Calendar** (`list_events`): Optional and often skippable. Full-month listings return very large payloads that exceed token limits — prefer relying on calendar events surfaced through Gmail invites, or use `fullText` filtering with a small `pageSize`.

After the initial pass, run additional targeted searches for anything that emerged — specific incidents, new initiatives, named projects.

### 3. Verify and ask before drafting

Before writing, check for these gotchas — they've each burned us once:

- **Financial numbers** (savings, costs, revenue impact): always ask the user. Never estimate. Getting a dollar figure wrong in a board doc is a credibility hit that isn't worth the risk.
- **Incident scope**: use the *final* assessment, not the initial worst-case scoping. Early Slack messages often reflect the widest possible impact; later messages narrow it once analysis is done. Always source the latest.
- **Activation claims**: calendar invites tell you what was *scheduled*, not what actually *happened* or how it went. Only say "launched", "went live", "delivered", "tested with real users" when you have explicit evidence of the outcome. When in doubt, ask.
- **Ian's own promotion or role changes**: exclude. That comes from the Executive Director, not the tech department update.
- **Repository names, PR numbers, ETL/deploy/MCP/subtree/staging jargon**: never board-appropriate. Drop.

If uncertain about anything, ask rather than infer.

### 4. Structure the report

Save as `outputs/YYYY-MM-tech-update-to-PE.md`.

Standard template:

```markdown
# Technology & Innovation Update

*Provincial Executive — [Month] [Year]*

## [Optional: Risks & Asks — only when actionable]

- **Item name (ask/risk/risk, being managed/risk, routine):** Description.

## [Section 1 — dominant theme of the month]

Narrative prose. Bold **key people's names** on first mention. Focus on impact and outcomes.

## [Section 2 — forward-looking or next-biggest theme]

Narrative prose.

## [Optional additional narrative sections as the month warrants]

Prose.

## Additional

- **Item:** Plain-English description.
- **Item:** ...
```

**Section count flexes.** Some months have 2 narrative sections + Additional, some have 4. Choose based on how much distinct stuff happened. Don't force sections to exist.

**Section headers flex to what dominated the month.** Same skill, different framing:
- May 2026: "Qomon Implementation" — generic phase name.
- June 2026: "Qomon at Convention" — because Convention was the month's central Qomon moment.
- July 2026: "Qomon Goes Live in York–Simcoe" — because that was the story.

**Risks & Asks section is optional.** Include only if something needs PE attention (a decision, a real risk they should know about, or an ask). If nothing actionable, omit — an absent section signals "nothing to flag." When included, tag each item so the PE can scan quickly.

**Security incidents always lead the report.** Board that finds out from other channels first loses trust in the reporting cadence.

### 5. Writing style

**Non-technical, plain English.** The test: could a thoughtful volunteer board member explain this to a fellow board member after one read? If not, rewrite.

**Every claim should answer "so what?" for a board member.** Not "we set up a local DDEV environment for the multisite platform" — instead, "the development environment is up so anyone new joining the team can start contributing quickly." Not "canonical members ETL with GVote CSV upload landed" — instead, "the core data systems that power our membership reports, fundraising dashboards, and donor history were prepared for the transition."

**Name people.** Board members recognize staff and key volunteers. Bold names on first mention: **Mark Wong**, **Arleigh Luckett**, **John Weston**, **Matt Welke**, **Patrick Fortier**, **Christi Gardner**, etc.

**Frame new contributors by what they bring + what work they unlock.** Not "Patrick Fortier joined this month." Instead: "New volunteer Patrick Fortier joined the team this month, bringing a data science background that's well-suited to the careful field-by-field reconciliation the migration requires."

**Inline links for referenceable artifacts** (post-mortems, key strategy docs). Not every doc — only the ones a board member might actually click.

**Avoid:**
- Repository names, PR numbers.
- Deploy / ETL / MCP / subtree / staging / bedrock / composer jargon.
- Emojis, unless the user has used them.
- Section labels tying to internal KPIs (see next).
- Speculation dressed as fact (see "activation claims" above).

### 6. KPI awareness (private, never in the report)

Ian's 2026 KPIs quietly inform prioritization. **Never surface them by name or number in the report.** They're for the Executive Director and for shaping what gets emphasis — not for the PE.

Current KPIs:

- **Qomon major transition:** August — full config with dummy data + three custom tools (EO/Tax Receipt, Walk Sheet, WordPress/Qomon plugin). October — data migration validation (100% financial reconciliation, <0.5% field error, BigQuery refresh <15 min). November — training + canvassing pilot in a target riding.
- **Inter-party cooperation:** End of Q2 — shareable Qomon selection report for GPC and other provincial Green parties. End of Q4 — implementation documentation.
- **WordPress migration (Canopy):** End of Q3 — full project plan/budget for board approval. End of Q4 — bilingual architecture live on gpo.ca with French Caucus sign-off.

If work in a given month advances these goals, weight it more in the narrative. If nothing much happened on a KPI thread, don't manufacture progress just to show it.

### 7. Present and iterate

Save to `outputs/YYYY-MM-tech-update-to-PE.md` and present via the file card. Include a short summary of judgment calls made — what you dropped, what framing choices you made, what you'd like the user to sanity-check.

Iterate based on user feedback. Common revisions:

- Financial numbers or metrics that need the user's actual data.
- Activation claims that weren't accurate (test vs. real launch; scheduled vs. happened).
- Missing context (people, projects, or relationships you didn't have).
- Priority reordering based on what Ian knows the board cares about.
- Tone corrections — usually pulling further away from technical vocabulary.

## Example: full report from July 2026

Use this as a shape reference — real language, real cadence, real length.

```markdown
# Technology & Innovation Update

*Provincial Executive — July 2026*

## Security Incident (July 23)

On July 23, gpo.ca was subject to a security incident in which an attacker exploited a known WordPress vulnerability to briefly obtain administrator access. The intruder gained access at 12:37 EDT and was locked out by 12:54 — a 17-minute window.

Our forensic assessment concluded that the compromised data was most likely the account information of the 35 people with WordPress accounts on gpo.ca, and that no other personally identifiable information (such as member or donor records) was likely taken. All 35 account holders have been notified, and all WordPress passwords have been reset. External counsel confirmed we are not legally required to report to the Privacy Commissioner (PIPEDA does not apply to Ontario political parties and Ontario has no equivalent legislation), but we chose to disclose to the affected account holders regardless. A [post-mortem](URL) is scheduled for August 5, and hardening work is underway: Cloudflare protection on WordPress admin routes has been tightened, and two-factor authentication for WordPress accounts is planned.

## Qomon Goes Live in York–Simcoe

When by-election preparations kicked off in early July, we made the call to use Qomon rather than GVote for the York–Simcoe campaign — the first real-world use of the new platform. The **Data Migration team** pivoted from longer-term migration planning to rapid setup: Matt Welke stood up the York–Simcoe Qomon space with a targeted subset of voter data, Arleigh Luckett made the judgment calls on which existing tags to migrate, and AK Saini has been leading the CallHub integration so volunteers can phone-bank through Qomon. **Christi Gardner** also joined the Data Migration team this month, adding welcome capacity.

The **Qomon Champions program** — experienced campaign managers helping shape Qomon's configuration before wider deployment — met again on July 30 and is now running on a bi-weekly cadence.

## Canopy: Deployment Begins

Canopy is now in a strong enough state that we've started deploying it to our Canadian hosts — the transition from development environment to real infrastructure. This is the last major step before the first proof-of-concept sites go live, and keeps us on track for the end-of-summer goal of three of our 30 sites running on the new platform.

## Qomon Beyond the GPO

Qomon interest is spreading beyond the GPO, and we are gaining valuable insight as it does. Municipal and leadership campaigns evaluating or actively using the platform — including a **Guelph mayoral campaign** and **Mike Morrice's leadership campaign** — are giving us real-world signal on how Qomon performs outside our own workflows.

At the same time, we have begun formally supporting the **Green Party of Canada** and the **Green Party of PEI** as they evaluate Qomon for their own organizations. Our earlier selection work is now paying dividends beyond the GPO — we can share what we learned about Qomon's fit, pricing, and configuration, sparing those parties much of the evaluation work we had to do ourselves.

## Additional

- **Payment processor: contract signed.** The Stripe pricing agreement was signed on July 13, replacing IATS as our primary payment processor. Expected savings of approximately **$11,400/year** compared to our 2025 IATS costs.
- **Data-insights team.** John Weston has kicked off a data-insights team (distinct from the Data Migration team) focused on the reporting and dashboards we'll need to make good decisions with Qomon data.
```

## Prior reports as reference

If prior monthly reports exist in the outputs folder (`YYYY-MM-tech-update-to-PE.md`), read one before drafting a new month — it's the fastest way to match voice and cadence. If none exist, the July example above is enough.

