-- MindScrolling — Migration 004: AI-Enhanced Feed
-- Adds semantic vector search (pgvector) + AI insight caching
-- Run in Supabase SQL Editor (after 003_feed_algorithm.sql)
-- Idempotent — safe to run multiple times

-- ─── 0. Backfill missing columns (if quotes table predates 001_initial v2) ────
ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS pack_name  VARCHAR(50) NOT NULL DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS is_premium BOOLEAN     NOT NULL DEFAULT false;

-- ─── 1. Enable pgvector extension ────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS vector;

-- ─── 2. Add embedding column to quotes ───────────────────────────────────────
-- voyage-3-lite produces 512-dim vectors (fast, cost-efficient, excellent recall)
ALTER TABLE quotes
  ADD COLUMN IF NOT EXISTS embedding VECTOR(512);

COMMENT ON COLUMN quotes.embedding IS 'Semantic embedding via Voyage AI voyage-3-lite (512 dims). NULL until embed_quotes.js script runs.';

-- ─── 3. HNSW index for approximate nearest-neighbour search ──────────────────
-- HNSW outperforms IVFFlat: no list pre-creation, incremental insert, ~10ms recall
-- Only index rows with embeddings (partial index saves space during rollout)
CREATE INDEX IF NOT EXISTS idx_quotes_embedding_hnsw
  ON quotes USING hnsw (embedding vector_cosine_ops)
  WITH (m = 16, ef_construction = 64)
  WHERE embedding IS NOT NULL;

-- ─── 4. User preference vectors ──────────────────────────────────────────────
-- Stores the rolling weighted-average embedding for each device.
-- Updated asynchronously on like, vault save, and long dwell (≥ 5 s).
CREATE TABLE IF NOT EXISTS user_preference_vectors (
  device_id     VARCHAR(100) PRIMARY KEY REFERENCES users(device_id) ON DELETE CASCADE,
  vector        VECTOR(512) NOT NULL,
  signal_count  INT     NOT NULL DEFAULT 0,   -- total high-signal events used to build this vector
  updated_at    TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE user_preference_vectors IS 'Per-device semantic preference vector (EMA of high-signal quote embeddings).';

-- ─── 5. AI insight cache ─────────────────────────────────────────────────────
-- Stores Claude-generated weekly insights. Generated at most once per 24 h per device.
CREATE TABLE IF NOT EXISTS ai_insights (
  device_id    VARCHAR(100) PRIMARY KEY REFERENCES users(device_id) ON DELETE CASCADE,
  insight      TEXT NOT NULL,
  generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  context_hash VARCHAR(64)          -- SHA-256 of context used to generate; detect stale insights
);

COMMENT ON TABLE ai_insights IS 'Cached Claude-generated weekly philosophy insights per device.';

-- ─── 6. RPC: match_quotes (semantic retrieval) ───────────────────────────────
-- Returns unseen quotes ordered by cosine similarity to a query embedding.
-- Replaces get_feed_candidates when the device has a preference vector.
-- Returns similarity score so the Node.js layer can compute hybrid scores.

DROP FUNCTION IF EXISTS match_quotes(VECTOR, TEXT, TEXT, BOOLEAN, INT);

CREATE OR REPLACE FUNCTION match_quotes(
  query_embedding VECTOR(512),
  p_device_id     TEXT,
  p_lang          TEXT,
  p_is_premium    BOOLEAN,
  p_pool_size     INT
)
RETURNS TABLE (
  id          UUID,
  text        TEXT,
  author      VARCHAR(150),
  category    VARCHAR(50),
  lang        CHAR(2),
  swipe_dir   VARCHAR(10),
  pack_name   VARCHAR(50),
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
    AND NOT EXISTS (
      SELECT 1
      FROM   seen_quotes sq
      WHERE  sq.device_id = p_device_id
        AND  sq.quote_id  = q.id
    )
  ORDER BY q.embedding <=> query_embedding
  LIMIT p_pool_size;
$$;

-- ─── 7. RPC: upsert_preference_vector ────────────────────────────────────────
-- Atomically updates the user's preference vector using exponential moving average.
-- α (alpha) = learning rate, passed by caller based on signal strength.

DROP FUNCTION IF EXISTS upsert_preference_vector(TEXT, VECTOR, FLOAT);

CREATE OR REPLACE FUNCTION upsert_preference_vector(
  p_device_id TEXT,
  p_new_vec   VECTOR(512),
  p_alpha     FLOAT          -- learning rate: 0.25 (vault/like), 0.10 (dwell)
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  current_vec  VECTOR(512);
  blended_vec  VECTOR(512);
BEGIN
  SELECT vector INTO current_vec
  FROM   user_preference_vectors
  WHERE  device_id = p_device_id;

  IF current_vec IS NULL THEN
    -- First signal: initialise directly from this quote's embedding
    INSERT INTO user_preference_vectors (device_id, vector, signal_count, updated_at)
    VALUES (p_device_id, p_new_vec, 1, now())
    ON CONFLICT (device_id)
    DO UPDATE SET
      vector       = EXCLUDED.vector,
      signal_count = user_preference_vectors.signal_count + 1,
      updated_at   = now();
  ELSE
    -- EMA blend: new = (1-α) × current + α × incoming
    -- pgvector arithmetic: scalar multiply + add, then L2-normalise
    blended_vec := (1.0 - p_alpha) * current_vec + p_alpha * p_new_vec;

    UPDATE user_preference_vectors
    SET
      vector       = l2_normalize(blended_vec),
      signal_count = signal_count + 1,
      updated_at   = now()
    WHERE device_id = p_device_id;
  END IF;
END;
$$;
