-- Migration 015: Add pack_name filter to match_quotes RPC.
-- Without this filter, semantic feed (vector-based) returns pack quotes
-- to free users, bypassing Block B monetization.
-- Mirror of the fix applied to get_feed_candidates in migration 011.

DROP FUNCTION IF EXISTS match_quotes(VECTOR, TEXT, TEXT, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION match_quotes(
  query_embedding VECTOR(512),
  p_device_id     TEXT,
  p_lang          TEXT      DEFAULT 'en',
  p_is_premium    BOOLEAN   DEFAULT false,
  p_pool_size     INT       DEFAULT 160
)
RETURNS TABLE (
  id          UUID,
  text        TEXT,
  author      TEXT,
  category    TEXT,
  lang        TEXT,
  swipe_dir   TEXT,
  pack_name   TEXT,
  is_premium  BOOLEAN,
  created_at  TIMESTAMPTZ,
  similarity  FLOAT
)
LANGUAGE sql
STABLE
SECURITY DEFINER
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
    1 - (q.embedding <=> query_embedding) AS similarity
  FROM quotes q
  WHERE q.lang       = p_lang
    AND q.embedding IS NOT NULL
    AND (p_is_premium = true OR q.is_premium = false)
    AND (q.pack_name = 'free' OR q.pack_name IS NULL)
    AND NOT EXISTS (
      SELECT 1
      FROM   seen_quotes sq
      WHERE  sq.device_id = p_device_id
        AND  sq.quote_id  = q.id
    )
  ORDER BY q.embedding <=> query_embedding
  LIMIT p_pool_size;
$$;
