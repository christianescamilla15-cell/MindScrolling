-- MindScrolling — Migration 006: Premium Activation Codes
-- Run in Supabase SQL Editor (after 005_purchases.sql)
-- Idempotent — safe to run multiple times

-- ─── 1. Extend users table with premium status fields ─────────────────────────
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS premium_status TEXT DEFAULT 'free',
  ADD COLUMN IF NOT EXISTS premium_source TEXT,
  ADD COLUMN IF NOT EXISTS premium_activated_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS trial_start_date TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS trial_end_date TIMESTAMPTZ;

-- Add CHECK constraints idempotently
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_premium_status_check'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_premium_status_check
        CHECK (premium_status IN ('free', 'trial', 'premium_onetime', 'premium_lifetime'));
  END IF;
END;
$$;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'users_premium_source_check'
  ) THEN
    ALTER TABLE users
      ADD CONSTRAINT users_premium_source_check
        CHECK (premium_source IN ('play_billing', 'donation_manual', 'admin_grant', 'activation_code'));
  END IF;
END;
$$;

-- Backfill existing premium users
UPDATE users
SET    premium_status = 'premium_onetime',
       premium_source = 'play_billing'
WHERE  is_premium = true
  AND  premium_status = 'free';

-- ─── 2. Premium activation codes table ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS premium_activation_codes (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code           TEXT UNIQUE NOT NULL,
  type           TEXT NOT NULL DEFAULT 'lifetime',
  created_by     TEXT DEFAULT 'admin',
  assigned_email TEXT,
  notes          TEXT,
  is_redeemed    BOOLEAN DEFAULT false,
  redeemed_by    TEXT,
  redeemed_at    TIMESTAMPTZ,
  expires_at     TIMESTAMPTZ,
  revoked        BOOLEAN DEFAULT false,
  created_at     TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_codes_code ON premium_activation_codes(code);
CREATE INDEX IF NOT EXISTS idx_codes_redeemed ON premium_activation_codes(is_redeemed);

-- ─── 3. Premium audit log ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS premium_audit_log (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id   TEXT,
  event_type  TEXT NOT NULL,
  source      TEXT,
  metadata    JSONB DEFAULT '{}',
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_audit_device ON premium_audit_log(device_id);
CREATE INDEX IF NOT EXISTS idx_audit_event ON premium_audit_log(event_type);
