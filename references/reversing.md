# Reverse Engineering

Covers static and dynamic analysis of executables to recover logic, passwords, or embedded flags.

## Triggers

An executable to understand (ELF, PE, Mach-O); challenge says "find the password" or "what is the key"; a license or serial-number check; no network service — analysis is purely on the binary.

## Workflow

1. Static triage: identify file type, architecture, and obvious strings.
2. Check for packers or obfuscation; unpack if needed.
3. Static analysis in Ghidra or objdump to understand the logic.
4. Dynamic analysis with gdb/ltrace/strace to observe runtime behavior.
5. Recover the flag constant or derive it from the algorithm.

## Commands

Run these via the kali skill (it owns host/auth):

**Triage**
```bash
file <bin>
strings -n 6 <bin> | grep -iE 'flag|CTF|pass|key|correct'
# Check for UPX packing
strings <bin> | grep UPX
upx -d <bin>       # unpack if packed
```

**Static analysis**
```bash
# Disassemble
objdump -d -M intel <bin> | less
# Symbol and section info
nm <bin>
readelf -a <bin>
# Load in Ghidra: File > Import, then analyse and decompile main / interesting functions
```

**Dynamic analysis**
```bash
# ltrace — watch library calls (strcmp, memcmp reveal passwords)
ltrace ./<bin>
ltrace ./<bin> 2>&1 | grep -iE 'strcmp|memcmp|strncmp'
# strace — watch syscalls
strace ./<bin>
# gdb with pwndbg or gef
gdb ./<bin>
# Inside gdb:
#   break main
#   run
#   disassemble current_func
#   ni / si to step
#   x/s $rdi  — inspect string argument
#   set $rax=1 — patch a return value to bypass a check
```

**Anti-debug bypass**
```bash
# Common anti-debug: ptrace self-check, IsDebuggerPresent (Windows), timing, int 3 traps
# In gdb: catch syscall ptrace
# Patch the binary: find the conditional jump after the ptrace check and NOP it
python3 -c "
import struct
with open('<bin>','r+b') as f:
    f.seek(<offset>)
    f.write(b'\x90\x90')  # NOP the jump
"
```

## Pitfalls

- Stripped binaries have no symbol names — navigate by cross-referencing strings and library calls.
- The password or key may be compared after a transformation (hash, XOR, rotate) — read the whole check routine.
- Statically-linked binaries produce a lot of noise in `strings` — focus on non-library sections.
- Wrong architecture flag in gdb causes confusing errors — confirm with `file <bin>` and set `set architecture` accordingly.

## Flag extraction

```bash
# Run the binary with the recovered input
./<bin> <recovered_password>
# Or the flag constant is directly visible in Ghidra's decompilation as a string literal
strings <bin> | grep -oE '[A-Za-z0-9_]+\{[^}]+\}'
```

The recovered constant or derived string is the flag; or supply the correct input and read the program's output.
