-- Migration 017: Restore discipline, reflection, and philosophy quotes to the free feed.
--
-- The pack assignment script (assign_pack_quotes.sql) incorrectly captured
-- these 3 core categories into paid packs, leaving the main feed with only
-- stoicism quotes. This migration restores them to pack_name='free' so they
-- appear in the free feed for all tiers via the RPC filters:
--   (pack_name = 'free' OR pack_name IS NULL)
--
-- Safe to re-run (idempotent — updates only rows that match the condition).

-- 1. Discipline quotes: were in stoicism_deep
UPDATE quotes
SET pack_name = 'free'
WHERE category = 'discipline'
  AND pack_name = 'stoicism_deep';

-- 2. Reflection quotes: were in zen_mindfulness
UPDATE quotes
SET pack_name = 'free'
WHERE category = 'reflection'
  AND pack_name = 'zen_mindfulness';

-- 3. Philosophy quotes: were in existentialism
UPDATE quotes
SET pack_name = 'free'
WHERE category = 'philosophy'
  AND pack_name = 'existentialism';
