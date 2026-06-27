#!/usr/bin/env bash
# Verifies the CTF skill follows its required structure.
# Exit 0 = pass, 1 = fail. Dependency-free (bash + grep).
set -u
cd "$(dirname "$0")/.." || exit 1
fail=0
err() { echo "FAIL: $*"; fail=1; }

# --- SKILL.md ---
[ -f SKILL.md ] || err "SKILL.md missing"
if [ -f SKILL.md ]; then
  head -1 SKILL.md | grep -q '^---$' || err "SKILL.md missing frontmatter opener"
  grep -q '^name:' SKILL.md || err "SKILL.md frontmatter missing name:"
  grep -q '^description:' SKILL.md || err "SKILL.md frontmatter missing description:"
  for s in Triage Dispatch Capture Safety; do
    grep -qi "## .*$s" SKILL.md || err "SKILL.md missing '## $s' section"
  done
fi

# --- references ---
REQ=("## Triggers" "## Workflow" "## Commands" "## Pitfalls" "## Flag extraction")
EXPECTED=(web crypto forensics stego reversing pwn misc-osint network)
for name in "${EXPECTED[@]}"; do
  f="references/$name.md"
  [ -f "$f" ] || { err "$f missing"; continue; }
  for h in "${REQ[@]}"; do
    grep -qF "$h" "$f" || err "$f missing section '$h'"
  done
  # commands must not hardcode the kali host/transport
  if grep -qiE 'ssh +[a-z]+@|192\.168\.|nohup .*2>&1 &' "$f"; then
    err "$f hardcodes kali connection details (delegate to kali skill instead)"
  fi
done

# --- assets + rubric ---
[ -f assets/notes-template.md ] || err "assets/notes-template.md missing"
[ -f tests/triage-rubric.md ] || err "tests/triage-rubric.md missing"

if [ "$fail" -eq 0 ]; then echo "PASS: ctf skill lint"; fi
exit "$fail"
