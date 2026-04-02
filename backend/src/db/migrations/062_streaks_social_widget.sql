-- 062: Streaks tracking + Social feed + Widget quote of the day

-- ─── STREAK TRACKING (daily login/usage) ─────────────────────────────────────
-- Users table already has streak INT column. Add tracking fields.
DO $$ BEGIN
  ALTER TABLE users ADD COLUMN last_active_date DATE;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE users ADD COLUMN longest_streak INT DEFAULT 0;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;

DO $$ BEGIN
  ALTER TABLE users ADD COLUMN streak_updated_at TIMESTAMPTZ;
EXCEPTION WHEN duplicate_column THEN NULL; END $$;

-- ─── SOCIAL FEED (friends' liked/vaulted quotes) ─────────────────────────────
-- Follow system: users can follow other users to see their activity
CREATE TABLE IF NOT EXISTS follows (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  follower_id     VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  following_id    VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  created_at      TIMESTAMPTZ DEFAULT now(),
  UNIQUE(follower_id, following_id)
);

CREATE INDEX IF NOT EXISTS idx_follows_follower ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following ON follows(following_id);

-- Social activity feed (what friends liked/vaulted)
CREATE TABLE IF NOT EXISTS social_activity (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id       VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id        UUID REFERENCES quotes(id) ON DELETE CASCADE,
  action_type     VARCHAR(20) NOT NULL CHECK (action_type IN ('like', 'vault', 'share')),
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_social_device ON social_activity(device_id);
CREATE INDEX IF NOT EXISTS idx_social_created ON social_activity(created_at DESC);

-- ─── WIDGET: Quote of the Day ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quote_of_day (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quote_id        UUID REFERENCES quotes(id) ON DELETE CASCADE,
  active_date     DATE NOT NULL UNIQUE,
  lang            CHAR(2) NOT NULL DEFAULT 'en',
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_qotd_date ON quote_of_day(active_date DESC);

-- ─── RLS on new tables ───────────────────────────────────────────────────────
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_activity ENABLE ROW LEVEL SECURITY;

CREATE POLICY follows_own ON follows
  FOR ALL USING (follower_id = current_setting('app.device_id', true))
  WITH CHECK (follower_id = current_setting('app.device_id', true));

CREATE POLICY social_own ON social_activity
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));
