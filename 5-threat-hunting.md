# Threat hunting — the simple routine

**Assume red team is already in.** They probably logged in with the default password before I changed it and left a way back.
My job: find what they left, remove it, and write it down.
More detail: [complex/07-threat-hunting.md](complex/07-threat-hunting.md)

## The fastest way: compare snapshots
1. Run my triage script → save as the **new** snapshot ([scripts/](scripts/README.md)).
2. Compare it with the **baseline** from this morning.
3. Every new line = something to look at. Most will be things I did. The rest is red team.

## The manual routine — same 8 questions, every machine, about once an hour

| # | Question | Linux (iron, redstone) | Windows (lapis) | Red flag |
|---|---|---|---|---|
| 1 | Is someone logged in who shouldn't be? | `who` | `query user` | A session that isn't mine |
| 2 | Is something listening that shouldn't be? | `sudo ss -tulpn` | `Get-NetTCPConnection -State Listen` | A port that isn't a scored service or normal system port |
| 3 | Is something running that shouldn't be? | `ps -ef --forest` | Task Manager → Details | Shells (`bash`, `sh`, `nc`, `python`) under the web server; programs in `/tmp` |
| 4 | Is there a new user or admin? | `getent group sudo` | `Get-ADGroupMember "Domain Admins"` | Anyone besides steve and alex |
| 5 | Is something scheduled to run? | `sudo crontab -l -u <user>`, `ls /etc/cron.d` | Task Scheduler (`taskschd.msc`) | Jobs I don't recognize, especially ones calling scripts or IPs |
| 6 | Is there a secret way to log in? | `sudo find / -name authorized_keys` | — | SSH keys I didn't add |
| 7 | Was security turned off? | `sudo ufw status` | Windows Security app → Virus protection | Defender off, exclusions added |
| 8 | Were files changed recently? | `sudo find /etc /var/www /tmp -mmin -60` | Newest files in `C:\inetpub` | New `.php`/`.aspx` files = web shell |

Splunk can answer questions 1 and 4 across all machines at once: [6-splunk-guide.md](6-splunk-guide.md).

## When I find something — always in this order
1. **Screenshot it** (it's evidence for my incident report).
2. **Write it down:** time · machine · what I found · what I think it does.
3. **Not sure what it is?** Ask the AI what it does before deleting.
4. **Remove it:**
   - Unknown user → lock/disable it (don't delete)
   - Bad process → kill it (`sudo kill -9 <PID>` / Task Manager → End task)
   - Bad scheduled job/task/service → disable it, then move the file away
   - SSH key → move the `authorized_keys` file away
5. **Check if it comes back** a few minutes later. If it does, something is re-creating it — look at question 5 again.
6. **Check Quotient** — did removing it break anything?

## Common red team tricks to watch for
- A new user with a normal-looking name (`admin2`, `support`, `backup`)
- A regular user suddenly in the admin group
- A cron job or scheduled task that runs every minute
- A web page file named like `shell.php`, `cmd.aspx`, or random letters
- A program running from `/tmp`, `/dev/shm`, or `C:\Windows\Temp`
- Defender turned off, or a folder excluded from scanning
- A firewall rule blocking a scored port
