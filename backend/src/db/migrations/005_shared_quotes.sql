-- 005: Shared quotes — share quotes between friends within MindScrolling

CREATE TABLE IF NOT EXISTS shared_quotes (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_device_id  VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  to_device_id    VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  quote_id        UUID REFERENCES quotes(id) ON DELETE CASCADE,
  seen            BOOLEAN DEFAULT false,
  created_at      TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_shared_to ON shared_quotes(to_device_id, seen);
CREATE INDEX IF NOT EXISTS idx_shared_from ON shared_quotes(from_device_id);
CREATE INDEX IF NOT EXISTS idx_shared_created ON shared_quotes(created_at DESC);

-- Add display_name to users if not exists
DO $$ BEGIN
  ALTER TABLE users ADD COLUMN display_name VARCHAR(100);
EXCEPTION WHEN duplicate_column THEN NULL; END $$;
