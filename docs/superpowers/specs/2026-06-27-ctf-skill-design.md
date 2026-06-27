# CTF Skill — Design Spec

**Date:** 2026-06-27
**Status:** Approved design, pending spec review

## Overview

An "ultimate" CTF skill that gives Claude a triage-and-execute brain for Capture the
Flag events. It recognizes a challenge's category, selects the matching playbook, and
drives the challenge **autonomous-first** by delegating tool execution to the existing
**kali skill**. It covers both the **Jeopardy** category taxonomy and a
**boot2root/network** track.

The skill is the *brain*; the kali skill is the *execution layer*. This skill does not
duplicate kali's tool inventory or connection details (host, auth, command patterns) —
the kali skill owns and maintains those, separately. This skill invokes the kali skill
abstractly and refers to tools by name only.

## Goals

- Classify an arbitrary challenge (file, URL, prompt text, or target host) into a CTF
  category quickly and correctly.
- Run the right workflow on the Kali box with minimal hand-holding, surfacing the flag
  or a concrete blocker.
- Keep per-invocation context lean via progressive disclosure (main file routes; depth
  lives in `references/`).
- Record everything to `ctf-notes/` for reproducibility.

## Scope

**In scope:** Jeopardy categories (web, crypto, forensics, stego, reversing, pwn,
misc/OSINT) and a network/boot2root track (recon → enum → exploit → shell → privesc →
lateral).

**Out of scope (YAGNI):** GUI-only tools (Burp, BloodHound), custom exploit-dev
frameworks, multi-operator/team coordination, automatic scoreboard submission.

## Architecture — Approach A (single skill, progressive disclosure)

```
ctf-skill/
├── SKILL.md                  # frontmatter + triage router + autonomous loop
├── references/
│   ├── web.md
│   ├── crypto.md
│   ├── forensics.md
│   ├── stego.md
│   ├── reversing.md
│   ├── pwn.md
│   ├── misc-osint.md
│   └── network.md
└── assets/
    └── notes-template.md     # per-challenge ctf-notes scaffold
```

**Frontmatter:** `name: ctf`; `description:` triggers on "CTF", "capture the flag",
"this challenge", a challenge file/URL, or a target box, so the skill is invocable.

## Main workflow (SKILL.md body) — 3-phase autonomous loop

1. **Triage** — classify via fast signals: `file`/`strings`/`binwalk` on artifacts,
   challenge title hints, prompt wording, and a port scan for network targets. Output:
   chosen category + confidence.
2. **Dispatch** — read the matching `references/<category>.md`, seed a
   `ctf-notes/<challenge>/` workspace from `assets/notes-template.md`, then run that
   category's workflow on Kali via the kali skill. Autonomous-first: run recon/exploit
   steps directly; checkpoint only before destructive/irreversible actions.
3. **Capture & verify** — extract the flag, validate against the configured regex
   (default `flag{...}`, `CTF{...}`, `picoCTF{...}`), log evidence to notes, report.
   If stuck: run the per-category fallback checklist, then re-triage to another
   category before asking the user.

## Reference file contents

Every `references/*.md` follows one shape: **trigger signals → ordered workflow →
exact Kali commands → common pitfalls → flag-extraction tips.**

- **web** — recon (gobuster/nikto/robots), SQLi (sqlmap), XSS, SSRF, command/template
  injection, NoSQLi, file-upload, WordPress (wpscan).
- **crypto** — cipher ID, Caesar/ROT/Vigenère, XOR/OTP key-reuse, RSA attacks, hash
  cracking (john/hashcat), CyberChef recipes.
- **forensics** — `file`/`binwalk`/`foremost`/`photorec`, metadata (exiftool), PCAP
  (wireshark/tshark, USB-keystroke recovery), memory (volatility), NTFS ADS.
- **stego** — zsteg/steghide/stegseek, LSB, EXIF, audio spectrogram, whitespace.
- **reversing** — `file`/`strings`, GDB/pwndbg, Ghidra/objdump, anti-debug checks.
- **pwn** — checksec, pattern offset, BOF→ROP, format string, GOT overwrite, pwntools
  template; mitigations (NX/ASLR/canary/RELRO).
- **misc-osint** — title hints, "google everything," GTFOBins, encoding chains,
  password-cracking conversions (zip2john/ssh2john/7z2john).
- **network** — nmap recon → service enum → exploit → shell stabilization → privesc
  (LinPEAS/GTFOBins/pspy) → lateral movement.

## Kali integration

- Tool execution is delegated to the kali skill. This skill invokes that skill and
  names the tool + arguments to run; it does NOT hardcode the host, auth, or
  ssh/background command patterns — those belong to the kali skill, which is maintained
  separately.
- Long-running scans run in the background per whatever pattern the kali skill provides.
- The skill refers to tools by name and lets the kali skill own the tool inventory.

## Notes & flag tracking

- Each challenge gets a `ctf-notes/<name>/` workspace, seeded from
  `assets/notes-template.md`: commands, output, evidence, and the flag.
- Flag validation against a configurable regex; sensible CTF defaults out of the box.

## Safety & error handling

- Scope/authorization confirmation before scanning or attacking any target.
- Checkpoint before destructive/irreversible actions.
- Per-category fallback checklist when the primary workflow dead-ends.
- Cross-category re-triage before escalating to the user.

## Testing / verification

This is a content skill, so verification is:

1. **Reference lint** — every `references/*.md` follows the shared section shape.
2. **Triage rubric** — a fixed set of sample challenge descriptions mapped to expected
   categories; running triage against them confirms the router classifies correctly.

## Open questions

None blocking. Git is not yet initialized in this repo; initializing + committing is
offered separately, not assumed.
