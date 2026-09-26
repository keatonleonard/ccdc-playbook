# redstone — Rocky 9.6 + Splunk Enterprise 10.0.2

Private `172.16.1.12`. **No scored services** — it's there to help me. Still in scope for red team.
iron and lapis already forward logs here. Don't touch the forwarders' outputs (Black Team indexer must keep receiving).

## Box basics (Rocky = RHEL family)
- Package manager `dnf`, firewall `firewalld` (`sudo firewall-cmd --list-all`), admin group `wheel`, auth log `/var/log/secure`.
- Splunk: `sudo /opt/splunk/bin/splunk status` / `restart`.
- Change Splunk admin password from CLI if the web UI is a problem:
  `sudo /opt/splunk/bin/splunk edit user admin -password 'NEW' -auth admin:'OLD'`
  (this saves both passwords in the shell history — prefer the web UI, or run `history -c` afterward)
- Same user/persistence hunt as iron applies ([02](02-iron-ubuntu.md)), except `getent group wheel` and `sudo rpm -Va` instead of `dpkg -V`.

## Splunk web: `http://172.16.1.12:8000` → Search & Reporting
Set the time picker (right of the search bar) to **Last 60 minutes** or **Today**. Then:

### What data do I have? (run first)
```
index=* | stats count by index, host, sourcetype
```
Use the index names this shows instead of `index=*` to make searches faster.

### Linux
```
index=* "Failed password" | rex "from (?<src>\d+\.\d+\.\d+\.\d+)" | stats count by host, src
index=* ("Accepted password" OR "Accepted publickey") | table _time host _raw
index=* sudo COMMAND | table _time host _raw
index=* (useradd OR usermod OR "new user" OR passwd) | table _time host _raw
index=* CRON CMD | stats count by host, _raw | sort -count
```

### Windows (EventCode)
```
index=* EventCode=4625 | stats count by host, Account_Name, Source_Network_Address          # failed logons
index=* EventCode=4624 (Logon_Type=3 OR Logon_Type=10) | table _time host Account_Name Source_Network_Address Logon_Type
index=* EventCode IN (4720, 4722, 4724, 4738) | table _time host EventCode _raw              # account created/enabled/pw reset/changed
index=* EventCode IN (4728, 4732, 4756) | table _time host EventCode _raw                    # added to a security group
index=* EventCode IN (4698, 7045) | table _time host EventCode _raw                          # scheduled task created / service installed
index=* EventCode IN (1102, 104) | table _time host _raw                                     # logs cleared (red flag!)
index=* EventCode=4688 | table _time host New_Process_Name Process_Command_Line              # process creation (if auditing on)
index=* EventCode=4104 | table _time host _raw                                               # PowerShell script block
```

### Web
```
index=* sourcetype=*access* | stats count by clientip | sort -count
index=* sourcetype=*access* ("cmd=" OR "../" OR ".php?" OR "select " OR "union ") | table _time host clientip uri _raw
```

### Pivot
Found an IP or username? Search just that value everywhere: `index=* "10.0.5.20"` → sort by time → that's the story for an incident report.
Field names differ by setup — if a field search returns nothing, search the plain text instead and look at `_raw`.

**Screenshot the search + results** — that's evidence for incident reports.
