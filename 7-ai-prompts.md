# Asking AI for help

More templates: [complex/09-ai-prompts.md](complex/09-ai-prompts.md)

## Rules
- ✅ **OK:** fixing services, explaining commands, "is this malicious?", learning a topic for an inject
- ❌ **Never:** writing or editing any part of an inject — not even one sentence
- ❌ **Never paste:** my passwords or my team number
- ✅ **Always:** read the command it gives me and make sure I understand it before running it

## Step 1 — paste this first, every time
> I'm a student in a cyber defense competition, defending my own lab machines. I have an Ubuntu 18.04 server, a Windows Server 2016 domain controller, a VyOS router, and a Rocky Linux server with Splunk. The services HTTP, SSH, FTP, AD/DNS and POP3 must stay up, and the website content must not change.

## Step 1 (long version) — full topology, for network or multi-machine problems
Use this instead of the short version when the question involves the router, firewalls, NAT, DNS/AD, Splunk, or more than one machine.
**Don't fill in the public IP prefix** — it contains my team number.

> I'm a student in a cyber defense competition (blue team), defending my own lab network. Here is my environment:
>
> **Network**
> - Router/firewall: **bedrock**, VyOS 2025.11. WAN `192.168.<wan>.2` (subnet `192.168.<wan>.0/24`), LAN `172.16.1.1` (subnet `172.16.1.0/24`).
> - The router does **1:1 NAT**: each server has a private LAN IP and a matching public WAN IP (`192.168.<wan>.N` ↔ `172.16.1.N`).
> - Upstream internet gateway and shared DNS: `192.168.192.1` (subnet `192.168.192.0/18`).
> - I reach the machines from my laptop through a NetBird VPN; the machines run as VMs on Proxmox.
>
> **Machines**
> - **iron** — Ubuntu Server 18.04, `172.16.1.10` / public `.10`
> - **lapis** — Windows Server 2016, Active Directory domain controller + DNS, `172.16.1.11` / public `.11`
> - **redstone** — Rocky Linux 9.6 running Splunk Enterprise 10.0.2 (web on port 8000), `172.16.1.12` / public `.12`. Not scored.
> - iron and lapis have Splunk Universal Forwarders sending logs to redstone **and** to an external organizer-owned indexer. Forwarding to the external indexer must not be disabled.
>
> **Users** (must all keep working; I may not delete them): admins `steve`, `alex`; users `enderman`, `creeper`, `villager`, `zombie`, `enderdragon`, `irongolem`, `chickenjockey`, `ghast`.
>
> **Scored services:** HTTP, SSH, FTP, AD/DNS (LDAP login), POP3. A scoring engine checks them **from the public/WAN side** by logging in as the users above and comparing web page content (MD5/keywords). Web content must not change.
>
> **Rules I must follow:** services stay on their assigned public IPs; I can't change any IP addressing; I can't block IP addresses or add rules that only allow the scoring engine; I can't fake a service to fool the checker. Red team is actively attacking and trying to take services down.
>
> Keep answers practical: exact commands, what each one does, how to check it worked, and how to undo it. Warn me if something could break a scored service.




## Step 2 — then one of these

**Something is broken**
> The `____` service on my `____` server stopped working. Here is the error: `[paste the exact output]`. What is wrong, and what is the simplest fix? Give me exact commands and tell me what each one does.

**Is this malicious?**
> I found this on my `____` server: `[paste the file, process, cron job or task]`. What does it do? Is it a backdoor? How do I safely remove it?

**How do I...?**
> How do I `____` on `____`? Give me step-by-step commands, how to check it worked, and how to undo it.

**What does this command do?**
> Explain what this command does, piece by piece, and whether it could break anything: `[paste command]`

**Learning a topic (for an inject — I write the memo myself)**
> Explain `____` in simple terms, and give me official sources I can read and cite.

## Tips
- Paste the **exact** error — not a description of it.
- Free AIs make mistakes. If a command could delete or block something, double-check before running it.
- If the answer doesn't work, paste the new error and ask again.
