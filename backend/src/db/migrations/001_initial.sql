-- MindScrolling — Schema v2 (Sprint 4)
-- Run this in Supabase SQL Editor

-- ─── DROP EXISTING (clean reset) ─────────────────────────────────────────────
DROP TABLE IF EXISTS challenge_progress       CASCADE;
DROP TABLE IF EXISTS daily_challenges         CASCADE;
DROP TABLE IF EXISTS user_preference_snapshots CASCADE;
DROP TABLE IF EXISTS swipe_events             CASCADE;
DROP TABLE IF EXISTS purchases                CASCADE;
DROP TABLE IF EXISTS user_profiles            CASCADE;
DROP TABLE IF EXISTS seen_quotes              CASCADE;
DROP TABLE IF EXISTS user_preferences         CASCADE;
DROP TABLE IF EXISTS vault                    CASCADE;
DROP TABLE IF EXISTS likes                    CASCADE;
DROP TABLE IF EXISTS users                    CASCADE;
DROP TABLE IF EXISTS quotes                   CASCADE;
DROP FUNCTION IF EXISTS increment_like(VARCHAR, VARCHAR);
DROP FUNCTION IF EXISTS decrement_like(VARCHAR, VARCHAR);

-- ─── QUOTES ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quotes (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  text        TEXT NOT NULL,
  author      VARCHAR(150) NOT NULL,
  category    VARCHAR(50) NOT NULL CHECK (category IN ('stoicism','philosophy','discipline','reflection')),
  lang        CHAR(2) NOT NULL DEFAULT 'en',
  swipe_dir   VARCHAR(10) NOT NULL CHECK (swipe_dir IN ('left','right','up','down')),
  pack_name   VARCHAR(50) NOT NULL DEFAULT 'free',
  is_premium  BOOLEAN NOT NULL DEFAULT false,
  created_at  TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_quotes_category_lang ON quotes(category, lang);
CREATE UNIQUE INDEX IF NOT EXISTS idx_quotes_text_author ON quotes(text, author);

-- ─── USERS ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  device_id          VARCHAR(100) PRIMARY KEY,
  streak             INT NOT NULL DEFAULT 0,
  total_reflections  INT NOT NULL DEFAULT 0,
  last_active        DATE,
  is_premium         BOOLEAN NOT NULL DEFAULT false,
  created_at         TIMESTAMPTZ DEFAULT now()
);

-- ─── LIKES ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS likes (
  device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id   UUID REFERENCES quotes(id) ON DELETE CASCADE,
  liked_at   TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (device_id, quote_id)
);
CREATE INDEX IF NOT EXISTS idx_likes_device ON likes(device_id);

-- ─── VAULT ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS vault (
  device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id   UUID REFERENCES quotes(id) ON DELETE CASCADE,
  saved_at   TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (device_id, quote_id)
);

-- ─── USER PREFERENCES (category weights for recommendation) ──────────────────
CREATE TABLE IF NOT EXISTS user_preferences (
  device_id          VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  category           VARCHAR(50) NOT NULL,
  like_count         INT NOT NULL DEFAULT 0,
  swipe_count        INT NOT NULL DEFAULT 0,
  wisdom_score       NUMERIC(5,2) DEFAULT 0,
  discipline_score   NUMERIC(5,2) DEFAULT 0,
  reflection_score   NUMERIC(5,2) DEFAULT 0,
  philosophy_score   NUMERIC(5,2) DEFAULT 0,
  updated_at         TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (device_id, category)
);

-- ─── SEEN QUOTES (prevents repeats in feed) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS seen_quotes (
  device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id   UUID REFERENCES quotes(id) ON DELETE CASCADE,
  seen_at    TIMESTAMPTZ DEFAULT now(),
  PRIMARY KEY (device_id, quote_id)
);
CREATE INDEX IF NOT EXISTS idx_seen_device ON seen_quotes(device_id);

-- ─── USER PROFILES (onboarding data) ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_profiles (
  device_id          VARCHAR(100) PRIMARY KEY REFERENCES users(device_id) ON DELETE CASCADE,
  age_range          VARCHAR(10)  CHECK (age_range IN ('18-24','25-34','35-44','45+')),
  interest           VARCHAR(30)  CHECK (interest IN ('philosophy','stoicism','personal_growth','mindfulness','curiosity')),
  goal               VARCHAR(30)  CHECK (goal IN ('calm_mind','discipline','meaning','emotional_clarity')),
  preferred_language CHAR(2) NOT NULL DEFAULT 'en',
  created_at         TIMESTAMPTZ DEFAULT now(),
  updated_at         TIMESTAMPTZ DEFAULT now()
);

-- ─── SWIPE EVENTS (raw event log) ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS swipe_events (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id     VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id      UUID REFERENCES quotes(id) ON DELETE CASCADE,
  direction     VARCHAR(10) NOT NULL,
  category      VARCHAR(50) NOT NULL,
  dwell_time_ms INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_swipe_events_device ON swipe_events(device_id);

-- ─── USER PREFERENCE SNAPSHOTS (for progress map history) ────────────────────
CREATE TABLE IF NOT EXISTS user_preference_snapshots (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id         VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  wisdom_score      NUMERIC(5,2) DEFAULT 0,
  discipline_score  NUMERIC(5,2) DEFAULT 0,
  reflection_score  NUMERIC(5,2) DEFAULT 0,
  philosophy_score  NUMERIC(5,2) DEFAULT 0,
  created_at        TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_snapshots_device ON user_preference_snapshots(device_id);

-- ─── DAILY CHALLENGES ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS daily_challenges (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code         VARCHAR(50) UNIQUE NOT NULL,
  title        VARCHAR(150) NOT NULL,
  description  TEXT NOT NULL,
  active_date  DATE NOT NULL,
  created_at   TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_challenges_date ON daily_challenges(active_date);

-- ─── CHALLENGE PROGRESS ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS challenge_progress (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id     VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  challenge_id  UUID REFERENCES daily_challenges(id) ON DELETE CASCADE,
  progress      INT DEFAULT 0,
  completed     BOOLEAN DEFAULT false,
  created_at    TIMESTAMPTZ DEFAULT now(),
  updated_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE (device_id, challenge_id)
);

-- ─── PURCHASES ───────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS purchases (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id      VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  purchase_type  VARCHAR(50) NOT NULL DEFAULT 'premium_unlock',
  amount         NUMERIC(10,2),
  currency       CHAR(3) DEFAULT 'USD',
  created_at     TIMESTAMPTZ DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_purchases_device ON purchases(device_id);

-- ─── HELPER FUNCTIONS (called from API) ──────────────────────────────────────
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
