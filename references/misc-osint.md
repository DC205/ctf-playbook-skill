# Misc / OSINT / Password Cracking

Covers miscellaneous puzzles, encoding chains, open-source intelligence, and hash/archive cracking.

## Triggers

Trivia or puzzle challenges; weird or chained encodings; OSINT task (find a person, place, or account); a bare hash or password-protected archive; challenge says "google it" or gives minimal context.

## Workflow

1. Identify the puzzle type: encoding chain, OSINT lead, hash, or archive.
2. Decode, search, or crack using the matching technique.
3. Follow the OSINT pivot chain or crack until plaintext is obtained.
4. Extract the flag from the result.

## Commands

Run these via the kali skill (it owns host/auth):

**Encoding chains**
```bash
# CyberChef "Magic" — paste input, enable Magic mode for auto-detection
# Manual chain: base64 → hex → URL → ROT → repeat
echo '<data>' | base64 -d
echo '<data>' | xxd -r -p
python3 -c "import urllib.parse; print(urllib.parse.unquote('<data>'))"
# Morse, Brainfuck, Whitespace — use dcode.fr or CyberChef recipes
file <blob>   # identify unknown binary blobs
```

**OSINT**
```bash
# Reverse image search: Google Images, TinEye, Yandex
# Extract GPS from photo
exiftool <file> | grep -i gps
# Pivot on username/email
# Wayback Machine: web.archive.org
# Certificate transparency: crt.sh
whois <domain>
dig <domain> ANY
# DNS enumeration
dig axfr @<target> <domain>
```

**Archive and protected file cracking**
```bash
# Convert to John-compatible hash, then crack
zip2john <file> > hash.txt
ssh2john <file> > hash.txt
7z2john <file> > hash.txt
pdf2john <file> > hash.txt
# Crack with John
gunzip /usr/share/wordlists/rockyou.txt.gz   # if still compressed
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
john --show hash.txt
# Crack with hashcat
hashcat -m <mode> hash.txt /usr/share/wordlists/rockyou.txt
```

**GTFOBins / binary abuse**
```bash
# Look up any privileged or unusual binary at gtfobins.github.io
# Common read-file primitives: awk, python, perl, ruby, vim, less, more
```

## Pitfalls

- Rabbit holes are common — verify the challenge title and any given hint before going deep.
- Low-point misc challenges are often simpler than they look; try obvious encodings first.
- rockyou.txt ships gzipped on some distros — `gunzip` before use.
- Assuming encryption when it is just encoding wastes time — always try simple decoding first.

## Flag extraction

```bash
# Decoded or cracked output
echo '<cracked_output>' | grep -oE '[A-Za-z0-9_]+\{[^}]+\}'
# After extracting a cracked archive
find out/ -type f | xargs grep -lE 'flag\{|CTF\{'
cat out/flag.txt
```

Decoded or cracked plaintext is the flag; validate against the event's flag regex format.
