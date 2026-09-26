# Triage scripts (read-only — they change nothing)

Run once right after the password changes → **baseline**. Re-run every ~30–60 min and diff → whatever is new is what red team added (or what I changed).

Replace `<me>/<repo>` with my GitHub username/repo name.

## Linux (iron, redstone)
```bash
curl -sO https://raw.githubusercontent.com/<me>/<repo>/main/scripts/triage.sh
sudo bash triage.sh > ~/t-base.txt
# later
sudo bash triage.sh > ~/t-now.txt
diff ~/t-base.txt ~/t-now.txt          # ">" lines = new
```
`curl: command not found`? Use: `wget https://raw.githubusercontent.com/<me>/<repo>/main/scripts/triage.sh`
No internet on the box? From my laptop over NetBird: `scp triage.sh steve@172.16.1.10:`

Error like `$'\r': command not found`? The file got Windows line endings (e.g. saved in Notepad). Fix it on the box:
```bash
sed -i 's/\r$//' triage.sh
```

## Windows (lapis) — PowerShell as Administrator
```powershell
mkdir C:\bk -Force; cd C:\bk
[Net.ServicePointManager]::SecurityProtocol = 'Tls12'
Invoke-WebRequest https://raw.githubusercontent.com/<me>/<repo>/main/scripts/triage.ps1 -OutFile triage.ps1 -UseBasicParsing
powershell -ExecutionPolicy Bypass -File .\triage.ps1 > C:\bk\t-base.txt
# later
powershell -ExecutionPolicy Bypass -File .\triage.ps1 > C:\bk\t-now.txt
Compare-Object (Get-Content C:\bk\t-base.txt) (Get-Content C:\bk\t-now.txt)     # "=>" = new
```

Red team may delete these files — keep a copy of the baseline in a second place too.
