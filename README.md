# ctf-playbook-skill

A [Claude Code](https://claude.com/claude-code) **skill** that turns Claude into a CTF
triage-and-execute brain. Hand it a challenge — a file, a URL, a target host, or just
the prompt text — and it classifies the category, loads the matching playbook, and works
the challenge **autonomous-first**, delegating tool execution to your own Kali skill.

It is the *brain*; your Kali skill is the *hands*. This repo deliberately contains **no
host, credentials, or connection details** — those live in the separately-maintained
execution skill.

> Built for and shared with **DC205**. Use it for CTFs and authorized engagements only.

## What it does

The skill runs a three-phase loop:

1. **Triage** — classify the challenge from fast signals (`file`/`strings`/`binwalk`,
   title hints, prompt wording, a port scan) into one category.
2. **Dispatch** — read the matching `references/<category>.md`, seed a
   `ctf-notes/<challenge>/` workspace, and run that category's workflow through the Kali
   skill, logging commands and output as it goes.
3. **Capture** — extract the flag, validate it against the expected format
   (`flag{...}`, `CTF{...}`, `picoCTF{...}`, or an event-specific one), record the
   reproduction steps, and report. If it dead-ends, it re-triages before asking you.

## Categories covered

**Jeopardy track**

| Category | Playbook |
|----------|----------|
| Web exploitation | [`references/web.md`](references/web.md) |
| Cryptography | [`references/crypto.md`](references/crypto.md) |
| Forensics (incl. PCAP/memory) | [`references/forensics.md`](references/forensics.md) |
| Steganography | [`references/stego.md`](references/stego.md) |
| Reverse engineering | [`references/reversing.md`](references/reversing.md) |
| Binary exploitation (pwn) | [`references/pwn.md`](references/pwn.md) |
| Misc / OSINT / password cracking | [`references/misc-osint.md`](references/misc-osint.md) |

**Boot2root / network track**

| Category | Playbook |
|----------|----------|
| Recon → enum → exploit → privesc → lateral | [`references/network.md`](references/network.md) |

Each playbook follows the same shape: **Triggers → Workflow → Commands → Pitfalls →
Flag extraction**. Commands are written as tool invocations (`nmap`, `sqlmap`, `gdb`,
`volatility3`, …) with `<target>` / `<host>` / `<file>` placeholders — never a hardcoded
connection.

## Requirements

- **Claude Code** (or another runtime that loads `SKILL.md` skills).
- **A separate Kali execution skill.** This skill names the tool and arguments to run and
  expects another skill to actually execute them on a Kali host (over SSH, a container,
  whatever you use). It is intentionally not bundled here — bring your own. If you don't
  have one, the playbooks still work fine as a reference cheatsheet you run by hand.

## Install

Clone into a directory your runtime scans for skills. For Claude Code, that's your
personal skills directory:

```bash
git clone https://github.com/DC205/ctf-playbook-skill.git ~/.claude/skills/ctf-playbook-skill
```

The directory name doesn't matter — the skill is invoked by its frontmatter `name`,
which is **`ctf`**.

## Usage

In a Claude Code session, point it at a challenge:

```
/ctf I have a binary that talks to nc challs.example.com 1337 — get the flag
```

```
/ctf forensics.pcapng — find what was exfiltrated
```

Claude triages the category, loads the right playbook, and drives it through your Kali
skill, keeping notes under `ctf-notes/` (gitignored). On the first unfamiliar flag
format, it will ask you what to match.

## Safety

- Confirm scope/authorization before scanning or attacking any target.
- CTF targets and explicitly authorized engagements only.
- Findings stay local in `ctf-notes/` (gitignored).

## Repo layout

```
SKILL.md                 # the router: triage → dispatch → capture
references/*.md          # the 8 category playbooks
assets/notes-template.md # per-challenge notes scaffold
tests/lint.sh            # structure lint (every playbook follows the shared shape)
tests/triage-rubric.md   # routing dry-run cases
docs/superpowers/        # design spec + implementation plan (how it was built)
```

## Contributing

PRs welcome from DC205. Keep playbooks in the shared five-section shape and run the lint
before opening a PR:

```bash
bash tests/lint.sh   # must print: PASS: ctf skill lint
```

The lint also rejects any hardcoded Kali connection details in `references/` — keep
execution delegated to the Kali skill.

## License

[MIT](LICENSE) © 2026 DC205
