# Injects and incident reports

Injects = **50% of my tryout score.** I write every word myself. AI can help me *do* the task or understand a topic — it cannot write or edit any part of the response. Graders run AI detectors; AI writing = zero and possible DQ.

## When an inject arrives
1. Note the **deadline** (hard cutoff, no late submissions).
2. Read it three times. Turn every ask into a checkbox — each part may carry its own points.
3. Estimate time. If it's big, submit a partial before the deadline rather than nothing.
4. Do the technical part. Screenshot as I go (`Win+Shift+S`), cropped to just the evidence.
5. Write the memo myself.
6. Check it against the checkbox list. Spell-check.
7. Export PDF → name it `team##_inject##.pdf` (two digits, e.g. `team07_inject02.pdf`) → submit in Quotient.
8. Can't finish? Submit anyway and explain what I did and how I would finish it.

## Memo format checklist (from the packet's example + inject training)
- [ ] Heading block: To / From (**Team ##**, never my name) / Date / Subject (include the inject name/ID)
- [ ] One opening line stating the purpose
- [ ] Body answers **every** ask, in the order asked (numbered list or short sections)
- [ ] Screenshots centered, each with a label/caption and one sentence saying what it proves
- [ ] Tables labeled
- [ ] One font, one size, consistent
- [ ] Written for the audience: CEO/management = plain language, no unexplained jargon
- [ ] Professional tone ("Figure 2 shows..." not "as you can see...")
- [ ] Concise — more words ≠ more points
- [ ] Cite sources when asked for research / best practices (link them)
- [ ] No faked evidence

## Research injects (like Inject 1)
AI and web searches are allowed for **learning** the material. Good habit: read sources (vendor docs, datasheets), take notes in my own words in a separate file, then write the memo from my notes, not from AI text. Keep links for citations.

## Incident reports (IR inject: released at start, due at the end — submit several)
Each report = one red team action I found and fixed. Points come back for **valid, detailed** reports.

**During the day, log every finding** in my notes file:
```
time | box | what I saw (evidence) | how they got in (if known) | what I did | screenshot filename
```
Golden rule: **screenshot before I delete.**

**Sections to include** (from the Threat Hunting & IR training):
1. **Header** — memo to leadership (CEO / CISO / Network Ops), From Team ##
2. **Incident details** — table: affected host, service, port, timestamps, source & destination IPs, affected users
3. **Vulnerability** — the weakness they used (e.g. default password, open anonymous FTP)
4. **Initial access** — how and when they got in, with evidence (log lines/screenshots)
5. **Impact** — what they did and what it meant for the business
6. **Eradication** — how I removed them (processes, backdoors, accounts)
7. **Remediation** — how I closed the hole so it can't happen again
Optional: MITRE ATT&CK technique IDs ([07](07-threat-hunting.md)).

**Tonight:** retype [../templates/inject-memo-template.md](../templates/inject-memo-template.md) and [../templates/incident-report-template.md](../templates/incident-report-template.md) into my word processor, so tomorrow I only fill them in.

**Time plan:** start assembling IR reports by 15:00 at the latest. Everything submitted by 15:50.
