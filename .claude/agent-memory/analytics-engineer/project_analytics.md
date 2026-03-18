---
name: MindScrolling - Analytics context
description: Data sources, KPI definitions, and analytics infrastructure as of Sprint 7 (2026-03-18)
type: project
---

## Available Data Sources (Supabase tables)

- `swipe_events` — direction, category, source (feed/pack/preview), dwell_time_ms, lang, created_at
- `vault` — saved quotes per device
- `seen_quotes` — feed coverage per device (deduplication table)
- `user_preferences` — like_count, vault_count, skip_count, total_dwell_ms per (device_id, category)
- `premium_audit_log` — all premium lifecycle events with JSONB metadata
- `pack_purchases` — individual pack entitlements (device_id, pack_id, purchased_at, status)
- `purchases` — Inside purchases
- `challenge_progress` — daily challenge completion
- `user_preference_snapshots` — philosophy map score history
- `users` — premium_status (free/trial/premium_onetime/premium_lifetime), trial_start_date, trial_end_date

## Registered Analytics Events (premium_audit_log.event_type)

Pack events: pack_catalog_viewed, pack_preview_started, pack_preview_completed, pack_paywall_shown, pack_purchase_started, pack_purchased, pack_feed_entered
Trial events: trial_soft_paywall_shown, trial_hard_paywall_shown
Premium events: premium_purchased, premium_restored, trial_started, activation_code_redeemed

## Key KPIs to Track Post-Launch

- D1 / D7 retention (devices seen again after first_seen_at)
- Free → Trial conversion rate
- Trial → Inside conversion rate
- Free → Pack purchase rate
- Pack preview completion rate (preview_completed / preview_started)
- Pack paywall-to-purchase rate
- Save rate per quote / per category
- Average dwell_time_ms per category
- Challenge completion rate
- Swipe source distribution (feed vs pack vs preview)

## Infrastructure Status

- No dedicated analytics tool yet (PostHog / Mixpanel not integrated)
- All analytics queryable via Supabase SQL editor
- `swipe_events.source` added in Migration 009 (2026-03-18) — pack analytics now trackable
- `premium_audit_log` is the primary funnel tracking table

**Why:** Pre-launch. Analytics infrastructure exists in DB but no dashboards built yet.
**How to apply:** First priority post-Play Store is building D1/D7 retention views and conversion funnel queries in Supabase.
