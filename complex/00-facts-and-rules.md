# Facts and rules (from the team packet)

## Machines
`x` = my team number. WAN ("public") IP = `192.168.(200+x).N`. Team 12 → `192.168.212.N`.
Router does **1:1 NAT**: each box has a public IP and a private IP. **Scoring hits the public IP.**

| Host | Public | Private | OS | Login |
|---|---|---|---|---|
| bedrock | .2 | 172.16.1.1 | VyOS 2025.11 (router/firewall) | `vyos` |
| iron | .10 | 172.16.1.10 | Ubuntu Server 18.04 | `steve` |
| lapis | .11 | 172.16.1.11 | Windows Server 2016 | `steve` |
| redstone | .12 | 172.16.1.12 | Rocky 9.6 + Splunk 10.0.2 | `steve` (OS), `admin` (Splunk web) |

Default password for everything is in the packet (same for all). **Red team knows it too.**

Other networks: Internet gateway + shared DNS `192.168.192.1` (subnet `192.168.192.0/18`), LAN `172.16.1.0/24`.

## Users — keep exactly these, don't delete any of them
- **Admins:** steve, alex
- **Users:** enderman, creeper, villager, zombie, enderdragon, irongolem, chickenjockey, ghast

The scoring engine logs in as these users (e.g. FTP/POP3/LDAP). **If I change their passwords I must submit a Password Change Request (PCR) in Quotient**, or those services score as down.
Anyone *not* on this list (besides built-in system accounts) is suspicious. Only steve and alex should be admins.

## Scored services (on Windows or Linux — find out which on day 1)
HTTP, SSH, FTP, AD/DNS, POP3. Redstone (Splunk) has no scored services.

How checks work:
- **HTTP:** fetches a page, compares MD5 and/or keywords → **don't change web page content.**
- **AD:** LDAP login with a valid user/password.
- **FTP/POP3/SSH:** probably log in as a listed user.
- Services must be *functional*, not just listening. Watch dependencies (e.g. a website that needs a database).

## Scoring
- 50% services, 50% injects.
- Points lost when red team gets in; win them back with **Incident Response reports** (the IR inject is released at the start, due at the end; multiple reports allowed).
- **Reverts** (ask in Discord `ticket` channel): 100 pts first, 200 second, 400 each after — per device.

## Rules that could get me DQ'd or zeroed
1. Injects: PDF, named `team##_inject##.pdf`, team number not my name, typed, memo format.
2. **No AI writing or editing any part of an inject.** AI is fine for hardening, fixing, and *researching* how to do inject tasks.
3. No paid AI, and nothing that needs a login (no signed-in ChatGPT/Claude).
4. Only public resources — notes/scripts must be in a public repo (this one).
5. Keep services on their assigned public IPs. Don't re-address anything unless an inject says so.
6. **No blocking IPs. No "knife edge" rules that only allow the scoring engine.**
7. Don't touch other teams' infrastructure.
8. No outside help from people.
9. Don't try to alter how a service is scored (e.g. replacing the site with a static string).
10. Don't disable log forwarding to the Black Team Splunk indexer.

## Access notes (from info sessions)
- Authentik (`auth.byuccdc.org`) links to Proxmox (VM consoles), Quotient (scoring + injects + PCR), NetBird VPN.
- NetBird VPN lets me SSH to boxes from my laptop → **copy/paste works over SSH**, it doesn't in the Proxmox console.
- Announcements: Discord + Quotient. Support/revert requests: Discord.
- Schedule: setup 9:00, start 10:00, end 16:00. Pizza ~12:00, competition doesn't pause.
