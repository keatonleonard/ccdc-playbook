# iron — Ubuntu Server 18.04

Private `172.16.1.10`, public `192.168.(200+x).10`. Likely runs some of HTTP / SSH / FTP / POP3 — confirm with `ss`.
18.04 is end-of-life: **don't run `apt upgrade`** (slow, may fail, may break services).

## See what's running
```bash
sudo ss -tulpn                                   # what's listening and which program owns it
systemctl list-units --type=service --state=running
ps -ef --forest | less                           # process tree; look for shells under www-data, weird paths (/tmp, /dev/shm)
who; w; last | head -20                          # who is logged in / recently logged in
```

## Users
```bash
awk -F: '$3==0 {print "UID0:",$1}' /etc/passwd              # only root should be UID 0
awk -F: '$3>=1000 && $3<65534 {print $1,$3,$7}' /etc/passwd  # human users — compare to the list
grep -vE 'nologin|false|sync|halt|shutdown' /etc/passwd     # accounts that can log in
getent group sudo adm                                       # only steve, alex
sudo cat /etc/sudoers | grep -v '^#' | grep -v '^$'; sudo ls -la /etc/sudoers.d/
```
Fix:
```bash
sudo deluser <user> sudo                   # remove from sudo group (user stays)
sudo usermod -L -e 1 -s /usr/sbin/nologin <baduser>   # lock an unknown account (don't delete — evidence)
sudo pkill -9 -u <baduser>                 # kill its processes
```
Extra line in sudoers like `creeper ALL=(ALL) NOPASSWD:ALL` → edit with `sudo visudo` (or delete the file in /etc/sudoers.d/).

## SSH (keep password login ON — the scorer logs in with passwords)
```bash
sudo find / -name authorized_keys 2>/dev/null -exec ls -la {} \; -exec cat {} \;
```
Keys I didn't put there → move them out: `sudo mv /home/u/.ssh/authorized_keys /root/evidence_u_keys`

`sudo nano /etc/ssh/sshd_config` — set:
```
PermitRootLogin no
PermitEmptyPasswords no
```
Do **not** set `PasswordAuthentication no`. Check nothing weird like a second `Port` or `AuthorizedKeysFile /tmp/...`.
```bash
sudo sshd -t && sudo systemctl restart ssh      # -t tests config first; no output = OK
```
Stay logged in in one window while testing a new SSH login in another.

## Persistence hunt
```bash
# cron
for u in $(cut -d: -f1 /etc/passwd); do sudo crontab -l -u $u 2>/dev/null | grep -v '^#' | sed "s/^/[$u] /"; done
cat /etc/crontab; ls -la /etc/cron.d /etc/cron.hourly /etc/cron.daily
systemctl list-timers --all
# systemd services added recently
ls -lt /etc/systemd/system/ /lib/systemd/system/ | head -20
# startup scripts / shell rc files
cat /etc/rc.local 2>/dev/null; ls -la /etc/profile.d/
sudo grep -H -E 'nc |ncat|bash -i|/dev/tcp|curl|wget|python' /root/.bashrc /home/*/.bashrc /etc/bash.bashrc /etc/profile 2>/dev/null
cat /etc/ld.so.preload 2>/dev/null               # should not exist / be empty
# files changed in the last hour in interesting places
sudo find /etc /usr/bin /usr/sbin /usr/lib /var/www /tmp /var/tmp /dev/shm -type f -mmin -60 2>/dev/null
# SUID binaries — red flags: bash, find, vim, python, cp, nano with SUID
sudo find / -perm -4000 -type f 2>/dev/null
# system files that don't match their package (replaced binaries, PAM backdoors)
sudo dpkg -V 2>/dev/null | grep -v ' c /'
```
Removing something: **screenshot first**, then e.g.
```bash
sudo systemctl disable --now evil.service; sudo mv /etc/systemd/system/evil.service /root/evidence/
sudo crontab -r -u <user>        # or crontab -e -u <user> to delete one line
sudo chmod u-s /usr/bin/find     # remove SUID bit
```

## Web
```bash
ls -la /var/www/html
sudo grep -rlE 'system\(|shell_exec|passthru|eval\(|base64_decode|exec\(' /var/www 2>/dev/null   # possible web shells
sudo tail -50 /var/log/apache2/access.log     # or /var/log/nginx/access.log
```
Don't edit real site content (scoring compares MD5). Move a web shell out, don't edit around it.

## Services quick reference
| Service | Status / restart | Config | Test config | Logs |
|---|---|---|---|---|
| Apache | `systemctl status apache2` | /etc/apache2/ | `sudo apache2ctl configtest` | /var/log/apache2/ |
| Nginx | `systemctl status nginx` | /etc/nginx/ | `sudo nginx -t` | /var/log/nginx/ |
| SSH | `systemctl status ssh` | /etc/ssh/sshd_config | `sudo sshd -t` | /var/log/auth.log |
| vsftpd | `systemctl status vsftpd` | /etc/vsftpd.conf | — | /var/log/vsftpd.log |
| ProFTPD | `systemctl status proftpd` | /etc/proftpd/ | `sudo proftpd -t` | /var/log/proftpd/ |
| Dovecot (POP3) | `systemctl status dovecot` | /etc/dovecot/ | `sudo doveconf -n` | /var/log/mail.log |
| Splunk fwd | `sudo /opt/splunkforwarder/bin/splunk status` | — | **don't disable** | |

FTP hardening: in vsftpd.conf set `anonymous_enable=NO` (unless an inject wants anonymous), keep `local_enable=YES`.

## Host firewall (optional, careful)
FTP passive mode uses random high ports — a firewall can silently break FTP scoring. Only do this if I know the ports.
```bash
sudo ufw status verbose
sudo ufw allow 22/tcp; sudo ufw allow 80/tcp; sudo ufw allow 443/tcp; sudo ufw allow 21/tcp; sudo ufw allow 110/tcp
sudo ufw enable          # then check Quotient immediately; `sudo ufw disable` to undo
```
