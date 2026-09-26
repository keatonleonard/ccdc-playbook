# Read-only Windows triage snapshot. Changes nothing.
# Usage (PowerShell as Administrator):
#   powershell -ExecutionPolicy Bypass -File .\triage.ps1 > C:\bk\triage-1005.txt
# Compare:
#   Compare-Object (Get-Content C:\bk\triage-1005.txt) (Get-Content C:\bk\triage-1130.txt)
#   "=>" = new since the first snapshot, "<=" = gone

function S($t) { ""; "===== $t =====" }

S "HOST"
$env:COMPUTERNAME

S "USERS"
try {
  Get-ADUser -Filter * -Properties Enabled, whenCreated | Sort-Object SamAccountName |
    ForEach-Object { "{0} enabled={1} created={2}" -f $_.SamAccountName, $_.Enabled, $_.whenCreated }
} catch {
  Get-LocalUser | Sort-Object Name | ForEach-Object { "{0} enabled={1}" -f $_.Name, $_.Enabled }
}

S "PRIVILEGED GROUPS"
foreach ($g in "Domain Admins", "Enterprise Admins", "Schema Admins", "Administrators", "DnsAdmins",
               "Group Policy Creator Owners", "Backup Operators", "Account Operators", "Server Operators", "Remote Desktop Users") {
  try { "{0}: {1}" -f $g, ((Get-ADGroupMember $g -ErrorAction Stop | ForEach-Object SamAccountName | Sort-Object) -join ", ") }
  catch { try { "{0}: {1}" -f $g, ((Get-LocalGroupMember $g -ErrorAction Stop | ForEach-Object Name | Sort-Object) -join ", ") } catch {} }
}

S "LISTENING TCP"
Get-NetTCPConnection -State Listen | ForEach-Object {
  "{0}:{1} {2}" -f $_.LocalAddress, $_.LocalPort, (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
} | Sort-Object -Unique

S "LISTENING UDP"
Get-NetUDPEndpoint | ForEach-Object {
  "{0}:{1} {2}" -f $_.LocalAddress, $_.LocalPort, (Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue).Name
} | Sort-Object -Unique

S "RUNNING SERVICES"
Get-Service | Where-Object Status -eq Running | ForEach-Object Name | Sort-Object

S "SERVICES OUTSIDE NORMAL PATHS"
Get-CimInstance Win32_Service | Where-Object { $_.PathName -notmatch 'system32|Program Files|SysWOW64' } |
  ForEach-Object { "{0} [{1}] {2}" -f $_.Name, $_.StartMode, $_.PathName } | Sort-Object

S "SCHEDULED TASKS (non-Microsoft)"
Get-ScheduledTask | Where-Object TaskPath -notlike '\Microsoft\*' | ForEach-Object {
  "{0}{1} [{2}] -> {3}" -f $_.TaskPath, $_.TaskName, $_.State, (($_.Actions | ForEach-Object { "$($_.Execute) $($_.Arguments)" }) -join '; ')
} | Sort-Object

S "RUN KEYS"
foreach ($k in 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run', 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce',
               'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Run', 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run',
               'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce') {
  if (Test-Path $k) {
    $p = Get-ItemProperty $k
    $p.PSObject.Properties | Where-Object Name -notlike 'PS*' | ForEach-Object { "$k | $($_.Name) = $($_.Value)" }
  }
}

S "STARTUP FOLDERS"
Get-ChildItem "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp", "C:\Users\*\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup" -ErrorAction SilentlyContinue |
  ForEach-Object FullName | Sort-Object

S "IFEO DEBUGGERS (sticky keys backdoor)"
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options' -ErrorAction SilentlyContinue |
  ForEach-Object { Get-ItemProperty $_.PSPath } | Where-Object Debugger | ForEach-Object { "{0} -> {1}" -f $_.PSChildName, $_.Debugger }

S "ACCESSIBILITY BINARY SIZES (compare with cmd.exe)"
Get-Item C:\Windows\System32\sethc.exe, C:\Windows\System32\utilman.exe, C:\Windows\System32\osk.exe,
         C:\Windows\System32\Magnify.exe, C:\Windows\System32\Narrator.exe, C:\Windows\System32\cmd.exe -ErrorAction SilentlyContinue |
  ForEach-Object { "{0} {1}" -f $_.Name, $_.Length }

S "DEFENDER"
try {
  $m = Get-MpPreference -ErrorAction Stop
  "RealtimeDisabled=$($m.DisableRealtimeMonitoring)"
  "ExclusionPath=$($m.ExclusionPath -join ',')"
  "ExclusionProcess=$($m.ExclusionProcess -join ',')"
  "ExclusionExtension=$($m.ExclusionExtension -join ',')"
} catch { "Defender not available" }

S "FIREWALL PROFILES"
Get-NetFirewallProfile | ForEach-Object { "{0} enabled={1} inbound={2}" -f $_.Name, $_.Enabled, $_.DefaultInboundAction }

S "ENABLED FIREWALL BLOCK RULES"
Get-NetFirewallRule -Enabled True -Action Block -ErrorAction SilentlyContinue | ForEach-Object DisplayName | Sort-Object

S "SHARES"
Get-SmbShare | ForEach-Object { "{0} {1}" -f $_.Name, $_.Path }

S "WMI EVENT CONSUMERS"
Get-CimInstance -Namespace root\subscription -ClassName __EventConsumer -ErrorAction SilentlyContinue | ForEach-Object Name

S "WEB FILES (newest 20)"
Get-ChildItem C:\inetpub -Recurse -File -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 20 |
  ForEach-Object { "{0} {1}" -f $_.LastWriteTime.ToString('s'), $_.FullName }

S "SESSIONS"
if (Get-Command query.exe -ErrorAction SilentlyContinue) { query.exe user 2>$null } else { "query.exe not available on this Windows edition" }
