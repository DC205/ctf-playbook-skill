# Cryptography

Covers cipher identification, classical and modern attacks, hash cracking, and RSA exploitation.

## Triggers

Ciphertext blobs; base64 or hex-encoded data; challenge description contains "encrypted"; RSA parameters (n, e, c) provided; repeated-key or pad-reuse hints; a found hash to crack.

## Workflow

1. Identify the encoding or cipher scheme (CyberChef Magic, `hashid`, visual inspection).
2. Apply the matching attack for that scheme.
3. Decode or reconstruct the plaintext.
4. Extract the flag from the result.

## Commands

Run these via the kali skill (it owns host/auth):

**Identify / decode**
```bash
# Base64
echo '<ciphertext>' | base64 -d
# Hex
echo '<ciphertext>' | xxd -r -p
# CyberChef "Magic" — paste ciphertext, enable Magic mode
# hashid on an unknown hash
hashid '<hash>'
```

**Classical ciphers**
```bash
# Caesar / ROT — try all 25 shifts; CyberChef ROT13 Brute Force
# Vigenère — frequency analysis via Guballa online solver
# Substitution cipher — quipqiup.com (online) or dcode.fr
```

**XOR / one-time pad**
```bash
# Single-byte XOR brute (Python)
python3 -c "
ct = bytes.fromhex('<hex>')
for k in range(256):
    pt = bytes(b ^ k for b in ct)
    if b'flag' in pt.lower() or all(32 <= c < 127 for c in pt):
        print(k, pt)
"
# Crib-dragging for reused pad — use xortool or cracxor online
xortool -x <file>
```

**RSA attacks**
```bash
# Small-e cube root (e=3, c < n^(1/3))
python3 -c "
from sympy import integer_nthroot
c = <c>; e = 3
m, exact = integer_nthroot(c, e)
if exact: print(bytes.fromhex(hex(m)[2:]))
"
# Factor weak modulus — try FactorDB then sympy
python3 -c "from sympy import factorint; print(factorint(<n>))"
# Wiener's attack — when d is small (large e), recover d from continued fractions
# (RsaCtfTool --attack wiener, or owiener / the wiener_attack recipe)
# All-in-one wrapper
RsaCtfTool --publickey <file>.pub --uncipher <file>.enc
RsaCtfTool -n <n> -e <e> --uncipher <c> --attack all
```

**Hash cracking**
```bash
# Identify mode
hashid '<hash>'
hashcat --example-hashes | grep -A2 '<type>'
# John
gunzip /usr/share/wordlists/rockyou.txt.gz   # if still compressed
john --format=<fmt> --wordlist=/usr/share/wordlists/rockyou.txt <hashfile>
john --show <hashfile>
# Hashcat
hashcat -m <mode> <hashfile> /usr/share/wordlists/rockyou.txt
# Online: CrackStation.net for common hashes
```

## Pitfalls

- Confusing encoding (reversible, no key) with encryption — always try base64/hex decode first.
- Wrong hashcat `-m` mode silently produces no results — verify with `hashcat --example-hashes`.
- rockyou.txt ships gzipped on some distros; `gunzip` before use.
- Byte-order/endianness in XOR operations can flip the result — try both.
- RSA cube root only works when `c < n` and no padding is applied.

## Flag extraction

The decoded plaintext usually is the flag or directly contains it:

```bash
echo '<ciphertext>' | base64 -d | grep -oE 'flag\{[^}]+\}|CTF\{[^}]+\}'
# Or pipe the decrypted bytes through the flag regex
python3 decrypt.py | grep -oE '[A-Za-z0-9_]+\{[^}]+\}'
```
