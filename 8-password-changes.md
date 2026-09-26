# Password changes — commands only

**No passwords in this file.**

**Scored users (steve, alex, and the 8 regular users): every time I change one, submit a new PCR in Quotient.**
**Use the same password for a user on every machine** (the PCR has one password per user).

When typing into `passwd` or `net user <name> *`, nothing shows on screen. That's normal.
If `sudo passwd <user>` says the user doesn't exist, that user lives in AD: change it on lapis only.

**Watch out:** if a Windows service runs as a user whose password I changed, that service stops working.
Check: `Get-CimInstance Win32_Service | ? { $_.StartName -notmatch 'LocalSystem|NT AUTHORITY|NT SERVICE|^$' } | ft Name,StartName`
Fix: `sc.exe config <ServiceName> password= NEWPASSWORD` (the space after `password=` is required), then `Start-Service <ServiceName>`.
Same idea on Linux: a website's config file may contain a user's password (e.g. for its database) — if the site breaks after a password change, that's why.

---

## Router — `vyos` (bedrock)
Not scored, no PCR needed.
```
configure
set system login user vyos authentication plaintext-password 'NEWPASSWORD'
commit
save
exit
```

## `steve` (admin, scored — PCR required)
iron and redstone:
```
sudo passwd steve
```
lapis (PowerShell as Administrator):
```
net user steve * /domain
```
Then: **submit PCR in Quotient.**

## `alex` (admin, scored — PCR required)
iron and redstone:
```
sudo passwd alex
```
lapis (PowerShell as Administrator):
```
net user alex * /domain
```
Then: **submit PCR in Quotient.**

## `Administrator` (lapis, Windows domain)
Not on the scored list, no PCR needed.
```
net user Administrator * /domain
```

## `root` (iron and redstone)
Not scored, no PCR needed.
```
sudo passwd root
```

## Splunk `admin` (redstone web interface)
Not scored, no PCR needed.
Web: top-right **admin** menu → **Account Settings** (or Settings → Users → admin → Edit) → new password → Save.
Or on redstone (saves both passwords in the shell history — prefer the web, or run `history -c` afterward):
```
sudo /opt/splunk/bin/splunk edit user admin -password 'NEWPASSWORD' -auth admin:'OLDPASSWORD'
```

---

## Regular users (all scored — PCR required after every change)
Same commands for each: `enderman`, `creeper`, `villager`, `zombie`, `enderdragon`, `irongolem`, `chickenjockey`, `ghast`

iron / redstone:
```
sudo passwd <user>
```
lapis:
```
net user <user> * /domain
```
Then **PCR**.

---

## PCR log
| Time | User(s) | Password # now in use | PCR submitted? |
|---|---|---|---|
| | | | |
| | | | |
| | | | |
| | | | |
