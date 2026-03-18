-- Migration 012: Create ai_insights table used by the insights service.
-- The service (services/insights.js) caches Claude-generated insights here.
-- Migration 008 accidentally created a table named 'weekly_insights' — this migration
-- creates the correct table name that the service expects.

CREATE TABLE IF NOT EXISTS ai_insights (
  id           BIGSERIAL PRIMARY KEY,
  device_id    TEXT        NOT NULL UNIQUE,
  insight      TEXT        NOT NULL,
  lang         TEXT        NOT NULL DEFAULT 'en',
  generated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_insights_device ON ai_insights(device_id);
