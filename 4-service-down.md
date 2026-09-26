# A service is red in Quotient

Stay calm. Write down the time it went red. Go top to bottom — stop as soon as it's fixed.
More detail: [complex/06-service-down.md](complex/06-service-down.md)

## Step 1 — How much is broken?
| What I see | Most likely cause | Go to |
|---|---|---|
| **Everything** is red | Router, or a firewall rule | Step 6 |
| Everything on **one machine** is red | Machine is off/frozen, or its firewall | Proxmox → is it running? Then Step 6 |
| **One service** is red | That service | Step 2 |
| It went red right after **I changed something** | My change | Undo it |
| It went red right after **I changed a password** | Missing PCR — or a service/website that logs in as that user | Submit the PCR, then Step 5 |

## Step 2 — Is it running?
| | Linux | Windows |
|---|---|---|
| Check | `systemctl status <name>` | `Get-Service <name>` |
| Start | `sudo systemctl start <name>` | `Start-Service <name>` |
| Why did it stop? | `journalctl -xeu <name>` | Event Viewer → Windows Logs → System |

## Step 3 — Which name do I use?
| Scored service | Linux name (try these) | Windows name |
|---|---|---|
| HTTP (website) | `apache2` or `nginx` (iron), `httpd` (Rocky) | `W3SVC` — or just run `iisreset` |
| SSH | `ssh` (Ubuntu), `sshd` (Rocky) | — |
| FTP | `vsftpd` or `proftpd` | `FTPSVC` |
| POP3 (email) | `dovecot` | — |
| AD / DNS | — | `NTDS` and `DNS` |

## Step 4 — It won't start? The config file is probably broken
Test the config — the error message tells me the file and line:
| Service | Test command |
|---|---|
| Apache | `sudo apache2ctl configtest` |
| Nginx | `sudo nginx -t` |
| SSH | `sudo sshd -t` |
| Dovecot | `sudo doveconf -n` |
Fix that line (or restore the file from my backup), then start it again.

## Step 5 — It's running but still red?
| Check | How | If it's wrong |
|---|---|---|
| Is it listening? | `sudo ss -tulpn` (Windows: `Get-NetTCPConnection -State Listen`) | Not in the list → config problem |
| Does it work from the machine itself? | `curl http://127.0.0.1` for websites | Works here but not from Quotient → firewall (Step 6) |
| Is the web page the original? | Open it in a browser | Defaced → restore from backup |
| Can the scored users log in? | Try logging in as one | Locked/disabled → unlock/enable. Password ≠ PCR → fix |
| Is the disk full? | `df -h` | Delete red team's junk files |
| Does the website need a database? | `systemctl status mysql mariadb postgresql` | Database stopped → start it; the website fails without it |
| Does a service log in as a user whose password I changed? | Windows: `Get-CimInstance Win32_Service \| ? { $_.StartName -notmatch 'LocalSystem\|NT AUTHORITY\|NT SERVICE\|^$' } \| ft Name,StartName` | Give it the new password: `sc.exe config <Service> password= NEWPASSWORD` (space after `=` required), then `Start-Service <Service>`. Linux: check the site's config file for the old password. |
| AD/DNS logins failing? Is the clock right? | On lapis: `w32tm /query /status` and compare with real time | More than 5 minutes off breaks AD logins → `w32tm /resync` |

## Step 6 — Firewall and router
- **Machine firewall:** did I (or red team) turn on a firewall or add a block rule? Linux: `sudo ufw status` · Windows: `wf.msc` → look for Block rules.
- **Router:** SSH to the router → `show nat destination rules` and `show firewall`. Compare with my backup. See [complex/04-bedrock-vyos-router.md](complex/04-bedrock-vyos-router.md).

## Step 7 — Still stuck after 20 minutes?
1. Ask the AI with the exact error message ([7-ai-prompts.md](7-ai-prompts.md)).
2. Last resort: revert through a Discord ticket (costs 100 points the first time). Afterward, redo passwords + PCR right away.

**Once it's fixed:** write down what happened — it may be an incident report.
