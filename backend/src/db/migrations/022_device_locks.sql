-- 022: Device lock table — restrict app to a single physical device
CREATE TABLE IF NOT EXISTS device_locks (
  device_id   text PRIMARY KEY,
  hardware_id text NOT NULL UNIQUE,
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE device_locks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "anon_insert_own" ON device_locks
  FOR INSERT WITH CHECK (true);

CREATE POLICY "anon_select_all" ON device_locks
  FOR SELECT USING (true);
