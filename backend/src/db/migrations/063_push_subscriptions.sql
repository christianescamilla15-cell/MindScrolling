-- 063: Web Push subscriptions
-- Stores per-device PushSubscription objects so the server can deliver
-- daily reminders, weekly map notifications, and "new follower" pings.

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id       VARCHAR(100) REFERENCES users(device_id) ON DELETE CASCADE,
  endpoint        TEXT NOT NULL,
  p256dh          TEXT NOT NULL,
  auth            TEXT NOT NULL,
  user_agent      TEXT,
  created_at      TIMESTAMPTZ DEFAULT now(),
  last_seen_at    TIMESTAMPTZ DEFAULT now(),
  UNIQUE(device_id, endpoint)
);

CREATE INDEX IF NOT EXISTS idx_push_sub_device ON push_subscriptions(device_id);
CREATE INDEX IF NOT EXISTS idx_push_sub_last_seen ON push_subscriptions(last_seen_at DESC);
