-- Migration 014: Change ai_insights unique constraint from device_id to (device_id, lang).
-- This allows bilingual users to cache insights in both EN and ES without
-- overwriting each other on every language switch.

-- Drop the old unique constraint on device_id alone
ALTER TABLE ai_insights DROP CONSTRAINT IF EXISTS ai_insights_device_id_key;

-- Add a composite unique constraint on (device_id, lang)
ALTER TABLE ai_insights ADD CONSTRAINT ai_insights_device_lang_key UNIQUE (device_id, lang);
