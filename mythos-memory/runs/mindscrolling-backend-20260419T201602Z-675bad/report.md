# Mythos Scan Report · mindscrolling-backend

**Run:** `mindscrolling-backend-20260419T201602Z-675bad`
**Started:** 2026-04-19T20:16:02.394934+00:00
**Finished:** 2026-04-19T20:16:03.130888+00:00
**Verdict:** **PASS**
**Suppressed findings:** 0

## Severity summary

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 0 |
| MEDIUM | 28 |
| LOW | 0 |
| INFO | 25 |

## Findings

### MEDIUM (28)

| CWE | File:Line | Scanner | Rule | Title |
|---|---|---|---|---|
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:151` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:152` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:159` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:164` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:165` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:172` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:1125` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:1550` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\048_exercises_sql_html.sql:1555` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:783` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:811` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:812` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:948` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:949` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\050_exercises_typescript.sql:951` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:233` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:234` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:237` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:241` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:1169` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:1170` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:1172` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:1173` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\052_exercises_sql.sql:1177` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\055_exercises_kotlin.sql:1405` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\055_exercises_kotlin.sql:1406` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\055_exercises_kotlin.sql:1408` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |
| CWE-532 | `db\migrations\055_exercises_kotlin.sql:1409` | pii | PII-EMAIL_IN_LOG | Possible PII (EMAIL_IN_LOG) present outside redaction |

### INFO (25)

| CWE | File:Line | Scanner | Rule | Title |
|---|---|---|---|---|
| CWE-79 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-79 | No detection for CWE Top-25 rank #1 · Cross-site Scripting (XSS) |
| CWE-787 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-787 | No detection for CWE Top-25 rank #2 · Out-of-bounds Write |
| CWE-89 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-89 | No detection for CWE Top-25 rank #3 · SQL Injection |
| CWE-352 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-352 | No detection for CWE Top-25 rank #4 · CSRF |
| CWE-22 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-22 | No detection for CWE Top-25 rank #5 · Path Traversal |
| CWE-125 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-125 | No detection for CWE Top-25 rank #6 · Out-of-bounds Read |
| CWE-78 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-78 | No detection for CWE Top-25 rank #7 · OS Command Injection |
| CWE-416 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-416 | No detection for CWE Top-25 rank #8 · Use After Free |
| CWE-862 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-862 | No detection for CWE Top-25 rank #9 · Missing Authorization |
| CWE-434 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-434 | No detection for CWE Top-25 rank #10 · Unrestricted Upload of File with Dangerous Type |
| CWE-94 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-94 | No detection for CWE Top-25 rank #11 · Improper Control of Code Generation (Code Injection) |
| CWE-20 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-20 | No detection for CWE Top-25 rank #12 · Improper Input Validation |
| CWE-77 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-77 | No detection for CWE Top-25 rank #13 · Command Injection (generic) |
| CWE-287 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-287 | No detection for CWE Top-25 rank #14 · Improper Authentication |
| CWE-269 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-269 | No detection for CWE Top-25 rank #15 · Improper Privilege Management |
| CWE-502 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-502 | No detection for CWE Top-25 rank #16 · Deserialization of Untrusted Data |
| CWE-200 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-200 | No detection for CWE Top-25 rank #17 · Exposure of Sensitive Information |
| CWE-863 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-863 | No detection for CWE Top-25 rank #18 · Incorrect Authorization |
| CWE-918 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-918 | No detection for CWE Top-25 rank #19 · SSRF |
| CWE-119 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-119 | No detection for CWE Top-25 rank #20 · Improper Restriction of Operations within Memory Buffer |
| CWE-476 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-476 | No detection for CWE Top-25 rank #21 · NULL Pointer Dereference |
| CWE-798 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-798 | No detection for CWE Top-25 rank #22 · Hardcoded Credentials |
| CWE-190 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-190 | No detection for CWE Top-25 rank #23 · Integer Overflow or Wraparound |
| CWE-400 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-400 | No detection for CWE Top-25 rank #24 · Uncontrolled Resource Consumption |
| CWE-306 | `(coverage):0` | adversary-coverage | COVERAGE-GAP-CWE-306 | No detection for CWE Top-25 rank #25 · Missing Authentication for Critical Function |
