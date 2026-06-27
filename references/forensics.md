# Forensics

Covers disk images, packet captures, memory dumps, documents, and file carving.

## Triggers

Disk image file (.img, .dd, .E01); packet capture (.pcap, .pcapng); memory dump (.raw, .mem, .vmem); office or PDF documents with anomalies; challenge asks to "recover" or "carve" something.

## Workflow

1. Identify the container type with `file` and initial metadata tools.
2. Extract or carve embedded content appropriate to the container.
3. Analyze at the right layer (packets, processes, filesystem, metadata).
4. Locate and read the flag.

## Commands

Run these via the kali skill (it owns host/auth):

**Identify and extract**
```bash
file <file>
binwalk -e <file>              # extract embedded files
foremost -i <file> -o out/     # carve by magic bytes
photorec                       # interactive carver for disks/images
strings -n 8 <file>
```

**Metadata**
```bash
exiftool <file>
strings -n 8 <file> | grep -iE 'flag|CTF|password'
```

**PCAP analysis**
```bash
# Open in Wireshark for visual inspection and stream following
wireshark <file>
# CLI — filter HTTP requests
tshark -r <file> -Y 'http.request'
# Follow a TCP stream (stream number from Wireshark)
tshark -r <file> -qz follow,tcp,ascii,0
# Export HTTP objects
tshark -r <file> --export-objects http,out/
# USB HID keystroke extraction
tshark -r <file> -Y 'usb.capdata' -T fields -e usb.capdata
# (pipe HID codes through a keymap lookup script)
```

**Memory forensics (Volatility 3)**
```bash
volatility3 -f <file> windows.info
volatility3 -f <file> windows.pslist
volatility3 -f <file> windows.cmdline
volatility3 -f <file> windows.filescan | grep -i flag
volatility3 -f <file> windows.dumpfiles --pid <pid>
# Linux profile
volatility3 -f <file> linux.pslist
```

**NTFS alternate data streams**
```bash
# On a mounted Windows image — list/read ADS
mount -o loop,ro <file> /mnt/img        # mount via ntfs-3g
getfattr -R -d -m '.*' /mnt/img         # list alternate data streams (Linux)
# Windows equivalent: dir /r   then   more < file:stream
```

**PDF analysis**
```bash
qpdf --qdf --object-streams=disable <file> out.pdf
pdf-parser <file>
pdfextract <file>
strings <file> | grep -iE 'flag|CTF'
# Check layers in Inkscape or Illustrator; inspect metadata with exiftool
```

## Pitfalls

- Truncated or wrong-magic files may need manual header repair before tools parse them.
- Volatility requires matching symbol tables for the OS version — use `windows.info` to identify, then fetch symbols.
- The flag may be split across multiple packets; reconstruct the stream.
- Hidden data may live in filesystem slack space — use a disk forensics suite.

## Flag extraction

```bash
strings <artifact> | grep -iE 'flag\{|CTF\{'
grep -raiE 'flag\{|CTF\{' out/
# After carving or dumping a file, open it and check its content
cat out/<carved-file>
```

Reconstruct any exfiltrated file reassembled from packet streams, then grep for the flag regex.
