-- 045_exercises_table.sql
-- Programming exercises system for Coding Mode practice console

CREATE TABLE IF NOT EXISTS exercises (
  id                  uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Content (bilingual)
  title_en            text NOT NULL,
  title_es            text,
  description_en      text NOT NULL,
  description_es      text,

  -- Classification
  language            varchar(30) NOT NULL,
  difficulty          smallint NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
  category            varchar(60) NOT NULL,

  -- Exercise content
  starter_code        text,
  solution            text NOT NULL,
  expected_output     text,
  test_cases          jsonb DEFAULT '[]',

  -- Hints (progressive)
  hint_count          smallint NOT NULL DEFAULT 0,
  hint_1_en           text,
  hint_1_es           text,
  hint_2_en           text,
  hint_2_es           text,
  hint_3_en           text,
  hint_3_es           text,

  -- Scoring
  points              smallint DEFAULT 10,
  hints_used_penalty  smallint DEFAULT 5,
  estimated_time      smallint DEFAULT 5,

  -- Metadata
  tags                text[] DEFAULT '{}',
  created_at          timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_exercises_language ON exercises(language);
CREATE INDEX IF NOT EXISTS idx_exercises_difficulty ON exercises(difficulty);
CREATE INDEX IF NOT EXISTS idx_exercises_category ON exercises(category);
CREATE INDEX IF NOT EXISTS idx_exercises_lang_diff ON exercises(language, difficulty);

-- User progress
CREATE TABLE IF NOT EXISTS exercise_progress (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  device_id       text NOT NULL,
  exercise_id     uuid NOT NULL REFERENCES exercises(id),
  status          varchar(20) NOT NULL DEFAULT 'not_started',
  user_code       text,
  hints_used      smallint DEFAULT 0,
  attempts        smallint DEFAULT 0,
  points_earned   smallint DEFAULT 0,
  started_at      timestamptz DEFAULT now(),
  completed_at    timestamptz,
  updated_at      timestamptz DEFAULT now(),

  UNIQUE(device_id, exercise_id)
);

CREATE INDEX IF NOT EXISTS idx_exercise_progress_device ON exercise_progress(device_id);
CREATE INDEX IF NOT EXISTS idx_exercise_progress_status ON exercise_progress(device_id, status);

-- RLS
ALTER TABLE exercises ENABLE ROW LEVEL SECURITY;
CREATE POLICY exercises_read_all ON exercises FOR SELECT USING (true);

ALTER TABLE exercise_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY exercise_progress_all ON exercise_progress FOR ALL USING (true);
