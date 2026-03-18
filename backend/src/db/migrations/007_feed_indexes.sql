-- MindScrolling — Migration 007: Feed query performance indexes
-- Run in Supabase SQL Editor (after 006_premium_codes.sql)
-- Idempotent — safe to run multiple times
--
-- CONTEXT: The feed route has two code paths:
--   1. Primary: RPC match_quotes / get_feed_candidates (pgvector ANN search)
--   2. Fallback: Direct quotes table scan per-category (when RPC not deployed)
--
-- These indexes cover both paths and the vault/swipe-event lookups that
-- happen on every feed request.

-- ─── 1. Quotes — main feed filter ────────────────────────────────────────────
-- Covers: WHERE lang = ? AND category = ? AND is_premium = false
-- Used by the fallback per-category query and get_feed_candidates RPC.
CREATE INDEX IF NOT EXISTS idx_quotes_feed_free
  ON quotes (lang, category)
  WHERE is_premium = false;

-- Covers: WHERE lang = ? AND category = ? (premium users — all quotes)
CREATE INDEX IF NOT EXISTS idx_quotes_feed_lang_cat
  ON quotes (lang, category);

-- ─── 2. Quotes — pack browser ─────────────────────────────────────────────────
-- Covers: WHERE pack_name IS NOT NULL AND lang = ?  (GET /packs)
CREATE INDEX IF NOT EXISTS idx_quotes_pack_lang
  ON quotes (lang, pack_name)
  WHERE pack_name IS NOT NULL;

-- ─── 3. Swipe events — unseen filter ─────────────────────────────────────────
-- Used by get_feed_candidates to exclude already-seen quotes per device.
-- Covers: WHERE device_id = ?  (large tables will benefit most)
CREATE INDEX IF NOT EXISTS idx_swipe_events_device
  ON swipe_events (device_id, quote_id);

-- ─── 4. User preferences — map + feed weights ─────────────────────────────────
-- Covers: WHERE device_id = ?  (called on every feed request)
CREATE INDEX IF NOT EXISTS idx_user_preferences_device
  ON user_preferences (device_id);

-- ─── 5. Vault — duplicate check + count ───────────────────────────────────────
-- Covers: WHERE device_id = ? AND quote_id = ?  (save dedup)
--         WHERE device_id = ? (free-user vault count)
CREATE INDEX IF NOT EXISTS idx_vault_device_quote
  ON vault (device_id, quote_id);

-- ─── 6. Challenge progress — today's progress lookup ─────────────────────────
-- Covers: WHERE challenge_id = ? AND device_id = ?
CREATE INDEX IF NOT EXISTS idx_challenge_progress_lookup
  ON challenge_progress (challenge_id, device_id);

-- ─── 7. User preference snapshots — map evolution ────────────────────────────
-- Covers: WHERE device_id = ? ORDER BY created_at DESC LIMIT 1
CREATE INDEX IF NOT EXISTS idx_snapshots_device_date
  ON user_preference_snapshots (device_id, created_at DESC);

-- ─── 8. Premium audit log — admin view (ordered by date) ─────────────────────
CREATE INDEX IF NOT EXISTS idx_audit_log_date
  ON premium_audit_log (created_at DESC);
