-- Migration 016: Add composite index on swipe_events(device_id, created_at)
-- Required by GET /stats today_swipes query which filters by device + date range.
-- Without this index, the query does a full table scan filtered only by device_id.

CREATE INDEX IF NOT EXISTS idx_swipe_events_device_date
  ON swipe_events(device_id, created_at DESC);
