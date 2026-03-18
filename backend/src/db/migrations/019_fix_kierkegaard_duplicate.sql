-- Migration 019: Fix duplicate Kierkegaard author rows and normalize quotes.
-- The authors table has both 'soren_kierkegaard' and 's_ren_kierkegaard' (from ø).
-- Standardize on 'soren_kierkegaard' and clean up the orphan.

-- 1. Update any quotes that reference 'Søren Kierkegaard' to the ASCII version
UPDATE quotes SET author = 'Soren Kierkegaard'
WHERE author = 'Søren Kierkegaard';

-- 2. Transfer quote_count from the orphan row to the canonical row
UPDATE authors
SET quote_count = (
  SELECT COUNT(*) FROM quotes WHERE author = 'Soren Kierkegaard'
)
WHERE slug = 'soren_kierkegaard';

-- 3. Delete the orphaned row
DELETE FROM authors WHERE slug = 's_ren_kierkegaard';
