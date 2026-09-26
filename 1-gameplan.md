# Game Plan

## How to win points
- **Half:** keep the services working (HTTP, SSH, FTP, AD/DNS, POP3)
- **Half:** turn in every inject on time
- **Bonus:** incident reports win back points red team took
- **Avoid:** reverts cost points

## My three habits
1. **Check Quotient often.**
2. **Never miss an inject deadline.** Set timers.
3. **Write down everything I find.** Time, machine, what, screenshot.

---

## Before 10:00 — Get set up
- [ ] Get my team number (write it on paper, tell no one)
- [ ] Connect the VPN, open Proxmox, Quotient, Discord
- [ ] Open this repo and the no-login AI in browser tabs
- [ ] Open my word processor with my templates
- [ ] Have my password sheet in front of me
- [ ] Find the Password Change Request (PCR) page in Quotient
- [ ] Make sure Inject 1 is submitted (check its deadline in Quotient)
- [ ] Find the Incident Response inject in Quotient — it opens at the start and is due at the end

## 10:00 – 10:45 — Lock the doors
- [ ] Change the router password
- [ ] Change every password on every machine (my password sheet)
- [ ] Submit the PCR for the scored users
- [ ] Check Quotient — still all green?
- [ ] Back up the important files on each machine
- [ ] Run my triage scripts to save a "normal" snapshot
- [ ] Remove anyone who shouldn't be an admin
- [ ] Don't create extra "backup" accounts — the packet says only the listed users. steve, alex and Administrator are my backups. (Unsure? Ask in Discord.)
- [ ] Write down which service runs on which machine

## 10:45 – 11:30 — Find what red team left behind
- [ ] Go through my hunt checklist on iron, then lapis
- [ ] Look in Splunk for strange logins
- [ ] Read any injects that came in and note their deadlines

## 11:30 – 3:00 — Repeat the loop
1. Quotient — anything red?
2. Injects — anything new or due soon?
3. Hunt — one machine at a time
4. Write it down

*Pizza around noon — eat while I work.*

## 3:00 – 4:00 — Finish strong
- [ ] Write my incident reports from my notes
- [ ] Submit anything unfinished — partial credit is still credit
- [ ] Everything in by 3:50

---

## When something goes wrong
| If... | Then... |
|---|---|
| One service is red | Follow [4-service-down](4-service-down.md) |
| Everything is red | Check the router first ([4-service-down](4-service-down.md), step 6) |
| I just changed something and it broke | Undo my change |
| I changed a password and a service went red | Did I submit the PCR? Does a service log in as that user? ([4-service-down](4-service-down.md), step 5) |
| I find something from red team | Screenshot → write it down → remove it |
| I've been stuck 20 minutes | Ask the AI with the exact error ([7-ai-prompts](7-ai-prompts.md)) |
| Nothing works and time is running out | Consider a revert (costs points) |

## Rules I can't break
- No AI in my inject writing — every word is mine
- Team number on injects, never my name
- Don't block IP addresses
- Don't change the website content
- Don't turn off the Splunk forwarders
- Never share my team number
