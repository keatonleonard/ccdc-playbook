# Splunk — simple guide

Splunk collects logs from iron and lapis in one place, so I can search every machine at once, even if red team deletes the logs on the machine itself.

## Get in
1. Browser → `http://192.168.___.12:8000` (backup: `http://172.16.1.12:8000`)
2. Log in as `admin`
3. Click **Search & Reporting** (left side)

## The screen
- **Search bar** (top): type the search, press Enter.
- **Time picker** (right of the search bar): set it to **Last 60 minutes** or **Today**. Wrong time range = no results.
- **Events** (below): newest first. Click the `>` arrow on an event to see all its fields.
- **Fields list** (left side): click a field name → see its most common values. Great for spotting one IP doing a lot.

## Search basics
| Type this | Means |
|---|---|
| `index=*` | Search all the data |
| `"Failed password"` | Events containing that exact text |
| `host=iron` | Only events from that machine (use the host names Search 1 shows) |
| `A B` | Both A and B |
| `A OR B` | Either one |
| `NOT A` | Leave A out |
| `\| stats count by host` | Count events per machine instead of listing them |
| `\| table _time host _raw` | Show just those columns |
| `\| sort -count` | Biggest first |

## Search 1 — What data do I have? (run first)
```
index=* | stats count by index, host, sourcetype
```
Shows which machines are sending logs. If a machine is missing, its forwarder might be down.

## Searches 2–7 — Copy, paste, read
**Who is failing to log in to Linux? (password guessing)**
```
index=* "Failed password" | stats count by host
```

**Who successfully logged in to Linux?**
```
index=* "Accepted password" OR "Accepted publickey" | table _time host _raw
```
Any login I didn't do = red team.

**Who is failing to log in to Windows?**
```
index=* EventCode=4625 | stats count by host
```

**Was a new Windows user created, or someone made an admin?**
```
index=* EventCode=4720 OR EventCode=4732 OR EventCode=4728 | table _time host EventCode _raw
```
4720 = new user · 4732/4728 = added to a group

**Was a new Windows service or scheduled task created?**
```
index=* EventCode=7045 OR EventCode=4698 | table _time host EventCode _raw
```
Usually how red team makes their program come back.

**Did someone erase the Windows logs?**
```
index=* EventCode=1102
```
Any result = someone is covering their tracks.

## Found something? Follow the thread
1. Note the **IP address** or **username** in the event.
2. Search just that: `index=* "10.1.2.3"` or `index=* "creeper"`.
3. Read the results oldest to newest — that's the story of the attack.
4. **Screenshot the search and results** for my incident report.

## If Splunk isn't working
- No results → check the time picker first.
- Can't reach the page → SSH into redstone: `sudo /opt/splunk/bin/splunk status` → `sudo /opt/splunk/bin/splunk start`
- Splunk isn't scored → don't spend more than ~10 minutes fixing it.

**Don't** turn off the forwarders on iron or lapis — that breaks a rule.
