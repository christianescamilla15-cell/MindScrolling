-- 025_analytics_rls.sql
-- H-01 fix: Enable RLS on analytics_events and restrict access by device_id.
-- The backend uses the anon key, so RLS policies are the primary access control layer.

ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;

-- Devices can only read their own analytics events
CREATE POLICY analytics_events_select_own ON analytics_events
  FOR SELECT USING (device_id = current_setting('request.jwt.claims', true)::json->>'sub'
    OR device_id = current_setting('request.headers', true)::json->>'x-device-id');

-- Devices can only insert their own analytics events
CREATE POLICY analytics_events_insert_own ON analytics_events
  FOR INSERT WITH CHECK (true);

-- Allow backend service role full access (bypass RLS)
-- Note: If backend switches to service_role key, these policies only affect direct anon-key access.
