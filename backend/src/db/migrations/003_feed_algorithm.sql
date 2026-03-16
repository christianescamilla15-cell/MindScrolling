-- MindScrolling — Migration 003: Feed Algorithm Enhancement
-- Run in Supabase SQL Editor (after 002_fix_swipe_dir.sql)
-- Idempotent — safe to run multiple times

-- ─── 1. Enrich user_preferences with richer behavioural signals ───────────────
ALTER TABLE user_preferences
  ADD COLUMN IF NOT EXISTS vault_count    INT    NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS skip_count     INT    NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_dwell_ms BIGINT NOT NULL DEFAULT 0;

COMMENT ON COLUMN user_preferences.vault_count    IS 'Times device saved a quote from this category (+5 weight)';
COMMENT ON COLUMN user_preferences.skip_count     IS 'Times device swiped with dwell < 500ms (negative signal)';
COMMENT ON COLUMN user_preferences.total_dwell_ms IS 'Cumulative dwell time on this category (ms); avg = total / swipe_count';

-- ─── 2. Performance indexes ───────────────────────────────────────────────────

-- Partial index for free-tier feed (most common query path)
CREATE INDEX IF NOT EXISTS idx_quotes_feed_free
  ON quotes(lang, category, id)
  WHERE is_premium = false;

-- Composite index for premium feed
CREATE INDEX IF NOT EXISTS idx_quotes_feed_all
  ON quotes(lang, category, id);

-- Index powering the NOT EXISTS exclusion in get_feed_candidates
CREATE INDEX IF NOT EXISTS idx_seen_device_quote
  ON seen_quotes(device_id, quote_id);

-- Index for seen_quotes reset query (DELETE WHERE device_id = ?)
CREATE INDEX IF NOT EXISTS idx_seen_device
  ON seen_quotes(device_id);

-- Index for user_preferences lookups
CREATE INDEX IF NOT EXISTS idx_prefs_device
  ON user_preferences(device_id);

-- ─── 3. RPC: get_feed_candidates ─────────────────────────────────────────────
-- Replaces the NOT IN (500 UUIDs) anti-pattern.
-- NOT EXISTS is index-friendly and has no URL-length limit.
-- Returns a raw pool of p_pool_size unseen quotes — JS layer does scoring.

DROP FUNCTION IF EXISTS get_feed_candidates(TEXT, TEXT, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION get_feed_candidates(
  p_device_id  TEXT,
  p_lang       TEXT,
  p_is_premium BOOLEAN,
  p_pool_size  INT
)
RETURNS SETOF quotes
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $$
  SELECT q.*
  FROM quotes q
  WHERE q.lang = p_lang
    AND (p_is_premium = true OR q.is_premium = false)
    AND NOT EXISTS (
      SELECT 1
      FROM   seen_quotes sq
      WHERE  sq.device_id = p_device_id
        AND  sq.quote_id  = q.id
    )
  LIMIT p_pool_size;
$$;

-- ─── 4. RPC: increment_vault / decrement_vault ───────────────────────────────
-- Kept as RPCs (like increment_like) so the JS layer stays thin.

DROP FUNCTION IF EXISTS increment_vault(TEXT, TEXT);
DROP FUNCTION IF EXISTS decrement_vault(TEXT, TEXT);

CREATE OR REPLACE FUNCTION increment_vault(
  p_device_id TEXT,
  p_category  TEXT
)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  INSERT INTO user_preferences (device_id, category, vault_count, updated_at)
  VALUES (p_device_id, p_category, 1, now())
  ON CONFLICT (device_id, category)
  DO UPDATE SET
    vault_count = user_preferences.vault_count + 1,
    updated_at  = now();
$$;

CREATE OR REPLACE FUNCTION decrement_vault(
  p_device_id TEXT,
  p_category  TEXT
)
RETURNS void
LANGUAGE sql
SECURITY DEFINER
AS $$
  UPDATE user_preferences
  SET vault_count = GREATEST(0, vault_count - 1),
      updated_at  = now()
  WHERE device_id = p_device_id
    AND category  = p_category;
$$;
