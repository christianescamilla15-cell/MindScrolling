-- 027_fix_swipe_dir_new_packs.sql
-- CRIT-01 fix: All new pack quotes had swipe_dir distributed across all 4 directions
-- instead of matching the canonical category→direction mapping:
--   stoicism  → up
--   philosophy → down
--   discipline → right
--   reflection → left
--
-- Since ALL new pack quotes have category='philosophy', they should ALL have swipe_dir='down'.

UPDATE quotes SET swipe_dir = 'down'
WHERE pack_name IN ('renaissance_mind', 'classical_foundations', 'modern_human_condition')
  AND category = 'philosophy'
  AND swipe_dir != 'down';

-- For safety, also fix any other category mismatches in these packs
UPDATE quotes SET swipe_dir = 'up'
WHERE pack_name IN ('renaissance_mind', 'classical_foundations', 'modern_human_condition')
  AND category = 'stoicism'
  AND swipe_dir != 'up';

UPDATE quotes SET swipe_dir = 'right'
WHERE pack_name IN ('renaissance_mind', 'classical_foundations', 'modern_human_condition')
  AND category = 'discipline'
  AND swipe_dir != 'right';

UPDATE quotes SET swipe_dir = 'left'
WHERE pack_name IN ('renaissance_mind', 'classical_foundations', 'modern_human_condition')
  AND category = 'reflection'
  AND swipe_dir != 'left';
