# bedrock — VyOS 2025.11 router

WAN `192.168.(200+x).2`, LAN `172.16.1.1`. Does 1:1 NAT: public `.10/.11/.12` ↔ private `172.16.1.10/.11/.12`.
**If every service goes red at once, look here first** (or at a firewall rule I just added).

## Two modes
- **Operational mode** (prompt `$`): `show ...` commands.
- **Configuration mode** (prompt `#`): type `configure`. Change things with `set` / `delete`, then `commit` (apply) and `save` (survive reboot). `exit` to leave.
- In config mode, run an op command with `run show ...`.

## Look around (op mode)
```
show interfaces
show ip route
show nat destination rules
show nat source rules
show firewall
show configuration commands | grep nat
show configuration commands | grep firewall
show configuration commands | grep 'login user'        # only vyos; look for public-keys too
show configuration commands | grep service              # ssh, https api, etc.
show configuration commands | grep task-scheduler       # red team could schedule scripts here
```
Also check `cat /config/scripts/vyos-postconfig-bootup.script` for added commands.

## Safe-change workflow
```
configure
save /config/bk-before-change.config       # snapshot
set ... / delete ...
compare                                    # show what I'm about to change
commit-confirm 5                           # auto-undo in 5 min unless I type: confirm   (older VyOS undoes by rebooting)
confirm
save
exit
```
Restore a snapshot: `configure` → `load /config/bk-start.config` → `commit` → `save`.

## Common fixes
```
# change password
set system login user vyos authentication plaintext-password 'NEW'

# remove an extra login user or an SSH key red team added
delete system login user <name>
delete system login user vyos authentication public-keys <keyname>

# a firewall rule red team added that drops traffic
show firewall                                        # find the ruleset + rule number
delete firewall ipv4 forward filter rule <N>          # (or input filter, depending on where it is)

# a NAT rule missing/changed — compare against the backup:
cat /config/bk-start.config | grep -A 20 nat          # (from op mode)
```
The NAT config in the backup is the source of truth for how it *should* look. If NAT is broken and I can't fix it fast, loading the backup (above) is cheaper than a revert.

## Don't
- Don't re-address interfaces or change the NAT mapping (rules say so).
- Don't add rules that only allow the scoring engine or block specific IPs.
