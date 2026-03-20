-- Migration 020: Atomic challenge progress increment
--
-- Fixes TOCTOU race condition in POST /challenges/:id/progress.
-- Previously the endpoint read progress, computed new value in JS, then upserted.
-- Concurrent requests could read the same old value and lose increments.
--
-- This RPC does the increment atomically in a single SQL statement.

CREATE OR REPLACE FUNCTION increment_challenge_progress(
  p_device_id    TEXT,
  p_challenge_id BIGINT,
  p_count        INT,
  p_target       INT
)
RETURNS TABLE(progress INT, completed BOOLEAN)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO challenge_progress (device_id, challenge_id, progress, completed, updated_at)
  VALUES (
    p_device_id,
    p_challenge_id,
    LEAST(p_count, p_target),
    LEAST(p_count, p_target) >= p_target,
    now()
  )
  ON CONFLICT (device_id, challenge_id) DO UPDATE
    SET progress   = LEAST(challenge_progress.progress + p_count, p_target),
        completed  = LEAST(challenge_progress.progress + p_count, p_target) >= p_target,
        updated_at = now()
  WHERE NOT challenge_progress.completed;

  RETURN QUERY
    SELECT cp.progress::INT, cp.completed
    FROM challenge_progress cp
    WHERE cp.device_id = p_device_id AND cp.challenge_id = p_challenge_id;
END;
$$;
