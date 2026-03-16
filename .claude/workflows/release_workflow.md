# Release Preparation Workflow

## Purpose

This document defines how a stable version of MindScrolling is prepared, validated, and approved for release. No release ships without passing all validation gates.

---

## Agents Involved

| Order | Agent | Role |
|-------|-------|------|
| 1 | Scrum Coordinator | Prepare release checklist |
| 2 | QA Reviewer | Stability review |
| 3 | Performance Engineer | Performance review |
| 4 | Documentation Writer | Update release docs |
| 5 | DevOps Engineer | Validate deployment |
| 6 | Agent Orchestrator | Approve release |

---

## Execution Sequence

### STEP 1 — Scrum Coordinator: Release Checklist

**Trigger:** Decision to prepare a release.

**Responsibilities:**
- List all features included in this release
- List all bugs fixed in this release
- Identify any known issues or limitations
- Confirm all sprint tasks are marked complete

**Required Output:**
```
Release: v<version>
Date: <target date>

Features Included:
  - <feature 1>
  - <feature 2>

Bugs Fixed:
  - <bug 1>
  - <bug 2>

Known Issues:
  - <issue 1> (severity, workaround if any)

Open Items: none | <list>
Sprint Status: all tasks complete | <exceptions>
```

---

### STEP 2 — QA Reviewer: Stability Review

**Trigger:** Release checklist prepared.

**Responsibilities:**
- Run full regression check across all features
- Verify all listed features work as expected
- Verify all listed bug fixes are resolved
- Check for new regressions

**Stability Checklist:**

- [ ] Feed loads correctly (EN)
- [ ] Feed loads correctly (ES)
- [ ] Language auto-detection works
- [ ] Language toggle in Settings works and reloads feed
- [ ] Swipe interactions work (left, right, up, down)
- [ ] Like/unlike works
- [ ] Vault save/remove works
- [ ] Navigation: Feed → Vault → back works
- [ ] Navigation: Feed → Map → back works
- [ ] Navigation: Feed → Insights → back works
- [ ] Navigation: Feed → Settings → back works
- [ ] Onboarding flow completes successfully
- [ ] Onboarding language selection persists
- [ ] Premium gating displays correctly
- [ ] Share/export generates image correctly
- [ ] No Flutter rendering exceptions in debug log
- [ ] No unhandled backend 500 errors
- [ ] Author names display correctly per language
- [ ] Category badges display correctly
- [ ] Streak counter increments properly
- [ ] Ambient audio plays and pauses correctly
- [ ] Ambient audio survives app background/foreground
- [ ] Donation screen accessible and functional
- [ ] Onboarding interest tiles render correctly (no blank boxes)
- [ ] Onboarding reset works from Settings

**Required Output:**
```
Stability Review: PASS | FAIL
Tests Passed: <count>/<total>
Failed Tests:
  - <test>: <reason>
Regressions Found: none | <list>
Recommendation: PROCEED | BLOCK (reason)
```

**Gate:** Release cannot proceed if stability review is FAIL with Critical/Major issues.

---

### STEP 3 — Performance Engineer: Performance Review

**Trigger:** Stability review passed.

**Responsibilities:**
- Review app startup time
- Review feed loading latency
- Review memory usage patterns
- Review network efficiency (payload sizes, request count)
- Review asset sizes (fonts, images, audio)
- Review Supabase query efficiency
- Verify app binary size is reasonable

**Performance Checklist:**

- [ ] Feed first load < 3 seconds on mobile network
- [ ] Swipe transition feels smooth (no jank)
- [ ] No excessive widget rebuilds
- [ ] API response payloads are reasonably sized
- [ ] No N+1 query patterns in backend
- [ ] Database queries use appropriate indexes
- [ ] App binary size < 50MB (debug) / < 25MB (release)
- [ ] No memory leaks detected in extended use
- [ ] Audio playback does not degrade performance

**Required Output:**
```
Performance Review: ACCEPTABLE | NEEDS OPTIMIZATION | HIGH RISK
Key Metrics:
  Feed Load Time: <ms>
  App Size: <MB>
  API Response Size (avg): <KB>
Performance Risks: none | <list>
Optimization Recommendations: <if any>
```

---

### STEP 4 — Documentation Writer: Release Documentation

**Trigger:** Performance review completed.

**Responsibilities:**
- Update SCRUM.md with sprint completion
- Update ROADMAP.md with release status
- Update README.md if feature set changed significantly
- Write release notes

**Required Output:**
```
Files Updated:
  - <file 1>: <what changed>
  - <file 2>: <what changed>

Release Notes:
  Version: v<version>
  Highlights:
    - <highlight 1>
    - <highlight 2>
  Bug Fixes:
    - <fix 1>
  Known Issues:
    - <issue 1>
```

---

### STEP 5 — DevOps Engineer: Deployment Validation

**Trigger:** Documentation updated.

**Responsibilities:**
- Verify all database migrations are applied
- Verify environment variables are correct for production
- Verify backend is deployed and healthy
- Verify API endpoints respond correctly
- Verify no development-only configuration leaks to production

**Deployment Checklist:**

- [ ] All Supabase migrations applied
- [ ] Backend deployed and /health returns OK
- [ ] API_BASE_URL configured correctly for production
- [ ] No debug flags in production build
- [ ] CORS configured for production domains
- [ ] Rate limiting configured appropriately
- [ ] SSL/TLS configured correctly
- [ ] Environment secrets are not exposed
- [ ] Backup strategy confirmed

**Required Output:**
```
Deployment Validation: PASS | FAIL
Environment: production | staging
Backend Status: healthy | <issue>
Database Status: migrated | <pending migrations>
Issues: none | <list>
```

---

### STEP 6 — Agent Orchestrator: Release Approval

**Trigger:** All previous steps completed.

**Responsibilities:**
- Verify all gates passed
- Collect all step outputs
- Make final release decision

**Approval Criteria:**
- [ ] Stability review: PASS
- [ ] Performance review: ACCEPTABLE or better
- [ ] Documentation: Updated
- [ ] Deployment: PASS
- [ ] No Critical or Major open issues

**Required Output:**
```
Release: v<version>
Decision: APPROVED | REJECTED (reason)
Gates:
  Stability: pass/fail
  Performance: pass/fail
  Documentation: pass/fail
  Deployment: pass/fail
Next Steps: <deploy / fix issues / re-review>
```

---

## MindScrolling-Specific Release Checks

Every release must explicitly verify:

1. **Multilingual UI** — EN and ES are complete and consistent
2. **Premium plan** — "MindScrolling Inside" at $4.99 USD displays correctly
3. **Ambient audio** — Stable, no crashes, no battery drain
4. **Backend quotes** — App reads from Supabase, not bundled data
5. **API contracts** — Backend and Flutter are aligned
6. **App size** — Not shipping bloated datasets or oversized assets
