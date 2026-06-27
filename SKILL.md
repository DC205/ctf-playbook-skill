---
name: ctf
description: Use when working a Capture the Flag (CTF) challenge or event — when given a challenge file, URL, prompt, or target host, or when the user mentions CTF, capture the flag, a flag to find, pwn/crypto/forensics/stego/rev/web challenges, or a boot2root/network box. Triages the challenge to a category, loads the matching playbook, and drives it autonomous-first via the kali skill.
---

# CTF

The brain for CTF events. Triage a challenge, load the right playbook, drive it to a
flag. Tool execution is delegated to the **kali skill** — this skill names the tool and
arguments to run; it never hardcodes the host, auth, or transport.

## How to use this skill

Run the loop: **Triage → Dispatch → Capture**. Stay autonomous-first — run
recon/exploit steps without asking; checkpoint only before destructive or irreversible
actions, and confirm authorization before scanning/attacking any target.

## Triage

Classify the challenge into one category using fast signals. Gather signals first
(via the kali skill where execution is needed):

- Artifact on disk: run `file`, `strings -n 8`, and `binwalk` on it.
- Challenge title and prompt wording (titles often hint the category).
- A URL or web service → web. A bare host/IP or "get root/user.txt" → network.

Routing table (pick the best match; note your confidence):

| Signals | Category | Reference |
|---------|----------|-----------|
| URL, web app, HTTP service, login form, "admin", cookies | web | `references/web.md` |
| ciphertext, keys, "encrypted", base64/hex blobs, RSA params | crypto | `references/crypto.md` |
| disk image, pcap, memory dump, office/pdf docs, carving | forensics | `references/forensics.md` |
| image/audio with hidden data, "look closer", LSB | stego | `references/stego.md` |
| ELF/PE/Mach-O to understand, "what's the password", license check | reversing | `references/reversing.md` |
| ELF/PE with a network service, overflow, "nc host port", shellcode | pwn | `references/pwn.md` |
| odd encodings, trivia, OSINT, a found hash, "google it" | misc-osint | `references/misc-osint.md` |
| target host/box, "get a shell", privesc, user.txt/root.txt | network | `references/network.md` |

If signals are ambiguous, pick the highest-confidence category and proceed; re-triage
on dead-end.

## Dispatch

1. Read the chosen `references/<category>.md` and follow its Workflow.
2. Seed a workspace: copy `assets/notes-template.md` to `ctf-notes/<challenge>/notes.md`.
3. Execute the category's Commands through the kali skill. Log each command + key
   output to the notes file.

## Capture

1. Extract the candidate flag.
2. Validate against the flag format. Default patterns: `flag{...}`, `CTF{...}`,
   `picoCTF{...}`, and any event-specific format the user provides — ask for the format
   if unknown and a candidate doesn't match.
3. Record the flag + the exact reproduction steps in the notes file, then report it.

If stuck: run the chosen reference's Pitfalls/fallback list, then re-triage to the next
most likely category before escalating to the user.

## Safety

- Confirm scope/authorization before scanning or attacking any target.
- Checkpoint before destructive or irreversible actions.
- CTF targets only unless the user explicitly authorizes a pentest engagement.
- Keep all findings in `ctf-notes/`.
