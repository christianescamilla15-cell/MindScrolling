-- MindScrolling — Migration 008: Catch-Up Schema
-- Applies ALL changes from migrations 001–007 that are missing from the current DB.
-- SAFE to run on a live DB — uses IF NOT EXISTS and ADD COLUMN IF NOT EXISTS.
-- Does NOT drop any existing tables or data.
-- Run in Supabase SQL Editor.

-- ─── 1. Missing columns on users ─────────────────────────────────────────────
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_premium            BOOLEAN    NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS premium_since         TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS premium_status        TEXT        DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS premium_source        TEXT,
  ADD COLUMN IF NOT EXISTS premium_activated_at  TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS trial_start_date      TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS trial_end_date        TIMESTAMPTZ;

-- premium_status constraint (free / trial / premium_onetime / premium_lifetime)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_premium_status_check'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_premium_status_check
        CHECK (premium_status IN ('free','trial','premium_onetime','premium_lifetime'));
  END IF;
END;
$$;

-- premium_source constraint — includes app_store (iOS) and play_billing (Android)
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_premium_source_check'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_premium_source_check
        CHECK (premium_source IN (
          'play_billing','app_store','donation_manual',
          'admin_grant','activation_code','legacy_unlock'
        ));
  END IF;
END;
$$;

-- ─── 2. Missing columns on quotes ────────────────────────────────────────────
ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS pack_name   VARCHAR(50) NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS is_premium  BOOLEAN     NOT NULL DEFAULT false;

-- ─── 3. Enable pgvector extension ────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS vector;

-- ─── 4. Embedding column on quotes ───────────────────────────────────────────
ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS embedding VECTOR(512);

-- ─── 5. Missing tables ───────────────────────────────────────────────────────

-- seen_quotes (prevents feed repeats)
CREATE TABLE IF NOT EXISTS seen_quotes (
  device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id   UUID         REFERENCES quotes(id)       ON DELETE CASCADE,
  seen_at    TIMESTAMPTZ  DEFAULT now(),
  PRIMARY KEY (device_id, quote_id)
);
CREATE INDEX IF NOT EXISTS idx_seen_device_quote ON seen_quotes(device_id, quote_id);
CREATE INDEX IF NOT EXISTS idx_seen_device        ON seen_quotes(device_id);

-- user_profiles (onboarding)
CREATE TABLE IF NOT EXISTS user_profiles (
  device_id          VARCHAR(100) PRIMARY KEY REFERENCES users(device_id) ON DELETE CASCADE,
  age_range          VARCHAR(10)  CHECK (age_range  IN ('18-24','25-34','35-44','45+')),
  interest           VARCHAR(30)  CHECK (interest   IN ('philosophy','stoicism','personal_growth','mindfulness','curiosity')),
  goal               VARCHAR(30)  CHECK (goal       IN ('calm_mind','discipline','meaning','emotional_clarity','mindfulness')),
  preferred_language CHAR(2)      NOT NULL DEFAULT 'en',
  created_at         TIMESTAMPTZ  DEFAULT now(),
  updated_at         TIMESTAMPTZ  DEFAULT now()
);

-- swipe_events (raw event log)
CREATE TABLE IF NOT EXISTS swipe_events (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id     VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id      UUID         REFERENCES quotes(id)       ON DELETE CASCADE,
  direction     VARCHAR(10)  NOT NULL,
  category      VARCHAR(50),
  lang          CHAR(2)      DEFAULT 'en',
  dwell_time_ms INT          DEFAULT 0,
  created_at    TIMESTAMPTZ  DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_swipe_events_device ON swipe_events(device_id);
CREATE INDEX IF NOT EXISTS idx_swipe_device_quote  ON swipe_events(device_id, quote_id);

-- user_preference_snapshots (philosophy map history)
CREATE TABLE IF NOT EXISTS user_preference_snapshots (
  id                UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id         VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  wisdom_score      NUMERIC(5,2) DEFAULT 0,
  discipline_score  NUMERIC(5,2) DEFAULT 0,
  reflection_score  NUMERIC(5,2) DEFAULT 0,
  philosophy_score  NUMERIC(5,2) DEFAULT 0,
  created_at        TIMESTAMPTZ  DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_snapshots_device ON user_preference_snapshots(device_id);
CREATE INDEX IF NOT EXISTS idx_snapshots_device_date ON user_preference_snapshots(device_id, created_at DESC);

-- daily_challenges
CREATE TABLE IF NOT EXISTS daily_challenges (
  id           UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  code         VARCHAR(50) UNIQUE NOT NULL,
  title        VARCHAR(150) NOT NULL,
  description  TEXT         NOT NULL,
  category     VARCHAR(50),
  active_date  DATE         NOT NULL,
  created_at   TIMESTAMPTZ  DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_challenges_date ON daily_challenges(active_date);

-- challenge_progress
CREATE TABLE IF NOT EXISTS challenge_progress (
  id            UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id     VARCHAR(100) REFERENCES users(device_id)      ON DELETE CASCADE,
  challenge_id  UUID         REFERENCES daily_challenges(id)  ON DELETE CASCADE,
  progress      INT          DEFAULT 0,
  completed     BOOLEAN      DEFAULT false,
  created_at    TIMESTAMPTZ  DEFAULT now(),
  updated_at    TIMESTAMPTZ  DEFAULT now(),
  UNIQUE (device_id, challenge_id)
);
CREATE INDEX IF NOT EXISTS idx_challenge_progress_lookup ON challenge_progress(challenge_id, device_id);

-- purchases
CREATE TABLE IF NOT EXISTS purchases (
  id             UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id      VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  purchase_type  VARCHAR(50)  NOT NULL DEFAULT 'premium_unlock',
  store          TEXT,
  product_id     TEXT,
  purchase_token TEXT,
  transaction_id TEXT,
  amount         NUMERIC(10,2),
  currency       CHAR(3)      DEFAULT 'USD',
  status         TEXT         NOT NULL DEFAULT 'verified',
  updated_at     TIMESTAMPTZ  DEFAULT now(),
  created_at     TIMESTAMPTZ  DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_purchases_device    ON purchases(device_id);
CREATE INDEX IF NOT EXISTS idx_purchases_device_id ON purchases(device_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status    ON purchases(status);

-- Add status check constraint if not exists
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'purchases_status_check'
      AND conrelid = 'purchases'::regclass
  ) THEN
    ALTER TABLE purchases
      ADD CONSTRAINT purchases_status_check
        CHECK (status IN ('pending','verified','failed','restored'));
  END IF;
END;
$$;

-- premium_activation_codes
CREATE TABLE IF NOT EXISTS premium_activation_codes (
  id             UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  code           TEXT    UNIQUE NOT NULL,
  type           TEXT    NOT NULL DEFAULT 'lifetime',
  created_by     TEXT    DEFAULT 'admin',
  assigned_email TEXT,
  notes          TEXT,
  is_redeemed    BOOLEAN DEFAULT false,
  redeemed_by    TEXT,
  redeemed_at    TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  revoked        BOOLEAN DEFAULT false,
  created_at     TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_codes_code     ON premium_activation_codes(code);
CREATE INDEX IF NOT EXISTS idx_codes_redeemed ON premium_activation_codes(is_redeemed);

-- premium_audit_log
CREATE TABLE IF NOT EXISTS premium_audit_log (
  id          UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id   TEXT,
  event_type  TEXT    NOT NULL,
  source      TEXT,
  metadata    JSONB   DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_audit_device   ON premium_audit_log(device_id);
CREATE INDEX IF NOT EXISTS idx_audit_event    ON premium_audit_log(event_type);
CREATE INDEX IF NOT EXISTS idx_audit_log_date ON premium_audit_log(created_at DESC);

-- user_preference_vectors (semantic preference)
CREATE TABLE IF NOT EXISTS user_preference_vectors (
  device_id     VARCHAR(100) PRIMARY KEY REFERENCES users(device_id) ON DELETE CASCADE,
  vector        VECTOR(512)  NOT NULL,
  signal_count  INT          NOT NULL DEFAULT 0,
  updated_at    TIMESTAMPTZ  DEFAULT now()
);

-- weekly_insights (AI insight cache)
CREATE TABLE IF NOT EXISTS weekly_insights (
  id         UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  week_key   TEXT    NOT NULL,
  lang       CHAR(2) NOT NULL DEFAULT 'en',
  insight    TEXT    NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (device_id, week_key, lang)
);
CREATE INDEX IF NOT EXISTS idx_insights_device_week ON weekly_insights(device_id, week_key);

-- ─── 6. Missing columns on user_preferences ──────────────────────────────────
ALTER TABLE user_preferences
  ADD COLUMN IF NOT EXISTS vault_count    INT    NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS skip_count     INT    NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS total_dwell_ms BIGINT NOT NULL DEFAULT 0;

-- ─── 7. Indexes ───────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_quotes_category_lang   ON quotes(category, lang);
CREATE INDEX IF NOT EXISTS idx_quotes_feed_free        ON quotes(lang, category) WHERE is_premium = false;
CREATE INDEX IF NOT EXISTS idx_quotes_feed_lang_cat    ON quotes(lang, category);
CREATE INDEX IF NOT EXISTS idx_quotes_pack_lang        ON quotes(lang, pack_name) WHERE pack_name IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_prefs_device            ON user_preferences(device_id);
CREATE INDEX IF NOT EXISTS idx_user_preferences_device ON user_preferences(device_id);
CREATE INDEX IF NOT EXISTS idx_vault_device_quote      ON vault(device_id, quote_id);

-- HNSW vector index (only once quotes have embeddings)
CREATE INDEX IF NOT EXISTS idx_quotes_embedding_hnsw
  ON quotes USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64)
  WHERE embedding IS NOT NULL;

-- ─── 8. Helper functions ──────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION increment_like(p_device_id VARCHAR, p_category VARCHAR)
RETURNS VOID AS $$
BEGIN
  INSERT INTO user_preferences (device_id, category, like_count, swipe_count)
  VALUES (p_device_id, p_category, 1, 0)
  ON CONFLICT (device_id, category)
  DO UPDATE SET like_count = user_preferences.like_count + 1, updated_at = now();
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION decrement_like(p_device_id VARCHAR, p_category VARCHAR)
RETURNS VOID AS $$
BEGIN
  UPDATE user_preferences
  SET like_count = GREATEST(like_count - 1, 0), updated_at = now()
  WHERE device_id = p_device_id AND category = p_category;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS increment_vault(TEXT, TEXT);
DROP FUNCTION IF EXISTS decrement_vault(TEXT, TEXT);

CREATE OR REPLACE FUNCTION increment_vault(p_device_id TEXT, p_category TEXT)
RETURNS void LANGUAGE sql SECURITY DEFINER AS $$
  INSERT INTO user_preferences (device_id, category, vault_count, updated_at)
  VALUES (p_device_id, p_category, 1, now())
  ON CONFLICT (device_id, category)
  DO UPDATE SET vault_count = user_preferences.vault_count + 1, updated_at = now();
$$;

CREATE OR REPLACE FUNCTION decrement_vault(p_device_id TEXT, p_category TEXT)
RETURNS void LANGUAGE sql SECURITY DEFINER AS $$
  UPDATE user_preferences
  SET vault_count = GREATEST(0, vault_count - 1), updated_at = now()
  WHERE device_id = p_device_id AND category = p_category;
$$;

DROP FUNCTION IF EXISTS get_feed_candidates(TEXT, TEXT, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION get_feed_candidates(
  p_device_id  TEXT,
  p_lang       TEXT,
  p_is_premium BOOLEAN,
  p_pool_size  INT
)
RETURNS SETOF quotes
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT q.*
  FROM quotes q
  WHERE q.lang = p_lang
    AND (p_is_premium = true OR q.is_premium = false)
    AND NOT EXISTS (
      SELECT 1 FROM seen_quotes sq
      WHERE sq.device_id = p_device_id AND sq.quote_id = q.id
    )
  LIMIT p_pool_size;
$$;
