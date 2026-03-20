-- Migration 021: analytics_events table
-- Persists client-side analytics events sent to POST /analytics/event.
-- Replaces pure console-log approach used during closed-testing phase.

CREATE TABLE IF NOT EXISTS analytics_events (
  id         bigserial     PRIMARY KEY,
  device_id  text          NOT NULL,
  event_type text          NOT NULL,
  properties jsonb         NOT NULL DEFAULT '{}',
  created_at timestamptz   NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_analytics_events_device_type_created
  ON analytics_events (device_id, event_type, created_at);
