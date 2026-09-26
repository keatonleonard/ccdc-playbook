# Access Guide — how to get into each machine

## Step 0: fill this in by hand tomorrow (on paper, not here)
My team number: **x = ____**
My public IP prefix: **192.168.(200 + x)** = **192.168.______**
(Example: team 12 → 192.168.212)

## Step 1: the competition websites
| Site | Address | What it's for |
|---|---|---|
| Authentik | `https://auth.byuccdc.org` | Sign up in the morning → team number, links to everything below |
| Quotient | `https://scoring.byuccdc.org` | Service status (red/green), injects, PCRs |
| Proxmox | link in Authentik | Machine consoles (Pool view) |
| NetBird | link in Authentik | VPN — needed for SSH / Remote Desktop |
| Discord | `https://discord.gg/XFEKJRxZY` | Announcements, support, **revert requests (`ticket` channel)** |

**Connect NetBird first.** Without it, SSH won't reach anything.

## Step 2: pick the machine
The session notes say my laptop reaches the machines *through the router*, so **try the public IP first**. If it doesn't answer, try the private one.

| Machine | What it is | Public IP (try first) | Private IP (backup) | Way in | Account |
|---|---|---|---|---|---|
| **iron** | Ubuntu Linux | `192.168.___.10` | `172.16.1.10` | SSH, port 22 | `steve` |
| **redstone** | Rocky Linux + Splunk | `192.168.___.12` | `172.16.1.12` | SSH, port 22 | `steve` |
| **redstone Splunk** | Splunk website | `http://192.168.___.12:8000` | `http://172.16.1.12:8000` | Browser | `admin` |
| **bedrock** | VyOS router | `192.168.___.2` | `172.16.1.1` | SSH, port 22 (or Proxmox console) | `vyos` |
| **lapis** | Windows Server | `192.168.___.11` | `172.16.1.11` | Remote Desktop, port 3389 (or Proxmox console) | `steve` |

If neither IP works, use the **Proxmox console** (always works).

---

## SSH into a Linux machine or the router
Open **PowerShell** or **Terminal** on my laptop (SSH is built into Windows). Fill in my prefix:
```
ssh steve@192.168.___.10        # iron
ssh steve@192.168.___.12        # redstone
ssh vyos@192.168.___.2          # bedrock (router)
```
Backup (private IPs): `ssh steve@172.16.1.10` · `ssh steve@172.16.1.12` · `ssh vyos@172.16.1.1`

- First time it asks `Are you sure you want to continue connecting?` → type `yes`.
- When typing the password, **nothing shows on screen** — that's normal. Type it and press Enter.
- **Paste** into the terminal: right-click, or `Ctrl+Shift+V`.
- **Leave:** type `exit`.
- Log in as a different user: change the name before `@`, e.g. `ssh alex@192.168.___.10`.

**Error: `REMOTE HOST IDENTIFICATION HAS CHANGED`** (happens after a revert) — forget the old key, then SSH again:
```
ssh-keygen -R 192.168.___.10
```

**Copy a file (like my triage script) to a Linux machine:**
```
scp triage.sh steve@192.168.___.10:
```

## Remote Desktop into lapis (Windows)
1. `Win + R` → type `mstsc` → Enter
2. Computer: `192.168.___.11` (backup: `172.16.1.11`) → Connect
3. Username: `steve` — if that fails, use `DOMAIN\steve` (find the domain name on the lapis login screen in Proxmox)
4. Accept the certificate warning
Copy/paste works through Remote Desktop.

## Proxmox console (backup for every machine)
Authentik → **Proxmox** → **Pool view** → click the machine → **Console**.
- **Windows login screen:** use the Ctrl+Alt+Del button in the console's side menu (pressing the keys hits my laptop, not the VM).
- **Copy/paste doesn't work** here → use SSH/Remote Desktop for long commands.

## Can't get in?
| Problem | Try |
|---|---|
| `Connection timed out` | VPN connected? Try the other IP. Machine powered on in Proxmox? |
| `Connection refused` | SSH service is down → fix it from the Proxmox console: `sudo systemctl start ssh` (iron) or `sudo systemctl start sshd` (redstone) |
| `Permission denied` | Wrong password → check my sheet. Red team may have changed it → log in from the Proxmox console as another admin. |
| Remote Desktop fails | Use the Proxmox console |
