# Incident report template (structure only)

Sections follow the Threat Hunting & IR info session slides. Everything in `[brackets]` is a placeholder for my own writing.
**Retype this in my word processor tonight.** One report per red team action. Submit to the Incident Response inject in Quotient before the end.

---

**Interoffice Memorandum**

**To:** [leadership — CEO / CISO / Network Operations]
**From:** Team [##] – IT & Cyber Defense
**Date:** [Month DD, YYYY]
**Subject:** Incident Report – [short name of the incident]

[One or two sentences: what happened, in plain language.]

**Incident Details**

| | |
|---|---|
| Affected host(s) | [hostname / IP] |
| Affected service / port | [e.g. service name / port number] |
| Time detected | [HH:MM] |
| Time of initial access (if known) | [HH:MM] |
| Source IP address(es) | [attacker IP] |
| Destination IP address(es) | [my box IP] |
| Affected user account(s) | [usernames] |

**Vulnerability**
[The weakness that was taken advantage of.]

**Initial Access**
[How and when they got in — with evidence.]
> [Screenshot of log lines / Splunk search, centered]
> *Figure [N]: [caption]*

**Impact**
[What they did and what it meant for the business.]

**Eradication**
[What I removed — processes, files, accounts, scheduled tasks — and how.]
> *Figure [N]: [caption]*

**Remediation**
[What I changed so the same thing can't happen again.]

[Optional: MITRE ATT&CK technique ID(s)]

[Closing: available for questions — Team ##]

---

## Evidence to collect during the day (so this is quick to fill in)
For every finding, one line in my notes file:
`time | box | what I saw | how they got in (if known) | what I did | screenshot filename`

- [ ] Screenshot **before** deleting anything
- [ ] Note the attacker IP and the user account involved
- [ ] Screenshot the log line or Splunk search that shows how they got in
- [ ] Screenshot proof that it's gone (e.g. the process list or user list afterward)
