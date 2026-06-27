# Steganography

Covers data hidden inside images, audio, and text files.

## Triggers

Image or audio file that is suspiciously large; challenge says "look closer" or "hidden"; spectrogram hint; a visually plain PNG, BMP, JPG, or WAV; a text file with unusual whitespace.

## Workflow

1. Check metadata and embedded strings.
2. Try binwalk for embedded files.
3. Apply bit-plane/channel analysis and format-specific stego tools.
4. If audio, inspect the spectrogram and check for DTMF/Morse.
5. Extract the payload and read the flag.

## Commands

Run these via the kali skill (it owns host/auth):

**First pass (any file type)**
```bash
exiftool <file>
strings -n 8 <file>
binwalk -e <file>
file <file>
```

**Images (PNG, BMP, JPG)**
```bash
# Detect and extract LSB and other patterns (PNG/BMP)
zsteg -a <file>
# Extract steghide payload (JPG/WAV) — try empty passphrase first
steghide extract -sf <file> -p ''
# Wordlist attack on steghide passphrase
stegseek <file> /usr/share/wordlists/rockyou.txt
# Channel/bit-level analysis — use StegSolve GUI or ImageMagick
convert <file> -separate channel_%d.png
# Outguess
outguess -r <file> out.txt
```

**Audio (WAV, MP3)**
```bash
# Spectrogram — open in Audacity: Analyze > Spectrogram, or Sonic Visualiser
# DTMF tone decode
multimon-ng -t wav -a DTMF <file>
# Morse patterns — listen or visualise
strings <file>
```

**Text / whitespace steganography**
```bash
# Detect tabs/spaces encoding (SNOW or similar)
stegsnow -C -m "passphrase" <file>
cat -A <file>   # shows ^I for tabs, trailing spaces
# Whitespace / zero-width character decoder — use an online tool or custom script
```

## Pitfalls

- No single tool covers all formats — work through the checklist methodically.
- `steghide` requires a passphrase; try empty string, the challenge title, and `stegseek` with rockyou.
- The flag may be visible in the spectrogram as text, not extractable as bytes.
- Stego can be double-layered (e.g., a hidden ZIP that itself contains a steghide image).

## Flag extraction

```bash
# After extraction
cat out.txt
strings extracted_payload | grep -oE '[A-Za-z0-9_]+\{[^}]+\}'
# Visual spectrogram flag — read it directly from the Audacity/Sonic Visualiser view
```

Extracted payload or visual text is the flag; pipe extracted bytes through the flag regex to confirm.
