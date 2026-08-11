# rhel-cvereport

한국어 | [English](./README.en.md)

Claude Skill: Automatically generates Red Hat CVE vulnerability security reports in a **fixed Korean-language format**.

Just give it a CVE ID (or a Red Hat CVE page URL) and it will research four sources — the Red Hat CVE page, CSAF/VEX, EPSS, and CISA KEV — and produce a report with the 6 fixed sections below.

> **Note:** The generated report content itself is always written in Korean, regardless of which language you use to invoke the skill. This is by design — the skill was built for Korean-speaking security teams.

---

## 1. Installation

This skill is for **Claude Code** (the CLI / desktop code agent). For Claude.ai web chat, use the manual upload method described in section 3 below — it cannot read a git repository directly.

### Method A — Automated install script (recommended)

Run this one-liner in your terminal:

```bash
curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh | bash
```

- By default this installs **globally** (`~/.claude/skills/redhat-cve-report/`) — available in every project.
- To install for a single project only, run this from inside that project's folder:
  ```bash
  curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh -o install.sh
  bash install.sh --project
  ```
  → Installs to `./.claude/skills/redhat-cve-report/` (only active in that project).

### Method B — Manual install (git clone)

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/yjj3019/rhel-cvereport.git ~/.claude/skills/redhat-cve-report
```

This way the repository itself becomes the skill folder, and you can update to the latest version with a simple `git pull`.
(Method A's install.sh copies files without the `.git` folder, which is cleaner, but requires re-running the script to update.)

### Method C — Claude.ai web / Claude Desktop (manual upload)

Claude.ai web chat and the Claude Desktop app cannot read a git repository directly. Instead:
1. Clone this repository locally, or download `SKILL.md` + `references/TEMPLATE.md`
2. In Claude's settings, go to Capabilities → Skills and upload those files (or a zipped folder)
3. The "Save skill" button only appears if your organization admin has enabled skill usage.

---

## 2. Verifying installation

```bash
# After starting a Claude Code session
claude
```
Type the following in the chat to check whether the skill is registered:
```
What skills do you have available?
```
If `redhat-cve-report` appears, the installation succeeded.

## 3. Usage

In a new Claude Code session, just mention a CVE ID (or a Red Hat CVE page URL) along with a request for a report — the skill triggers automatically. No slash command is needed.

**Example prompts:**
```
Give me a report on CVE-2026-12329
```
```
https://access.redhat.com/security/cve/CVE-2026-55200 — analyze this vulnerability
```
```
Make a security report for libssh2 CVE-2026-55200
```

**Report output:**
- Saved as a file: `CVE-{ID}_리포트.md`
- Fixed structure of 6 sections (report body is in Korean):
  1. Overview (basic CVE info + plain-language vulnerability explanation)
  2. Severity (CVSS) comparison — Red Hat / NVD / cve.org
  3. Real-world exploitation likelihood — EPSS score/percentile, CISA KEV listing status
  4. Mitigation — automatically branches depending on whether an official mitigation exists
  5. Affected products & patches — RHSA per RHEL version, exact fixed package version
  6. Sources — every original URL used during research

## 4. Updating

**If installed via Method A** — just re-run install.sh; it overwrites with the latest version.
```bash
curl -sL https://raw.githubusercontent.com/yjj3019/rhel-cvereport/main/install.sh | bash
```

**If installed via Method B (git clone):**
```bash
cd ~/.claude/skills/redhat-cve-report
git pull
```

## 5. Uninstalling

```bash
rm -rf ~/.claude/skills/redhat-cve-report
# If installed as project-only:
rm -rf ./.claude/skills/redhat-cve-report
```

## 6. File structure

```
rhel-cvereport/
├── install.sh              # Automated install script
├── SKILL.md                # Skill definition: data-fetch order, fixed report rules
├── references/
│   └── TEMPLATE.md         # Verified reference output (CVE-2026-12329) — the format's source of truth
├── README.md                # Korean documentation
└── README.en.md              # This document (English)
```

## 7. How it works (reference)

`SKILL.md` instructs Claude to query the following sources, in this order:
1. Red Hat CVE page (`access.redhat.com/security/cve/{CVE-ID}`) — description, CVSS, presence of an official mitigation
2. Red Hat CSAF/VEX JSON — exact fixed package version (never guessed; if a combination isn't in this JSON, it's left out of the table)
3. Each referenced RHSA's issue date
4. EPSS score (`api.first.org`; automatically falls back to a GitHub mirror on failure)
5. CISA KEV listing status (full scan of the `cisagov/kev-data` GitHub mirror)

`references/TEMPLATE.md` is the actual mold this data gets poured into — `SKILL.md` explicitly forbids changing its section titles, order, table columns, or tone.

## 8. Security notes

This repository and skill never handle passwords, API keys, or personal data. Every API queried (Red Hat, EPSS, CISA) is public data that requires no authentication.
