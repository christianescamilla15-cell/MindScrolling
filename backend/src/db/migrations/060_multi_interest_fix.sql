-- 060: Support multi-interest selection (comma-separated) + new interests (creativity, humor)
-- The original CHECK constraint only allowed single values from 5 options.
-- Now we need to store comma-separated values like 'philosophy,creativity,humor'.

-- 1. Drop the old CHECK constraint on interest column
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_interest_check;

-- 2. Widen the column to accommodate comma-separated interests (up to 3 × ~20 chars + commas)
ALTER TABLE user_profiles ALTER COLUMN interest TYPE VARCHAR(100);
