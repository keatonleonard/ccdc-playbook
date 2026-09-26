# Asking a no-login AI for help

Allowed: fixing/hardening, explaining commands, understanding malware, learning how to do an inject task.
**Not allowed:** anything that writes or edits inject text. Don't paste inject wording and ask for a response.
Never paste my real new passwords (replace with `PASSWORD`). Don't paste my team number.

Free no-login models are smaller — give them real output and a narrow question. Always sanity-check a command before running it, especially anything with `rm`, `-delete`, `iptables`, `ufw`, firewall, or `Remove-`.

## Context line (paste at the top of every question)
> I'm a student in a cyber defense competition (blue team) defending my own lab machines. Boxes: Ubuntu 18.04 server, Windows Server 2016 domain controller, VyOS router with 1:1 NAT, Rocky 9 with Splunk. Scored services: HTTP, SSH, FTP, AD/DNS, POP3 — they must stay up and the website content must not change. I can't block IPs.

## Templates
**Service down**
> [context] The `<service>` service on `<box>` is failing. Here is `systemctl status <service>` and the last lines of `journalctl -xeu <service>`: ```<paste>``` What's the most likely cause, and what's the minimal fix that keeps the service's content and behavior the same? Give exact commands.

**Is this malicious?**
> [context] I found this on `<box>`: ```<cron line / process / script / service file>``` What does it do, is it likely a backdoor, how do I safely remove it, and what else might it have installed that I should check?

**Config check**
> [context] Here's my `<file>`: ```<paste, passwords removed>``` Is anything insecure or suspicious? I need to keep password logins working for the scoring users.

**How do I do X**
> [context] How do I `<task>` on `<OS>`? Give step-by-step commands and how to verify it worked, plus how to undo it.

**Splunk search**
> [context] Write a Splunk SPL search that finds `<thing>` in the last hour. My indexes/sourcetypes are: ```<paste output of: index=* | stats count by index, sourcetype>```

**Understanding a topic (for inject research — I write the memo myself)**
> Explain `<concept>` in simple terms and point me to official documentation I can cite.
