# lapis — Windows Server 2016 (almost certainly the Domain Controller: AD + DNS)

Private `172.16.1.11`, public `192.168.(200+x).11`. May also run IIS (HTTP/FTP).
Everything below: **PowerShell as Administrator.** In the Proxmox console use the Ctrl+Alt+Del button to log in.
On a DC there are no local users — users are domain users (`/domain`, `*-ADUser`).

## See what's running
```powershell
# what's listening and which process owns it
Get-NetTCPConnection -State Listen | Sort LocalPort | select LocalPort,OwningProcess,@{n='Proc';e={(Get-Process -Id $_.OwningProcess).Name}} -Unique
Get-Service | ? Status -eq Running | Sort Name
Get-Service NTDS,DNS,Netlogon,Kdc,W3SVC,FTPSVC,SplunkForwarder -ErrorAction SilentlyContinue
query user                      # who's logged in; kick with: logoff <ID>
```

## Users and groups
```powershell
Get-ADUser -Filter * -Properties whenCreated,Enabled | Sort whenCreated | ft SamAccountName,Enabled,whenCreated
foreach ($g in "Domain Admins","Enterprise Admins","Schema Admins","Administrators","DnsAdmins","Group Policy Creator Owners","Backup Operators","Account Operators","Server Operators") {
  "== $g"; Get-ADGroupMember $g | select -Expand SamAccountName }
```
Normal built-ins: Administrator, Guest (should be disabled), krbtgt (**never delete/disable**), DefaultAccount.
Only steve, alex (+ Administrator) should be in admin groups.
```powershell
Remove-ADGroupMember "Domain Admins" -Members creeper -Confirm:$false
Disable-ADAccount -Identity <baduser>          # unknown account: disable, don't delete
Disable-ADAccount -Identity Guest
Enable-ADAccount -Identity <scoreduser>        # if red team disabled a scored user
Unlock-ADAccount -Identity <scoreduser>        # if a scored user got locked out
```
Changing a password: `net user <user> * /domain` (asks for it, so it isn't saved in history) → **then PCR in Quotient.**
Don't turn on an account-lockout policy mid-competition: red team brute-forcing can lock out the scoring users.

## Persistence hunt
```powershell
# scheduled tasks not from Microsoft
Get-ScheduledTask | ? TaskPath -notlike '\Microsoft\*' | ft TaskName,TaskPath,State
(Get-ScheduledTask -TaskName "<name>").Actions            # what does it run?
Disable-ScheduledTask -TaskName "<name>"

# services running from odd places
Get-CimInstance Win32_Service | ? { $_.PathName -notmatch 'system32|Program Files|SysWOW64' } | ft Name,State,StartMode,PathName -Wrap

# Run keys and startup folders
Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run','HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run'
dir "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp", "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

# sticky-keys / utilman backdoor (login-screen shell)
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' | % { Get-ItemProperty $_.PSPath } | ? Debugger | select PSChildName,Debugger
Get-Item C:\Windows\System32\sethc.exe,C:\Windows\System32\utilman.exe,C:\Windows\System32\cmd.exe | ft Name,Length   # sethc/utilman same size as cmd = replaced

# Defender tampering
Get-MpPreference | select DisableRealtimeMonitoring,ExclusionPath,ExclusionProcess,ExclusionExtension
Set-MpPreference -DisableRealtimeMonitoring $false
Remove-MpPreference -ExclusionPath "C:\whatever"
Start-MpScan -ScanType QuickScan; Get-MpThreatDetection

# WMI persistence
Get-CimInstance -Namespace root\subscription -ClassName __EventConsumer

# web shells
Get-ChildItem C:\inetpub -Recurse -Include *.aspx,*.asp,*.ashx,*.php -ErrorAction SilentlyContinue | Sort LastWriteTime -Desc | select -First 20 FullName,LastWriteTime
```
GUI equivalents: `services.msc`, `taskschd.msc`, `wf.msc`, `eventvwr`, `dsa.msc` (AD Users & Computers), `dnsmgmt.msc`, `inetmgr` (IIS).

## Cheap hardening wins (low risk to scoring)
```powershell
Stop-Service Spooler -Force; Set-Service Spooler -StartupType Disabled       # PrintNightmare; DC doesn't need printing
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force                # EternalBlue
# logging (Script Block Logging + logon auditing)
New-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Force | Out-Null
Set-ItemProperty 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' -Name EnableScriptBlockLogging -Value 1
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable
```
Don't block SMB (445) or LDAP/Kerberos on a DC — AD needs them.

## Firewall
```powershell
Get-NetFirewallProfile | ft Name,Enabled,DefaultInboundAction
Get-NetFirewallRule -Enabled True -Direction Inbound -Action Block | ft DisplayName,Profile      # did red team block a scored port?
Get-NetFirewallRule -Enabled True -Direction Inbound -Action Allow | ft DisplayName -AutoSize    # anything allowing a weird port?
Set-NetFirewallProfile -All -Enabled True          # then CHECK QUOTIENT; if something breaks, add an allow rule:
New-NetFirewallRule -DisplayName "Allow HTTP" -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
```

## Services quick reference
| Service | Check | Restart | Notes |
|---|---|---|---|
| AD DS | `Get-Service NTDS,Netlogon,Kdc` | `Start-Service NTDS` (restarting it also restarts DNS/Kerberos — last resort) | `dcdiag /q` shows problems |
| DNS | `Get-Service DNS`; `Resolve-DnsName <name> -Server 127.0.0.1` | `Restart-Service DNS` | zones: `Get-DnsServerZone`; records: `Get-DnsServerResourceRecord -ZoneName <zone>` |
| IIS (HTTP) | `Get-Service W3SVC`; `Get-Website` | `iisreset` | site files usually `C:\inetpub\wwwroot`; `Start-Website <name>` if stopped |
| IIS FTP | `Get-Service FTPSVC` | `Restart-Service FTPSVC` | settings in `inetmgr` |
| Time | `w32tm /query /status` | `w32tm /resync` | Kerberos breaks if clock is >5 min off |

Test LDAP login as a scored user from another box, or on lapis: `Get-ADUser creeper` should work; `nltest /dsgetdc:<domain>`.
