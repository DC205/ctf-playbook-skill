# Triage Rubric

Dry-run check: read each description, decide the category using SKILL.md's routing
table, and confirm it matches "Expected". Used to verify the router classifies
correctly.

| # | Challenge description | Expected category |
|---|-----------------------|-------------------|
| 1 | "Login page at http://10.0.0.5/admin, bypass it" | web |
| 2 | "Here's n, e, and c. Recover the message." | crypto |
| 3 | "capture.pcapng — find what was exfiltrated" | forensics |
| 4 | "innocent.png — there's more than meets the eye" | stego |
| 5 | "crackme ELF, find the password it checks" | reversing |
| 6 | "nc challs.ctf 1337 — binary attached, get a shell" | pwn |
| 7 | "Decode this: U0ZUe...== then base32 then rot13" | misc-osint |
| 8 | "Box at 10.10.10.20 — get user.txt and root.txt" | network |
| 9 | "WAV file, the flag is in the sound" | stego |
| 10 | "sudo -l shows you can run vim as root" | network |
