# Threat hunting

**Assume breach.** Red team probably logged in with the default password before I changed it and left a way back in.
Loop: **Hypothesize → Collect → Analyze → Act** (and document before deleting).

## What red team does, and where it shows up
| Stage | Evidence | Where |
|---|---|---|
| Recon | one IP hitting many ports; scanner user-agents | web access logs, firewall logs |
| Get in | many failed logins then a success; weird web requests (`../`, `cmd=`) | `auth.log`/`secure`, 4625→4624, access/error logs |
| Stay in | new users, sudo/admin group changes, cron/scheduled tasks, services, SSH keys | 4720, 4732, 4698, 7045; `/etc/passwd`, crontabs, `authorized_keys` |
| Hurt me | services stopped, configs changed, pages defaced, firewall rules | Quotient, `journalctl`, System log |

## The 10-minute sweep (per box, repeat every ~hour)
**Linux** (details in [02](02-iron-ubuntu.md)):
1. `who; w; last | head` — sessions that aren't me
2. `sudo ss -tulpn` — listeners I don't recognize
3. `ps -ef --forest` — shells under `www-data`, processes from `/tmp`, `/dev/shm`, `nc`, `python -c`, `bash -i`
4. Users: UID 0, new users, sudo/wheel members
5. Cron (all users + `/etc/cron*`), `systemctl list-timers`, new files in `/etc/systemd/system`
6. `authorized_keys` everywhere
7. `find ... -mmin -60` in `/etc /var/www /tmp /dev/shm /usr/bin`

**Windows** (details in [03](03-lapis-windows-dc.md)):
1. `query user` — sessions
2. Listeners with owning process
3. New AD users (sort by whenCreated), admin group members
4. Non-Microsoft scheduled tasks, services with odd paths
5. Run keys, startup folders, sticky-keys/utilman
6. Defender off / exclusions
7. New files in `C:\inetpub`, `C:\Windows\Temp`, `C:\Users\Public`

**Fastest way to spot new things:** re-run the triage script and diff against the baseline ([scripts/](../scripts/README.md)).

## Killing a reverse shell (Linux)
```bash
sudo ss -tunp | grep ESTAB          # outbound connections + PID
ps -ef --forest | less              # find its parent (web server? cron?)
# document: PID, user, command, parent, remote IP  → screenshot
sudo kill -9 <PID>
# then remove WHY it started (cron/service/web shell), or it respawns
```
Windows: `Get-NetTCPConnection -State Established | select RemoteAddress,RemotePort,OwningProcess,@{n='Proc';e={(Get-Process -Id $_.OwningProcess).Path}}` → `Stop-Process -Id <PID> -Force`.

## Windows Event IDs worth knowing
| ID | Meaning |
|---|---|
| 4624 / 4625 | logon success / failure (type 3 = network, 10 = RDP) |
| 4720 | user created |
| 4722 / 4724 / 4738 | user enabled / password reset / user changed |
| 4728 / 4732 / 4756 | added to global / local / universal group |
| 4698 | scheduled task created |
| 7045 | service installed (System log) |
| 1102 | security log cleared |
| 4688 | process created |
| 4104 | PowerShell script block |
Look up any others: ultimatewindowssecurity.com/securitylog/encyclopedia

## Linux log files
| Ubuntu (iron) | Rocky (redstone) | What |
|---|---|---|
| `/var/log/auth.log` | `/var/log/secure` | logins, sudo |
| `/var/log/syslog` | `/var/log/messages` | cron, services |
| `/var/log/apache2/` | `/var/log/httpd/` | web |
| — | `/var/log/audit/audit.log` | auditd (`sudo ausearch -m USER_LOGIN`) |
`sudo grep -E "Accepted|Failed" /var/log/auth.log | tail -30` is a great first look.

## Map it to MITRE ATT&CK (makes incident reports look pro)
T1136 Create Account · T1098 Account Manipulation · T1053 Scheduled Task/Cron · T1543 Create/Modify System Process (service) · T1505.003 Web Shell · T1110 Brute Force · T1078 Valid Accounts · T1098.004 SSH Authorized Keys · T1546.008 Accessibility Features (sticky keys) · T1562.001 Disable/Modify Tools (Defender) · T1489 Service Stop.
