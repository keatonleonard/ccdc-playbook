# First hour — do this in order

Keep a notes file open the whole time. Every entry: **time — box — what I did / what I found.**
That notes file becomes my incident reports.

## 9:00–10:00 Setup (don't touch the boxes until told)
- [ ] Authentik sign-up → write down team number (on paper, tell nobody).
- [ ] Connect NetBird VPN. Open Proxmox (pool view), Quotient, Discord.
- [ ] Open this repo in a browser tab. Open the no-login AI in another tab and confirm it works.
- [ ] Open a word processor for injects (local app → export PDF). Snipping tool = `Win+Shift+S`.
- [ ] **Printed password sheet in front of me** (kept offline, never in this repo). Use password #1 for each account.
- [ ] Find the PCR page in Quotient and see what format it wants.

**Why I never type a password into a command:** Linux and PowerShell save typed commands to a history file red team can read. `sudo passwd <user>` and `net user <user> * /domain` *ask* for the password instead, so it's never saved. Nothing shows on screen while I type it — that's normal.

## 10:00 Go

### 1. Router password (2 min) — [04](04-bedrock-vyos-router.md)
Proxmox console → bedrock → log in as `vyos`:
```
configure
set system login user vyos authentication plaintext-password 'ROUTER-PASSWORD-FROM-SHEET'
commit
save
exit
```
(VyOS has no prompt version of this — the router stores it scrambled, which is fine.)
While there: `show configuration commands | grep 'system login'` → only `vyos` should exist.

### 2. iron (Ubuntu) passwords — [02](02-iron-ubuntu.md)
SSH over NetBird: `ssh steve@172.16.1.10` (or the public IP).
Each command asks for the new password twice (from the sheet):
```bash
sudo passwd steve
sudo passwd alex
sudo passwd root
sudo passwd enderman       # ...and the same for creeper, villager, zombie, enderdragon, irongolem, chickenjockey, ghast
realm list 2>/dev/null     # if this prints a domain, users may be AD users -> change them on lapis instead
who                        # anyone logged in who isn't me?
```
Same password for a user on every machine (the PCR has one password per user).
Kick a session that isn't mine: `sudo pkill -9 -t pts/N` (check with `who` first — don't kill my own).

### 3. lapis (Windows DC) passwords — [03](03-lapis-windows-dc.md)
Proxmox console (or RDP over NetBird). Open **PowerShell as Administrator**:
Each command asks for the new password twice (from the sheet):
```powershell
net user steve * /domain
net user alex * /domain
net user Administrator * /domain
net user enderman * /domain      # ...and the same for the other 7 users
query user                       # other sessions? logoff <ID>
```

### 4. redstone (Rocky + Splunk)
```bash
sudo passwd steve
sudo passwd root
```
Splunk web `http://172.16.1.12:8000` → log in `admin` → top-right Account/Settings → change to the Splunk password from the sheet.
(Also change passwords of any regular users on this box that exist — `getent passwd | awk -F: '$3>=1000'`.)

### 5. Submit the PCR in Quotient
Every scored user whose password I changed (steve, alex, and the 8 users) — on every box where they log in.
Then **watch Quotient for one scoring round.** If something went red after the password change, the PCR is wrong or the service uses a different account.

### 6. Backups (before I change anything else)
iron:
```bash
sudo tar czf /root/bk-start.tgz /etc /var/www /home 2>/dev/null
sudo cp /root/bk-start.tgz /var/lib/.bk-start.tgz     # second copy, red team may wipe /root
```
lapis (PowerShell admin):
```powershell
mkdir C:\bk -Force
Copy-Item C:\inetpub C:\bk\inetpub -Recurse -ErrorAction SilentlyContinue
Get-DnsServerZone | ? {-not $_.IsAutoCreated} | % { dnscmd /zoneexport $_.ZoneName "bk_$($_.ZoneName).dns" }   # saved in C:\Windows\System32\dns\
```
bedrock: `configure` → `save /config/bk-start.config` → `exit`

### 7. Baseline triage (read-only) — [scripts/](../scripts/)
Run the triage script on iron, redstone and lapis and save the output. Later re-runs + diff show what red team added.

### 8. Who's an admin who shouldn't be?
- iron: `getent group sudo adm` and `sudo ls /etc/sudoers.d; sudo grep -v '^#' /etc/sudoers | grep -v '^$'`
- redstone: `getent group wheel`
- lapis: `Get-ADGroupMember "Domain Admins" | select SamAccountName` (and Administrators, Enterprise Admins)
- Only steve and alex (+ built-in Administrator on Windows) belong there. Remove others (see box pages). Users not on the list → lock/disable, don't delete (evidence).

### 9. Fill in the service map
Run `sudo ss -tulpn` on iron/redstone and the listener command on lapis ([03](03-lapis-windows-dc.md)). Write down:

| Service | Port | Box | Program (apache2? vsftpd? IIS?) |
|---|---|---|---|
| HTTP | 80/443 | | |
| SSH | 22 | | |
| FTP | 21 | | |
| POP3 | 110 | | |
| AD/DNS | 389/53 | lapis | NTDS / DNS |

### 10. Check Quotient. Then read the injects.
From here: [07 threat hunting](07-threat-hunting.md), [08 injects](08-injects-and-ir.md), and [06](06-service-down.md) whenever something goes red.
