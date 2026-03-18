# Security Workflow — MindScrolling
**Last updated:** 2026-03-18

> Public repository. Every line of code is visible to everyone.
> This document defines how the team prevents, detects, and responds to security incidents.

---

## 1. Security Layers (Defense in Depth)

```
Layer 1 — Developer machine
  └── pre-commit hook (.git/hooks/pre-commit)
      └── blocks secrets before they enter git

Layer 2 — GitHub
  └── .github/workflows/security-scan.yml
      └── Gitleaks scan on every push/PR
      └── npm audit on backend deps
      └── .env leak check

Layer 3 — GitHub native (automatic)
  └── GitHub Secret Scanning (automatic for public repos)
      └── Alerts on detected Supabase, Anthropic, etc. keys

Layer 4 — Infrastructure
  └── Supabase RLS (Row Level Security) on all tables
  └── Backend validates device_id on every request
  └── Admin endpoints: timing-safe comparison + rate limit
  └── RevenueCat webhook: timing-safe shared secret verification

Layer 5 — Operational
  └── Key rotation procedure (this document)
      └── Rotate immediately on any suspected exposure
```

---

## 2. What Must NEVER Be in the Repo

| Item | Why | Alternative |
|------|-----|-------------|
| `SUPABASE_URL` (real project URL) | Exposes project identity | Use `process.env.SUPABASE_URL` |
| `SUPABASE_ANON_KEY` | JWT with project ref + role | Use `process.env.SUPABASE_ANON_KEY` |
| `SUPABASE_SERVICE_ROLE_KEY` | **Full DB access, bypasses RLS** | Never commit, store in Railway only |
| `ANTHROPIC_API_KEY` | Billable API key | Use `process.env.ANTHROPIC_API_KEY` |
| `VOYAGE_API_KEY` | Billable API key | Use `process.env.VOYAGE_API_KEY` |
| `ADMIN_SECRET` | Admin endpoint bypass | Use `process.env.ADMIN_SECRET` |
| `REVENUECAT_WEBHOOK_SECRET` | Webhook auth bypass | Use `process.env.REVENUECAT_WEBHOOK_SECRET` |
| `SENTRY_DSN` | Project identifier | Use `process.env.SENTRY_DSN` |
| Android `.keystore` / `.jks` | APK signing key | Store offline or in encrypted vault |
| `key.properties` | Keystore credentials | Excluded by .gitignore |
| `google-services.json` | Firebase/GCM keys | Excluded by .gitignore |
| `GoogleService-Info.plist` | Firebase/APNS keys | Excluded by .gitignore |
| Real `.env` files | All of the above | Only `.env.example` is tracked |

---

## 3. Pre-Commit Hook

**Location:** `.git/hooks/pre-commit` (active on this machine)

Blocks commits containing:
- Supabase JWT tokens
- Hardcoded Supabase project URLs
- Anthropic API keys (`sk-ant-...`)
- Voyage AI keys (`pa-...`)
- Generic secrets (40+ char strings assigned to `*key*` or `*secret*` vars)
- `.env` files (non-example)
- Android keystore binaries
- `google-services.json` / `GoogleService-Info.plist`

> **Note:** `.git/hooks/` is not tracked by git. Every developer on a new machine must run:
> ```bash
> cp scripts/setup-hooks.sh . && sh setup-hooks.sh
> ```
> Or manually copy the hook file.

---

## 4. GitHub Actions

**File:** `.github/workflows/security-scan.yml`

Runs on every push to `main`/`develop` and every PR:
- **Gitleaks** — full git history + diff secret scan
- **npm audit** — high-severity dependency vulnerabilities
- **.env leak check** — confirms no real env files are tracked
- **JWT scan** — searches all JS/TS/Dart files for hardcoded tokens

---

## 5. Key Rotation Procedure

**When to rotate:** Immediately if:
- A key appears in a public commit (even briefly)
- A key appears in a PR diff that was public
- GitHub Secret Scanning fires an alert
- Any team member's machine is suspected compromised

### Supabase Keys
1. Go to Supabase → Project Settings → API
2. Click **Regenerate** on `anon` key (and `service_role` key if needed)
3. Update `SUPABASE_ANON_KEY` in Railway environment variables
4. Update local `.env` files on all dev machines
5. Redeploy backend on Railway

### Anthropic API Key
1. Go to console.anthropic.com → API Keys
2. Delete the compromised key
3. Create a new key
4. Update `ANTHROPIC_API_KEY` in Railway

### Admin Secret
1. Generate a new random secret: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"`
2. Update `ADMIN_SECRET` in Railway
3. Restart backend service

### RevenueCat Webhook Secret
1. Go to RevenueCat → Project → Webhooks
2. Regenerate the shared secret
3. Update `REVENUECAT_WEBHOOK_SECRET` in Railway

---

## 6. Git History Cleaning (BFG)

If secrets were committed to git history (as happened with `fetch_es.js` and `hardcode_es.js`):

```bash
# Install BFG Repo Cleaner (Java required)
# https://rtyley.github.io/bfg-repo-cleaner/

# 1. Create a backup
git clone --mirror https://github.com/user/MindScrolling.git MindScrolling-backup.git

# 2. Remove the specific string from all history
# Create a file with the secrets to replace:
echo "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." > secrets.txt

# 3. Run BFG
java -jar bfg.jar --replace-text secrets.txt MindScrolling.git

# 4. Clean and force-push
cd MindScrolling.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive
git push --force

# 5. All collaborators must re-clone (history has changed)
```

> **Important:** After BFG, rotate ALL keys that were in history (they may have been cached by GitHub, search engines, or anyone who cloned).

---

## 7. Supabase Row Level Security (RLS)

All tables must have RLS enabled. Current status:

| Table | RLS | Policy |
|-------|-----|--------|
| users | ✅ | device_id match via X-Device-ID header (backend enforced) |
| quotes | ✅ | public read; no direct client writes |
| vault | ✅ | device_id match |
| user_preferences | ✅ | device_id match |
| swipe_events | ✅ | device_id match |
| daily_challenges | ✅ | public read |
| challenge_progress | ✅ | device_id match |
| purchases | ✅ | device_id match |
| premium_activation_codes | ✅ | read only via backend (anon key cannot list all codes) |
| premium_audit_log | ✅ | write-only via backend service role |

> **Rule:** Never use `service_role` key in the Flutter app or frontend code. Only in backend server-to-server calls.

---

## 8. Security Agent Role

The **Security Agent** (part of the multi-agent workflow) is responsible for:

- Running a security check after every sprint close
- Verifying no new secrets leaked into commits
- Reviewing new dependencies for known vulnerabilities
- Confirming RLS policies are still active after schema migrations
- Updating this document when new keys or services are added

**Trigger:** Automatically after any commit that:
- Adds a new third-party service
- Changes authentication/authorization logic
- Adds new environment variables
- Modifies database schema

**Output format:**
```
Security Check — Build #N
Secrets scan: PASS / FAIL
Dep audit: PASS / X high-severity issues
RLS status: OK / DEGRADED
New env vars documented: YES / NO
Key rotation needed: YES / NO
```

---

## 9. Incident Response

If a secret is confirmed exposed:

1. **T+0 min** — Rotate the affected key immediately (see section 5)
2. **T+5 min** — Check Supabase logs for anomalous queries in the last 24h
3. **T+10 min** — Revoke and reissue any activation codes generated with admin endpoint
4. **T+30 min** — Run BFG to clean git history (section 6)
5. **T+1h** — Document incident in `cloud/debugging/debug_log.md`
6. **T+24h** — Post-mortem: how did it happen, what pre-commit rule would have caught it

---

## 10. Environment Variables Inventory

| Variable | Service | Sensitivity | Where stored |
|----------|---------|-------------|--------------|
| `SUPABASE_URL` | Supabase | Medium (project identifier) | Railway, local .env |
| `SUPABASE_ANON_KEY` | Supabase | Medium (public by design but don't expose) | Railway, local .env |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase | **CRITICAL** (bypasses RLS) | Railway only — never local |
| `ANTHROPIC_API_KEY` | Claude API | High (billable) | Railway, local .env |
| `VOYAGE_API_KEY` | Voyage AI | High (billable) | Railway, local .env |
| `ADMIN_SECRET` | Backend admin | High | Railway only |
| `REVENUECAT_WEBHOOK_SECRET` | RevenueCat | High (revenue bypass) | Railway only |
| `SENTRY_DSN` | Sentry | Low (project identifier) | Railway, can be public |
| `PORT` | Server | None | Railway |
| `ALLOWED_ORIGIN` | CORS | Low | Railway |
| `NODE_ENV` | Runtime | None | Railway |

---

*Updated by Security Agent after every sprint. Reviewed by Backend Implementer before each release.*
