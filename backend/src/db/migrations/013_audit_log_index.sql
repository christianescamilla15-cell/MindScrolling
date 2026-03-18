-- Migration 013: Composite index on premium_audit_log for dedup SELECT
-- (renamed from 011_audit_log_index.sql which conflicted with 011_fix_feed_candidates.sql)
-- The trial_expired dedup query filters on (device_id, event_type) on every
-- status check for expired-trial users. A composite index avoids a heap-filter
-- step after the device_id index scan.

CREATE INDEX IF NOT EXISTS idx_premium_audit_log_device_event
  ON premium_audit_log (device_id, event_type);
