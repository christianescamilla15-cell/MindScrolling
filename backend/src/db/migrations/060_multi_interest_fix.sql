-- 060: Support multi-interest + multi-goal selection (comma-separated)
--
-- Interest = direction (philosophy, stoicism, personal_growth, mindfulness)
-- Goal = what user wants to achieve (calm_mind, discipline, meaning, emotional_clarity, curiosity, creativity, humor)
--
-- Both columns now store comma-separated values.

-- 1. Drop old CHECK constraints
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_interest_check;
ALTER TABLE user_profiles DROP CONSTRAINT IF EXISTS user_profiles_goal_check;

-- 2. Widen columns for comma-separated values
ALTER TABLE user_profiles ALTER COLUMN interest TYPE VARCHAR(100);
ALTER TABLE user_profiles ALTER COLUMN goal TYPE VARCHAR(100);
