-- MindScrolling — Migration 009: Pack Monetization
-- Block B: Individual pack purchases, preview curation, swipe source tracking.
-- SAFE to run on a live DB — uses IF NOT EXISTS / ADD COLUMN IF NOT EXISTS.
-- Grandfathering cutoff constant: 2026-06-01 (Sprint 8 ship date, BR-04).

-- ─── 1. New table: pack_purchases ─────────────────────────────────────────────
-- Records individual pack purchase entitlements per device.
-- One canonical row per (device_id, pack_id) — duplicates prevented by UNIQUE.
-- A second purchase attempt upserts and updates status to 'verified'.
-- Restore creates a second row with status = 'restored' (matches purchases table
-- pattern from migration 005). Do NOT use this table for Inside entitlements;
-- those live in users.is_premium. This table is pack-scoped only.

CREATE TABLE IF NOT EXISTS pack_purchases (
  id               UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id        VARCHAR(100)  NOT NULL REFERENCES users(device_id) ON DELETE CASCADE,
  pack_id          VARCHAR(50)   NOT NULL,
  store            VARCHAR(10)   NOT NULL,        -- 'ios' | 'android'
  product_id       TEXT          NOT NULL,        -- e.g. com.mindscrolling.pack.stoicism_deep
  transaction_id   TEXT,                          -- App Store transaction_id
  purchase_token   TEXT,                          -- Play Store purchase token
  amount           NUMERIC(10,2) NOT NULL,
  currency         CHAR(3)       NOT NULL DEFAULT 'USD',
  status           VARCHAR(20)   NOT NULL DEFAULT 'verified',
  purchased_at     TIMESTAMPTZ   NOT NULL DEFAULT now(),
  updated_at       TIMESTAMPTZ   NOT NULL DEFAULT now(),

  -- EC-09: prevent duplicate rows for the same device+pack (upsert target)
  UNIQUE (device_id, pack_id)
);

-- store constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'pack_purchases_store_check'
  ) THEN
    ALTER TABLE pack_purchases
      ADD CONSTRAINT pack_purchases_store_check
        CHECK (store IN ('ios', 'android'));
  END IF;
END;
$$;

-- status constraint
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'pack_purchases_status_check'
  ) THEN
    ALTER TABLE pack_purchases
      ADD CONSTRAINT pack_purchases_status_check
        CHECK (status IN ('verified', 'restored', 'pending', 'failed'));
  END IF;
END;
$$;

-- pack_id constraint — locked to the three packs in scope for Block B.
-- Future packs added post-grandfathering cutoff are added here via a subsequent
-- migration that extends this constraint (never alter prod ad-hoc).
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'pack_purchases_pack_id_check'
  ) THEN
    ALTER TABLE pack_purchases
      ADD CONSTRAINT pack_purchases_pack_id_check
        CHECK (pack_id IN ('stoicism_deep', 'existentialism', 'zen_mindfulness'));
  END IF;
END;
$$;

-- Indexes on pack_purchases
CREATE INDEX IF NOT EXISTS idx_pack_purchases_device
  ON pack_purchases(device_id);

CREATE INDEX IF NOT EXISTS idx_pack_purchases_device_pack
  ON pack_purchases(device_id, pack_id);

-- Supports restore lookup by transaction_id (iOS) or purchase_token (Android)
CREATE INDEX IF NOT EXISTS idx_pack_purchases_transaction
  ON pack_purchases(transaction_id)
  WHERE transaction_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_pack_purchases_token
  ON pack_purchases(purchase_token)
  WHERE purchase_token IS NOT NULL;

-- ─── 2. Preview curation columns on quotes ────────────────────────────────────
-- is_pack_preview: true when this quote is designated as part of the curated
--   preview set for its pack. Must be set per (pack_name, lang) combination.
--   Curation is NOT shared across languages (US-B10, US-B11).
--
-- pack_preview_rank: 1–15, determines preview order.
--   Rank 1–5  → shown to Free users (and Trial users).
--   Rank 6–15 → shown to Trial users only.
--   NULL      → not a preview quote.
--
-- released_at: timestamp the pack was released. Used to determine whether a
--   pack is a "future pack" that falls after the grandfathering cutoff
--   (EC-07, GRANDFATHERING_CUTOFF = 2026-06-01). Backfilled to now() for
--   the three existing packs by the UPDATE statement below.

ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS is_pack_preview   BOOLEAN  NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS pack_preview_rank INT      CHECK (pack_preview_rank BETWEEN 1 AND 15),
  ADD COLUMN IF NOT EXISTS released_at       TIMESTAMPTZ DEFAULT now();

-- pack_preview_rank must be non-null when is_pack_preview is true
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'quotes_preview_rank_required'
  ) THEN
    ALTER TABLE quotes
      ADD CONSTRAINT quotes_preview_rank_required
        CHECK (
          (is_pack_preview = false)
          OR
          (is_pack_preview = true AND pack_preview_rank IS NOT NULL)
        );
  END IF;
END;
$$;

-- Backfill released_at for the three existing packs so they are treated as
-- pre-grandfathering-cutoff packs (i.e., included for Inside users for free).
-- Any pack added AFTER 2026-06-01 will have released_at > cutoff and must be
-- purchased separately even by Inside users.
UPDATE quotes
SET released_at = '2026-01-01T00:00:00Z'
WHERE pack_name IN ('stoicism_deep', 'existentialism', 'zen_mindfulness');

-- Indexes for preview query (GET /packs/:id/preview)
-- Covering index: pack + lang + preview flag + rank — all needed for the query
CREATE INDEX IF NOT EXISTS idx_quotes_pack_preview
  ON quotes(pack_name, lang, is_pack_preview, pack_preview_rank)
  WHERE is_pack_preview = true;

-- Partial index for full pack feed (GET /packs/:id/feed)
-- Filters on pack_name + lang; ordered by scoring logic in application layer
CREATE INDEX IF NOT EXISTS idx_quotes_pack_feed
  ON quotes(pack_name, lang)
  WHERE pack_name IS NOT NULL AND pack_name <> 'free';

-- ─── 3. Swipe source tracking on swipe_events ─────────────────────────────────
-- source: distinguishes main-feed swipes from pack-feed swipes (BR-07).
--   'feed' is the default — backward compatible with all existing rows.
--   'pack' is set when swipe originates from GET /packs/:id/feed.
--   'preview' is set for pack preview swipes — these do NOT update user
--   preference weights or trial quota (BR-08, BR-06).
--
-- source_pack_id: populated when source = 'pack' or source = 'preview'.
--   Used to produce per-pack analytics and the Philosophy Map (BR-07).

ALTER TABLE swipe_events
  ADD COLUMN IF NOT EXISTS source         VARCHAR(10)  NOT NULL DEFAULT 'feed',
  ADD COLUMN IF NOT EXISTS source_pack_id VARCHAR(50);

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'swipe_events_source_check'
  ) THEN
    ALTER TABLE swipe_events
      ADD CONSTRAINT swipe_events_source_check
        CHECK (source IN ('feed', 'pack', 'preview'));
  END IF;
END;
$$;

-- source_pack_id required when source is 'pack' or 'preview'
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'swipe_events_pack_id_required'
  ) THEN
    ALTER TABLE swipe_events
      ADD CONSTRAINT swipe_events_pack_id_required
        CHECK (
          (source = 'feed' AND source_pack_id IS NULL)
          OR
          (source IN ('pack', 'preview') AND source_pack_id IS NOT NULL)
        );
  END IF;
END;
$$;

-- Index for pack-scoped analytics
CREATE INDEX IF NOT EXISTS idx_swipe_events_pack_source
  ON swipe_events(source_pack_id, source)
  WHERE source IN ('pack', 'preview');

-- ─── 4. RLS policies ──────────────────────────────────────────────────────────
-- All policies use Supabase anon key, scoped by device_id passed from the
-- Fastify service role connection. RLS on pack_purchases prevents any client
-- from reading other devices' purchase records directly.
--
-- The Fastify backend always uses the SERVICE ROLE key, so these policies
-- apply to direct client queries only (a defense-in-depth measure, not the
-- primary entitlement gate — that is server-side in Fastify routes).

ALTER TABLE pack_purchases ENABLE ROW LEVEL SECURITY;

-- Service role bypasses RLS. Anon clients can only see their own rows.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'pack_purchases' AND policyname = 'pack_purchases_device_isolation'
  ) THEN
    CREATE POLICY pack_purchases_device_isolation
      ON pack_purchases
      FOR ALL
      USING (device_id = current_setting('request.jwt.claims', true)::json->>'sub');
  END IF;
END;
$$;

-- ─── 5. Analytics helper: pack_catalog_events ─────────────────────────────────
-- Extends premium_audit_log with pack-specific events (Section 11 of scope).
-- No new table required — all pack analytics events go into premium_audit_log
-- using the event_type values defined below. The metadata JSONB column carries
-- all event-specific fields.
--
-- Registered event_type values for Block B:
--   pack_catalog_viewed
--   pack_preview_started
--   pack_preview_completed
--   pack_paywall_shown
--   pack_purchase_started
--   pack_purchased
--   pack_feed_entered
--   trial_soft_paywall_shown
--   trial_hard_paywall_shown
--
-- No schema changes needed — premium_audit_log already has the correct shape.
-- This comment block documents the event catalog for implementers.

-- ─── 6. Pack pricing table ────────────────────────────────────────────────────
-- Stores server-side canonical prices per pack (BR-01: price comes from backend,
-- not hardcoded in the client). Allows price updates without an app release.
-- Regional currencies are informational only — actual charge is always in USD
-- via the payment provider.

CREATE TABLE IF NOT EXISTS pack_prices (
  pack_id           VARCHAR(50)   NOT NULL,
  currency          CHAR(3)       NOT NULL,
  amount            NUMERIC(10,2) NOT NULL,
  product_id_ios    TEXT,                    -- com.mindscrolling.pack.<id>
  product_id_android TEXT,
  is_active         BOOLEAN       NOT NULL DEFAULT true,
  updated_at        TIMESTAMPTZ   NOT NULL DEFAULT now(),
  PRIMARY KEY (pack_id, currency)
);

-- Seed canonical prices for the three Block B packs (BR-01, US-B06)
INSERT INTO pack_prices (pack_id, currency, amount, product_id_ios, product_id_android)
VALUES
  ('stoicism_deep',    'USD', 2.99, 'com.mindscrolling.pack.stoicism_deep',    'com.mindscrolling.pack.stoicism_deep'),
  ('stoicism_deep',    'EUR', 2.69, NULL, NULL),
  ('stoicism_deep',    'CAD', 3.99, NULL, NULL),
  ('stoicism_deep',    'BRL', 14.90, NULL, NULL),
  ('existentialism',   'USD', 2.99, 'com.mindscrolling.pack.existentialism',   'com.mindscrolling.pack.existentialism'),
  ('existentialism',   'EUR', 2.69, NULL, NULL),
  ('existentialism',   'CAD', 3.99, NULL, NULL),
  ('existentialism',   'BRL', 14.90, NULL, NULL),
  ('zen_mindfulness',  'USD', 2.99, 'com.mindscrolling.pack.zen_mindfulness',  'com.mindscrolling.pack.zen_mindfulness'),
  ('zen_mindfulness',  'EUR', 2.69, NULL, NULL),
  ('zen_mindfulness',  'CAD', 3.99, NULL, NULL),
  ('zen_mindfulness',  'BRL', 14.90, NULL, NULL)
ON CONFLICT (pack_id, currency) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_pack_prices_pack
  ON pack_prices(pack_id)
  WHERE is_active = true;
