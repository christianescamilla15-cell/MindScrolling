-- 026_fix_match_quotes_return_columns.sql
-- Algorithm audit fix: match_quotes RPC must return tags, content_type
-- and filter is_hidden_mode to prevent hidden content leaking into feeds.
--
-- Also fixes get_feed_candidates to exclude hidden mode content.

-- Drop and recreate match_quotes with correct return columns + hidden_mode filter
CREATE OR REPLACE FUNCTION match_quotes(
  query_embedding vector(512),
  p_device_id     uuid,
  p_lang          text,
  p_is_premium    boolean,
  p_pool_size     int
)
RETURNS TABLE (
  id              uuid,
  text            text,
  author          text,
  category        text,
  lang            text,
  swipe_dir       text,
  pack_name       text,
  is_premium      boolean,
  created_at      timestamptz,
  content_type    varchar(30),
  tags            text[],
  similarity      float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    q.id,
    q.text,
    q.author,
    q.category,
    q.lang,
    q.swipe_dir,
    q.pack_name,
    q.is_premium,
    q.created_at,
    q.content_type,
    q.tags,
    1 - (q.embedding <=> query_embedding) AS similarity
  FROM quotes q
  WHERE q.lang = p_lang
    AND q.embedding IS NOT NULL
    AND q.is_hidden_mode = false
    AND (q.pack_name = 'free' OR q.pack_name IS NULL)
    AND (p_is_premium OR q.is_premium = false)
    AND NOT EXISTS (
      SELECT 1 FROM seen_quotes s
      WHERE s.device_id = p_device_id AND s.quote_id = q.id
    )
  ORDER BY q.embedding <=> query_embedding
  LIMIT p_pool_size;
$$;

-- Fix get_feed_candidates to also exclude hidden_mode content
CREATE OR REPLACE FUNCTION get_feed_candidates(
  p_device_id  uuid,
  p_lang       text,
  p_is_premium boolean,
  p_pool_size  int
)
RETURNS SETOF quotes
LANGUAGE sql STABLE
AS $$
  SELECT q.*
  FROM quotes q
  WHERE q.lang = p_lang
    AND q.is_hidden_mode = false
    AND (q.pack_name = 'free' OR q.pack_name IS NULL)
    AND (p_is_premium OR q.is_premium = false)
    AND NOT EXISTS (
      SELECT 1 FROM seen_quotes s
      WHERE s.device_id = p_device_id AND s.quote_id = q.id
    )
  ORDER BY random()
  LIMIT p_pool_size;
$$;
