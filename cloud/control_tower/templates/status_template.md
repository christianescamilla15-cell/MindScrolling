# Build Status Entry Template
**Instructions:** Copy this template into build_status.md as a new section after each build iteration. Fill in all fields. Do not leave any field as "TBD" — if unknown, write "Not measured" and explain why.

---

## Build #[N] — [Sprint Name or Description]
**Date:** YYYY-MM-DD
**Sprint:** [Sprint number and name]
**Label:** [Stable / Unstable / Release Candidate / Released]
**Release status:** [NOT READY / BLOCKED / READY / RELEASED]

---

### Score Breakdown

| Category | Score | Max | Notes |
|----------|-------|-----|-------|
| Build Integrity | | 20 | |
| Core Product | | 20 | |
| Localization | | 15 | |
| Premium / Free | | 15 | |
| Data / Backend | | 10 | |
| Performance | | 10 | |
| Docs Alignment | | 10 | |
| **Total** | | **100** | |

**Label:** [score]/100 — [Stable/Unstable/RC]

---

### What earned points

- [Specific fix or feature that contributed to the score]
- [Another item]
- ...

---

### What lost points

- [Specific blocker, missing feature, or gap that cost points]
- [Another item]
- ...

---

### Path to 90+ (if not already there)

| Fix | Points recovered | Owner |
|-----|-----------------|-------|
| [Fix description] | +[N] | [Agent name] |
| ... | | |

---

### Open blockers for this build

List any blockers that exist at the time of this build entry. Cross-reference with blockers.md.

| ID | Description | Severity | Status |
|----|-------------|----------|--------|
| [B-XX] | [Description] | [Critical/Major/Minor] | [Open/In Progress] |
