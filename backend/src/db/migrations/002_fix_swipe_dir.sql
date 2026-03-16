-- MindScrolling — Migration 002
-- Fix swipe_dir values to align with the canonical direction mapping:
--   stoicism  → up
--   philosophy → down
--   discipline → right
--   reflection → left
--
-- Run this in Supabase SQL Editor ONCE after migration 001.
-- Safe to re-run (idempotent WHERE clauses).

UPDATE quotes SET swipe_dir = 'up'    WHERE category = 'stoicism'   AND swipe_dir != 'up';
UPDATE quotes SET swipe_dir = 'down'  WHERE category = 'philosophy'  AND swipe_dir != 'down';
UPDATE quotes SET swipe_dir = 'right' WHERE category = 'discipline'  AND swipe_dir != 'right';
UPDATE quotes SET swipe_dir = 'left'  WHERE category = 'reflection'  AND swipe_dir != 'left';

-- Verify counts after running:
-- SELECT category, swipe_dir, COUNT(*) FROM quotes GROUP BY category, swipe_dir ORDER BY category;
