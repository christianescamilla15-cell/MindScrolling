-- 023_content_model_expansion.sql
-- Phase 1: Content model refactor for multi-mode expansion
-- Adds content_type, sub_category, tags, locked_by, is_hidden_mode to quotes table

-- content_type: 'philosophical' (default), 'science', 'coding'
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS content_type VARCHAR(30) NOT NULL DEFAULT 'philosophical';

-- sub_category: finer grain within category (e.g., 'physics', 'frontend', 'humanism')
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS sub_category VARCHAR(60);

-- tags: emotional/thematic tags for Insight matching (e.g., '{motivation,calm,focus}')
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';

-- locked_by: which hidden mode locks this content (null = not locked)
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS locked_by VARCHAR(30);

-- is_hidden_mode: whether this content belongs to a hidden mode (science, coding)
ALTER TABLE quotes ADD COLUMN IF NOT EXISTS is_hidden_mode BOOLEAN NOT NULL DEFAULT FALSE;

-- Indexes for the new query patterns
CREATE INDEX IF NOT EXISTS idx_quotes_content_type ON quotes(content_type);
CREATE INDEX IF NOT EXISTS idx_quotes_sub_category ON quotes(sub_category) WHERE sub_category IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_quotes_locked_by ON quotes(locked_by) WHERE locked_by IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_quotes_is_hidden_mode ON quotes(is_hidden_mode) WHERE is_hidden_mode = TRUE;
CREATE INDEX IF NOT EXISTS idx_quotes_tags ON quotes USING GIN(tags) WHERE tags != '{}';

-- Backfill existing philosophical quotes: set tags based on category
UPDATE quotes SET tags = ARRAY['wisdom', 'discipline', 'inner_strength']
WHERE category = 'stoicism' AND (tags IS NULL OR tags = '{}');

UPDATE quotes SET tags = ARRAY['reflection', 'meaning', 'existence']
WHERE category = 'philosophy' AND (tags IS NULL OR tags = '{}');

UPDATE quotes SET tags = ARRAY['discipline', 'focus', 'self_improvement']
WHERE category = 'discipline' AND (tags IS NULL OR tags = '{}');

UPDATE quotes SET tags = ARRAY['calm', 'reflection', 'mindfulness']
WHERE category = 'reflection' AND (tags IS NULL OR tags = '{}');

-- Ensure get_feed_candidates excludes hidden mode content
-- (existing RPC already filters by pack_name; hidden_mode content won't have free pack_name)
