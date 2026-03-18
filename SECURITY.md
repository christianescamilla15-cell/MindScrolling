# Security Policy

## Supported Versions

| Version | Supported |
| ------- | --------- |
| latest (main) | ✅ |

## Reporting a Vulnerability

**Please do not open a public GitHub issue for security vulnerabilities.**

Email: **security@mindscrolling.app** (or contact the maintainer directly via GitHub)

Include:
- A clear description of the vulnerability
- Steps to reproduce
- Affected endpoints or components
- Potential impact

We will acknowledge receipt within **48 hours** and aim to release a fix within **7 days** for critical issues.

## Scope

In scope:
- Backend API (`/backend`)
- Flutter mobile app (`/flutter_app`)
- Supabase database schema and RLS policies

Out of scope:
- Third-party services (Supabase, RevenueCat, Sentry, Railway)
- Denial-of-service attacks

## Security Measures

- All requests require a device ID header (`x-device-id`)
- Rate limiting: 60 req/min per IP (configurable)
- HTTP security headers via `@fastify/helmet`
- Secrets managed via environment variables — never committed to git
- Automated secret scanning on every push (Gitleaks + TruffleHog)
- Weekly dependency audits via Dependabot
- Row-Level Security (RLS) enabled on all Supabase tables
- Webhook authenticity verified via shared secret (timing-safe compare)
- Sensitive headers redacted from logs (`authorization`, `x-device-id`, `cookie`)
