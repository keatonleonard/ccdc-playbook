#!/bin/bash
# Read-only Linux triage snapshot. Changes nothing.
# Usage:   sudo bash triage.sh > /root/triage-$(date +%H%M).txt
# Compare: diff /root/triage-1005.txt /root/triage-1130.txt
#   lines starting with ">" are new since the first snapshot

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo"; exit 1; }
s() { echo; echo "===== $1 ====="; }

s "HOST"
hostname; grep PRETTY_NAME /etc/os-release

s "USERS (name:uid:gid:home:shell)"
cut -d: -f1,3,4,6,7 /etc/passwd | sort

s "UID 0 ACCOUNTS"
awk -F: '$3==0 {print $1}' /etc/passwd

s "ADMIN GROUPS"
getent group sudo wheel adm

s "SUDOERS"
grep -hv '^\s*#' /etc/sudoers /etc/sudoers.d/* 2>/dev/null | grep -v '^\s*$'

s "AUTHORIZED KEYS"
find / -xdev -name 'authorized_keys*' 2>/dev/null | while read -r f; do echo "# $f"; cat "$f"; done

s "LISTENING PORTS"
ss -tulpn | awk 'NR>1 {print $1, $5, $7}' | sed -E 's/pid=[0-9]+,//g; s/fd=[0-9]+//g' | sort -u

s "RUNNING SERVICES"
systemctl list-units --type=service --state=running --no-legend --plain | awk '{print $1}' | sort

s "ENABLED UNIT FILES"
systemctl list-unit-files --state=enabled --no-legend | awk '{print $1}' | sort

s "UNIT FILES IN /etc/systemd/system"
find /etc/systemd/system -type f \( -name '*.service' -o -name '*.timer' \) | sort

s "TIMERS"
systemctl list-timers --all --no-legend | awk '{print $(NF-1), $NF}' | sort

s "USER CRONTABS"
for u in $(cut -d: -f1 /etc/passwd); do
  crontab -l -u "$u" 2>/dev/null | grep -v '^\s*#' | grep -v '^\s*$' | sed "s|^|[$u] |"
done

s "SYSTEM CRON"
grep -v '^\s*#' /etc/crontab 2>/dev/null | grep -v '^\s*$'
ls -1 /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /etc/cron.monthly 2>/dev/null

s "LD PRELOAD / RC.LOCAL / PROFILE.D"
cat /etc/ld.so.preload 2>/dev/null
cat /etc/rc.local 2>/dev/null
ls -1 /etc/profile.d 2>/dev/null

s "SUID FILES"
find / -xdev -perm -4000 -type f 2>/dev/null | sort

s "PROCESSES (user + command, no PIDs)"
ps -eo user:20,args --no-headers | grep -v -E '^\S+\s+\[' | grep -v triage | sort -u

s "FILES IN /tmp /var/tmp /dev/shm"
find /tmp /var/tmp /dev/shm -type f 2>/dev/null | sort

s "WEB FILES (newest 20)"
find /var/www -type f -printf '%TY-%Tm-%Td %TH:%TM %p\n' 2>/dev/null | sort -r | head -20

s "SESSIONS"
who
