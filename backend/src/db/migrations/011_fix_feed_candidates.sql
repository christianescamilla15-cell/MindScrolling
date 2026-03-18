-- Migration 011: Exclude pack-exclusive quotes from free feed
--
-- Bug: get_feed_candidates() returned ALL quotes regardless of pack_name,
-- meaning paid pack content (stoicism_deep, existentialism, zen_mindfulness)
-- was reachable in the free main feed without purchase or Inside status.
--
-- Fix: add a filter so only quotes with pack_name = 'free' or NULL are
-- returned. Pack quotes (pack_name IN known packs) are served exclusively
-- through GET /packs/:id/feed which enforces entitlement.

DROP FUNCTION IF EXISTS get_feed_candidates(TEXT, TEXT, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION get_feed_candidates(
  p_device_id  TEXT,
  p_lang       TEXT,
  p_is_premium BOOLEAN,
  p_pool_size  INT
)
RETURNS SETOF quotes
LANGUAGE sql STABLE SECURITY DEFINER AS $$
  SELECT q.*
  FROM quotes q
  WHERE q.lang = p_lang
    AND (p_is_premium = true OR q.is_premium = false)
    AND (q.pack_name = 'free' OR q.pack_name IS NULL)
    AND NOT EXISTS (
      SELECT 1 FROM seen_quotes sq
      WHERE sq.device_id = p_device_id AND sq.quote_id = q.id
    )
  LIMIT p_pool_size;
$$;
