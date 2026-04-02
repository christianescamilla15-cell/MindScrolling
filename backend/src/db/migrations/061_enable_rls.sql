-- 061: Enable Row Level Security on sensitive tables
--
-- Since MindScrolling uses device_id (not Supabase Auth), RLS policies
-- use a custom claim: current_setting('app.device_id') set by the backend
-- before each request. The service_role key bypasses RLS, so the backend
-- sets the device_id context and queries as the anon role for user-facing ops.
--
-- For now, we enable RLS and create permissive policies that the backend
-- enforces via its own X-Device-ID validation. This prevents direct
-- Supabase REST API abuse from outside the backend.

-- ─── Enable RLS on user-facing tables ────────────────────────────────────────

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_preference_vectors ENABLE ROW LEVEL SECURITY;
ALTER TABLE seen_quotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE vault ENABLE ROW LEVEL SECURITY;
ALTER TABLE swipe_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
ALTER TABLE challenge_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_insights ENABLE ROW LEVEL SECURITY;
ALTER TABLE premium_audit_log ENABLE ROW LEVEL SECURITY;

-- ─── Service role bypass (backend uses service_role key) ─────────────────────
-- The service_role key bypasses RLS automatically in Supabase.
-- These policies only apply to anon/authenticated roles (direct REST access).

-- Users: can only read/modify own row
CREATE POLICY users_own ON users
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY profiles_own ON user_profiles
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY prefs_own ON user_preferences
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY vectors_own ON user_preference_vectors
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY seen_own ON seen_quotes
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY likes_own ON likes
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY vault_own ON vault
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY swipes_own ON swipe_events
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY purchases_own ON purchases
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY challenge_own ON challenge_progress
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

CREATE POLICY insights_own ON ai_insights
  FOR ALL USING (device_id = current_setting('app.device_id', true))
  WITH CHECK (device_id = current_setting('app.device_id', true));

-- Audit log: read-only for own device, no direct writes
CREATE POLICY audit_read_own ON premium_audit_log
  FOR SELECT USING (device_id = current_setting('app.device_id', true));
