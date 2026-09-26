# Essentials

If I only read one page tomorrow, it's this one. Full details live in [complex/](complex/).
**Rule for myself:** before I run a command, I can say in one sentence what it does. If I can't, I ask the AI first.

---

## 1. The loop (all day)
1. **Quotient** — anything red? → section 6.
2. **Injects** — anything new? Note the deadline. → [templates/](templates/)
3. **Hunt** — run the sweep (section 5) on one box.
4. **Write it down** — time, box, what I found, what I did, screenshot.

---

## 2. First 30 minutes
| Step | Why |
|---|---|
| Change router password | Red team knows the default. If they own the router, every service dies at once. |
| Change all passwords (iron, lapis, redstone, Splunk) | Same reason — the default is public. |
| Submit the PCR in Quotient | The scorer logs in as the 10 users. New password without a PCR = my services score as down. |
| Backups (`/etc`, `/var/www`, `C:\inetpub`, DNS zones, router config) | So I can undo red team (or my own) damage without a revert. |
| Run the triage scripts → save as baseline | So later I can see exactly what changed. |
| Remove extra admins, lock unknown users | Only steve + alex should be admins. |
| **Don't** create a backup admin account | The info session suggested it, but the packet says machines should have *only* the listed users. steve, alex and Administrator already give me three ways in. Unsure → ask in Discord. |

Commands: [01-first-hour.md](complex/01-first-hour.md).

---

## 3. Core commands — Linux (iron, redstone)
| Command | What it does / why I use it |
|---|---|
| `sudo ss -tulpn` | Lists every port the box is listening on and which program owns it. Unknown port = possible backdoor. No program names = forgot sudo. |
| `systemctl status <svc>` | Is a service running? Shows the last few log lines too. |
| `sudo systemctl restart <svc>` | Stop + start a service. Needed after changing its config. |
| `journalctl -xeu <svc>` | Full log for one service — *why* it failed. `q` to quit. |
| `ps -ef --forest \| less` | All processes as a tree. Look for shells under `www-data`, or things running from `/tmp`. |
| `sudo kill -9 <PID>` | Force-kill one process. Find *why* it started first, or it comes back. |
| `who` / `last` | Who is logged in now / recently. |
| `sudo pkill -9 -t pts/N` | Kick the session on terminal `pts/N` (check it isn't me). |
| `sudo passwd <user>` | Change a user's password. It *asks* for the new one (nothing shows while typing), so it never lands in the command history where red team could read it. |
| `getent group sudo` (Ubuntu) / `wheel` (Rocky) | Who is an admin. |
| `sudo deluser <user> sudo` | Remove admin rights, keep the user. |
| `sudo usermod -L <user>` | Lock an account (reversible, keeps evidence). |
| `sudo crontab -l -u <user>` | That user's scheduled jobs — a favorite red team hiding spot. |
| `sudo sshd -t` / `sudo apache2ctl configtest` | Check a config file for mistakes *before* restarting. |
| `curl -s http://127.0.0.1/` | Does the website answer on this box? |

## 4. Core commands — Windows (lapis, PowerShell as Admin)
| Command | What it does / why I use it |
|---|---|
| `net user <user> * /domain` | Change a domain user's password. The `*` makes it *ask* for the password, so it isn't saved in PowerShell's history. |
| `Get-ADGroupMember "Domain Admins"` | Who has full control of the domain. Should be steve, alex, Administrator. |
| `Remove-ADGroupMember "Domain Admins" -Members <u> -Confirm:$false` | Take admin away. |
| `Disable-ADAccount <u>` / `Enable-ADAccount <u>` / `Unlock-ADAccount <u>` | Turn an account off/on, or unlock it (scored users must stay on and unlocked). |
| `Get-Service <name>` / `Start-Service <name>` | Is a service running / start it. Key ones: `NTDS` (AD), `DNS`, `W3SVC` (IIS web), `FTPSVC`. |
| `Get-NetTCPConnection -State Listen` | Listening ports (Windows version of `ss`). |
| `query user` → `logoff <ID>` | See / kick logged-in sessions. |
| `Get-ScheduledTask \| ? TaskPath -notlike '\Microsoft\*'` | Scheduled tasks that aren't built in — check each one. |
| `Get-MpPreference \| select DisableRealtimeMonitoring,Exclusion*` | Did red team turn Defender off or hide a folder from it? |
| `iisreset` | Restart the web server. |
| `services.msc`, `taskschd.msc`, `wf.msc`, `eventvwr`, `dsa.msc` | GUI tools: services, tasks, firewall, event logs, AD users. |

**Router (bedrock):** `configure` → `set ...` → `commit` → `save` → `exit`. Look with `show nat destination rules` and `show firewall`.

---

## 5. Systematic threat hunt (same order, every box, every ~hour)
Ask these questions in order. Each one maps to a way red team keeps access.

| # | Question | Linux | Windows |
|---|---|---|---|
| 1 | Is someone logged in who shouldn't be? | `who`, `last` | `query user` |
| 2 | Is something listening that shouldn't be? | `sudo ss -tulpn` | `Get-NetTCPConnection -State Listen` |
| 3 | Is something running that shouldn't be? | `ps -ef --forest` | Task Manager / `Get-Process` |
| 4 | Is there a new user or admin? | `/etc/passwd`, `getent group sudo` | `Get-ADUser`, `Get-ADGroupMember` |
| 5 | Is something set to run on a schedule or at boot? | crontabs, `systemctl list-timers`, `/etc/systemd/system` | scheduled tasks, services, Run keys |
| 6 | Is there a secret way to log in? | `authorized_keys` files | sticky keys (`sethc.exe`) |
| 7 | Was a security control switched off? | firewall rules | Defender, firewall |
| 8 | Did files change? | `find /etc /var/www /tmp -mmin -60` | newest files in `C:\inetpub` |

**Shortcut:** the triage script checks nearly all of this. Run it, diff against the baseline, then investigate only the new lines.

When I find something: **screenshot → note it → remove it → remove whatever re-creates it → check Quotient.**

---

## 6. Service down — 5 questions
Step-by-step version: [4-service-down.md](4-service-down.md)

1. **All services down?** → router NAT/firewall, or a firewall rule I just added.
2. **Is it running?** `systemctl status` / `Get-Service` → start it; if it won't start, read the log and test the config.
3. **Is it listening?** `ss -tulpn` / `Get-NetTCPConnection`.
4. **Does it work locally?** `curl` from the box itself. Works locally but not from outside = firewall.
5. **Right content / right login?** Page defaced → restore from backup. Login check failing → user locked or disabled, or PCR mismatch.

Still stuck after 20 minutes? Ask the AI with the real error output ([7-ai-prompts](7-ai-prompts.md)). Revert = last resort (100 points).

---

## 7. The triage scripts — what they are and how to run them
**Read-only.** They look, they never change anything. Safe to run any time.

**Run (Linux):**
```bash
sudo bash triage.sh > ~/t-base.txt      # once, right after passwords are changed
sudo bash triage.sh > ~/t-now.txt       # later
diff ~/t-base.txt ~/t-now.txt           # lines starting with ">" are new
```
**Run (Windows, PowerShell as Admin):**
```powershell
powershell -ExecutionPolicy Bypass -File .\triage.ps1 > C:\bk\t-base.txt
powershell -ExecutionPolicy Bypass -File .\triage.ps1 > C:\bk\t-now.txt
Compare-Object (Get-Content C:\bk\t-base.txt) (Get-Content C:\bk\t-now.txt)   # "=>" = new
```
`-ExecutionPolicy Bypass` lets this one script run. Windows blocks downloaded scripts by default.
How to get them onto the box: [scripts/README.md](scripts/README.md).

**What each section of the output means:**
| Section | What a new line there probably means |
|---|---|
| USERS / UID 0 / ADMIN GROUPS / SUDOERS / PRIVILEGED GROUPS | Red team made an account or gave one admin rights |
| AUTHORIZED KEYS | Red team can SSH in without a password |
| LISTENING PORTS | A backdoor or unwanted service is waiting for connections |
| RUNNING / ENABLED SERVICES, UNIT FILES | A service was added so their program restarts on boot |
| TIMERS / CRONTABS / SYSTEM CRON / SCHEDULED TASKS | Their program re-runs on a schedule (re-breaking my services) |
| LD PRELOAD / RC.LOCAL / RUN KEYS / STARTUP FOLDERS | Something runs at boot or login |
| SUID FILES | A program anyone can run as root — privilege escalation |
| PROCESSES | Something new is running right now |
| /tmp /dev/shm FILES | Dropped malware (these folders are world-writable) |
| IFEO / ACCESSIBILITY SIZES | Sticky-keys backdoor: a shell on the login screen |
| DEFENDER / FIREWALL | A security control was turned off or bypassed |
| WMI CONSUMERS | Hidden Windows persistence |
| WEB FILES | A web shell or defaced page |
| SESSIONS | Someone is logged in (also changes when I log in — check who) |

---

## 8. Screenshots
**`Win + Shift + S`** → drag a box → it's copied → **`Ctrl + V`** into my document. Also auto-saved to **Pictures → Screenshots**.

| Keys | What it does |
|---|---|
| `Win + Shift + S` | Snip part of the screen (the main one) |
| `Win + PrtScn` | Whole screen, saved to Pictures → Screenshots |
| `Alt + PrtScn` | Just the active window, copied |

Works on everything: Proxmox console, Remote Desktop, SSH, Splunk, Quotient.

- **Crop to the evidence** — not the whole terminal.
- **Show where it came from** — include the prompt with the machine name (`steve@iron:~$`) or the Splunk search bar.
- **Show the time** for incident reports — run `date` (Linux) / `Get-Date` (Windows) right before.
- **Screenshot before deleting** anything red team left.
- **In injects:** center it, caption it ("Figure 1: …").
- **In my notes:** write the time next to each finding to match it with the saved screenshot.