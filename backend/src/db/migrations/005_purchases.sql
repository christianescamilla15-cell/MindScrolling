-- MindScrolling — Migration 005: Purchases v2 (MindScrolling Inside)
-- Run in Supabase SQL Editor (after 004_ai_feed.sql)
-- Idempotent — safe to run multiple times

-- 1. Add new columns to purchases
ALTER TABLE purchases
  ADD COLUMN IF NOT EXISTS store          TEXT,
  ADD COLUMN IF NOT EXISTS product_id     TEXT,
  ADD COLUMN IF NOT EXISTS purchase_token TEXT,
  ADD COLUMN IF NOT EXISTS transaction_id TEXT,
  ADD COLUMN IF NOT EXISTS status         TEXT NOT NULL DEFAULT 'pending',
  ADD COLUMN IF NOT EXISTS updated_at     TIMESTAMPTZ DEFAULT now();

-- 2. Add CHECK constraint on status
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'purchases_status_check'
      AND conrelid = 'purchases'::regclass
  ) THEN
    ALTER TABLE purchases
      ADD CONSTRAINT purchases_status_check
        CHECK (status IN ('pending', 'verified', 'failed', 'restored'));
  END IF;
END;
$$;

-- 3. Backfill status on existing legacy rows
UPDATE purchases
SET    status = 'verified'
WHERE  status = 'pending'
  AND  purchase_type IS NOT NULL
  AND  store IS NULL;

-- 4. New indexes
CREATE INDEX IF NOT EXISTS idx_purchases_device_id ON purchases(device_id);
CREATE INDEX IF NOT EXISTS idx_purchases_status    ON purchases(status);

-- 5. Add premium_since to users
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS premium_since TIMESTAMPTZ;

UPDATE users u
SET    premium_since = (
  SELECT MIN(p.created_at)
  FROM   purchases p
  WHERE  p.device_id = u.device_id
    AND  p.status    = 'verified'
)
WHERE u.is_premium    = true
  AND u.premium_since IS NULL;
