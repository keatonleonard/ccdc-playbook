# A service is red in Quotient

Stay calm. Work top to bottom. Write down the time it went red (incident report material).

## 0. One service or all of them?
- **All (or all on one box)** → network: router NAT/firewall ([04](04-bedrock-vyos-router.md)), host firewall I just enabled, box powered off/hung (check Proxmox).
- **One** → keep going.
- **Did I just change something?** Undo it first. Password change → did I submit the PCR?

## 1. Is the program running?
| | Linux | Windows |
|---|---|---|
| status | `systemctl status <svc>` | `Get-Service <svc>` |
| start | `sudo systemctl start <svc>` | `Start-Service <svc>` |
| why it died | `journalctl -xeu <svc>` | `eventvwr` → Windows Logs → System |
| set to start at boot | `sudo systemctl enable <svc>` | `Set-Service <svc> -StartupType Automatic` |

If it won't start, the config is probably broken. Test it: `apache2ctl configtest`, `nginx -t`, `sshd -t`, `doveconf -n`, `proftpd -t`. Compare with the backup: `diff /etc/x.conf <(tar xzOf /root/bk-start.tgz etc/x.conf)`.

## 2. Is it listening on the right port?
- Linux: `sudo ss -tulpn | grep -E ':(21|22|80|443|110) '`
- Windows: `Get-NetTCPConnection -State Listen -LocalPort 53,80,389,21`
Listening only on `127.0.0.1` instead of `0.0.0.0`/`*` → outside can't reach it (check `Listen`/`listen_address` in the config).

## 3. Does it work from the box itself?
```bash
curl -s http://127.0.0.1/ | head                        # HTTP
curl -v ftp://creeper:PASS@127.0.0.1/                    # FTP login
curl -v pop3://creeper:PASS@127.0.0.1/                   # POP3 login
ssh creeper@127.0.0.1                                    # SSH
nslookup <some-name> 172.16.1.11                         # DNS
```
Works locally but not from outside → firewall (host or router).

## 4. Does it work via the public IP?
From another box: same tests against `192.168.(200+x).N`. Fails → router NAT/firewall or host firewall.

## 5. Right content / right login?
- HTTP checks page **content** (MD5/keywords). Defaced or missing page? Restore from backup:
  `sudo tar xzf /root/bk-start.tgz -C / var/www` (restores /var/www) — or `Copy-Item C:\bk\inetpub\* C:\inetpub -Recurse -Force`.
- Login-based check failing → user disabled/locked/password changed? `sudo passwd -S <user>`, `Get-ADUser <user> -Properties LockedOut,Enabled`. Unlock/enable. PCR matches?
- Scorer user's shell set to `nologin`? `grep creeper /etc/passwd`.

## 6. Other common causes
- Disk full: `df -h` (Linux) — red team fills disks.
- Firewall rule red team added (host or router).
- Service replaced/stopped by a cron job or scheduled task that keeps killing it → find the persistence ([07](07-threat-hunting.md)).
- Web app needs a database: `systemctl status mysql mariadb postgresql`.
- DNS/AD: time out of sync (`w32tm /query /status`), NTDS/DNS service stopped, DNS zone/record deleted (`Get-DnsServerResourceRecord -ZoneName <zone>` vs backup).

## 7. Still broken after ~20 min?
Ask the AI with real output ([09](09-ai-prompts.md)). Last resort: **revert** via Discord ticket (100 pts first time) — cost it against how many points the service loses per hour. After a revert, the box is back to defaults: redo passwords + PCR immediately.
