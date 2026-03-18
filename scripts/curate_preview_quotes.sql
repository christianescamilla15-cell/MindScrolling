-- ============================================================
-- MindScrolling — curate_preview_quotes.sql
-- Block A Task 2: Designate 15 preview quotes per pack per lang.
-- 6 combinations = 90 quotes total.
-- Rank 1–5:  shown to Free users (highest impact, shortest).
-- Rank 6–15: shown to Trial users (very good, author variety).
-- Criteria: <150 chars, maximum impact, author variety per pack.
-- Safe to re-run — resets all preview flags before re-applying.
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- STEP 0: Reset all existing preview designations
-- Keeps the slate clean so re-runs are idempotent.
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET is_pack_preview = false,
    pack_preview_rank = NULL
WHERE is_pack_preview = true;

-- ============================================================
-- PACK: stoicism_deep | LANG: en
-- ============================================================

-- Rank 1: Marcus Aurelius — the anchor quote of all Stoicism
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 1
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Marcus Aurelius'
  AND text ILIKE 'You have power over your mind%';

-- Rank 2: Epictetus — dichotomy of control (short, devastating)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 2
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Epictetus'
  AND text ILIKE 'It''s not what happens to you%';

-- Rank 3: Seneca — "We suffer more in imagination"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 3
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Seneca'
  AND text ILIKE 'We suffer more in imagination%';

-- Rank 4: Marcus Aurelius — "Waste no more time arguing"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 4
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Marcus Aurelius'
  AND text ILIKE 'Waste no more time arguing%';

-- Rank 5: Epictetus — "No man is free who is not master of himself"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 5
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Epictetus'
  AND text ILIKE 'No man is free who is not master%';

-- Rank 6: Marcus Aurelius — "The impediment to action advances action"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 6
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Marcus Aurelius'
  AND text ILIKE 'The impediment to action advances%';

-- Rank 7: Seneca — "Luck is what happens when preparation meets opportunity"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 7
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Seneca'
  AND text ILIKE 'Luck is what happens when preparation%';

-- Rank 8: Marcus Aurelius — "The happiness of your life depends on the quality of your thoughts"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 8
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Marcus Aurelius'
  AND text ILIKE 'The happiness of your life depends%';

-- Rank 9: Epictetus — "Wealth consists not in having great possessions"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 9
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Epictetus'
  AND text ILIKE 'Wealth consists not in having great possessions%';

-- Rank 10: Seneca — "He who is brave is free"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 10
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Seneca'
  AND text ILIKE 'He who is brave is free%';

-- Rank 11: Zeno of Citium — "Man conquers the world by conquering himself"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 11
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Zeno of Citium'
  AND text ILIKE 'Man conquers the world by conquering himself%';

-- Rank 12: Epictetus — "People are not disturbed by things, but by the view they take of them"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 12
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Epictetus'
  AND text ILIKE 'People are not disturbed by things%';

-- Rank 13: Seneca — "While we are postponing, life speeds by"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 13
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Seneca'
  AND text ILIKE 'While we are postponing%';

-- Rank 14: Cleanthes — "Fate leads the willing and drags along the reluctant"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 14
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Cleanthes'
  AND text ILIKE 'Fate leads the willing%';

-- Rank 15: Heraclitus — "Character is destiny"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 15
WHERE pack_name = 'stoicism_deep' AND lang = 'en'
  AND author = 'Heraclitus'
  AND text ILIKE 'Character is destiny%';

-- ============================================================
-- PACK: stoicism_deep | LANG: es
-- Same quotes, Spanish equivalents. Text match uses translated text.
-- ============================================================

-- Rank 1: Marcus Aurelius — "Tienes poder sobre tu mente"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 1
WHERE pack_name = 'stoicism_deep' AND lang = 'es'
  AND author = 'Marcus Aurelius'
  AND (text ILIKE 'Tienes poder sobre tu mente%'
       OR text ILIKE 'Tú tienes poder sobre tu mente%'
       OR text ILIKE 'Tienes control sobre tu mente%');

-- Rank 2: Epictetus — "No es lo que te pasa"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 2
WHERE pack_name = 'stoicism_deep' AND lang = 'es'
  AND author = 'Epictetus'
  AND (text ILIKE 'No es lo que te pasa%'
       OR text ILIKE 'No importa lo que ocurra%'
       OR text ILIKE 'No es lo que sucede%');

-- Rank 3: Seneca — "Sufrimos más en la imaginación"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 3
WHERE pack_name = 'stoicism_deep' AND lang = 'es'
  AND author = 'Seneca'
  AND (text ILIKE 'Sufrimos más en la imaginación%'
       OR text ILIKE 'Sufrimos más por imaginación%');

-- Rank 4: Marcus Aurelius — "No pierdas más tiempo discutiendo"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 4
WHERE pack_name = 'stoicism_deep' AND lang = 'es'
  AND author = 'Marcus Aurelius'
  AND (text ILIKE 'No pierdas más tiempo%'
       OR text ILIKE 'Deja de perder el tiempo%');

-- Rank 5: Epictetus — "Ningún hombre es libre si no es dueño de sí mismo"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 5
WHERE pack_name = 'stoicism_deep' AND lang = 'es'
  AND author = 'Epictetus'
  AND (text ILIKE 'Ningún hombre es libre%'
       OR text ILIKE 'No es libre quien no se domina%');

-- Ranks 6–15: ES stoicism_deep — assign by quality to remaining stoic authors
-- Use a ranked subquery to fill remaining slots deterministically.
WITH ranked AS (
  SELECT id,
    ROW_NUMBER() OVER (
      PARTITION BY author
      ORDER BY LENGTH(text) ASC
    ) AS author_rank,
    ROW_NUMBER() OVER (
      ORDER BY
        CASE author
          WHEN 'Marcus Aurelius'    THEN 1
          WHEN 'Seneca'             THEN 2
          WHEN 'Epictetus'          THEN 3
          WHEN 'Zeno of Citium'     THEN 4
          WHEN 'Cleanthes'          THEN 5
          WHEN 'Chrysippus'         THEN 6
          WHEN 'Heraclitus'         THEN 7
          ELSE 8
        END,
        LENGTH(text) ASC
    ) AS overall_rank
  FROM quotes
  WHERE pack_name = 'stoicism_deep'
    AND lang = 'es'
    AND is_pack_preview = false
    AND LENGTH(text) < 150
    AND author IN (
      'Marcus Aurelius','Seneca','Seneca the Younger','Epictetus',
      'Zeno of Citium','Cleanthes','Chrysippus','Heraclitus','Epicurus'
    )
)
UPDATE quotes
SET is_pack_preview = true,
    pack_preview_rank = ranked.overall_rank + 5
FROM ranked
WHERE quotes.id = ranked.id
  AND ranked.overall_rank BETWEEN 1 AND 10
  AND quotes.is_pack_preview = false;

-- ============================================================
-- PACK: existentialism | LANG: en
-- ============================================================

-- Rank 1: Camus — "In the midst of winter, I found there was, within me, an invincible summer"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 1
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Albert Camus'
  AND text ILIKE 'In the midst of winter%invincible summer%';

-- Rank 2: Sartre — "Existence precedes essence"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 2
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Jean-Paul Sartre'
  AND text ILIKE 'Existence precedes essence%';

-- Rank 3: Nietzsche — "He who has a why to live can bear almost any how"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 3
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Friedrich Nietzsche'
  AND text ILIKE 'He who has a why to live%';

-- Rank 4: Camus — "One must imagine Sisyphus happy"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 4
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Albert Camus'
  AND text ILIKE 'One must imagine Sisyphus happy%';

-- Rank 5: Nietzsche — "That which does not kill us makes us stronger"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 5
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Friedrich Nietzsche'
  AND text ILIKE 'That which does not kill us%';

-- Rank 6: Sartre — "Man is condemned to be free"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 6
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Jean-Paul Sartre'
  AND text ILIKE 'Man is condemned to be free%';

-- Rank 7: Nietzsche — "One must still have chaos in oneself to give birth to a dancing star"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 7
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Friedrich Nietzsche'
  AND text ILIKE 'One must still have chaos in oneself%';

-- Rank 8: Camus — "There is but one truly serious philosophical problem, and that is suicide"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 8
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Albert Camus'
  AND text ILIKE 'There is but one truly serious philosophical problem%';

-- Rank 9: Kierkegaard — top quality quote (assigned by quality fallback)
WITH ks AS (
  SELECT id FROM quotes
  WHERE pack_name = 'existentialism' AND lang = 'en'
    AND author IN ('Søren Kierkegaard','Soren Kierkegaard')
    AND is_pack_preview = false
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 9
FROM ks WHERE quotes.id = ks.id;

-- Rank 10: de Beauvoir — top quality quote
WITH sdb AS (
  SELECT id FROM quotes
  WHERE pack_name = 'existentialism' AND lang = 'en'
    AND author = 'Simone de Beauvoir'
    AND is_pack_preview = false
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 10
FROM sdb WHERE quotes.id = sdb.id;

-- Rank 11: Viktor Frankl — top quality quote
WITH vf AS (
  SELECT id FROM quotes
  WHERE pack_name = 'existentialism' AND lang = 'en'
    AND author = 'Viktor Frankl'
    AND is_pack_preview = false
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 11
FROM vf WHERE quotes.id = vf.id;

-- Rank 12: Nietzsche — "Without music, life would be a mistake"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 12
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Friedrich Nietzsche'
  AND text ILIKE 'Without music, life would be a mistake%'
  AND is_pack_preview = false;

-- Rank 13: Dostoevsky — top quality quote
WITH fd AS (
  SELECT id FROM quotes
  WHERE pack_name = 'existentialism' AND lang = 'en'
    AND author = 'Fyodor Dostoevsky'
    AND is_pack_preview = false
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 13
FROM fd WHERE quotes.id = fd.id;

-- Rank 14: Hannah Arendt — top quality quote
WITH ha AS (
  SELECT id FROM quotes
  WHERE pack_name = 'existentialism' AND lang = 'en'
    AND author = 'Hannah Arendt'
    AND is_pack_preview = false
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 14
FROM ha WHERE quotes.id = ha.id;

-- Rank 15: Sartre — "Hell is other people"
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 15
WHERE pack_name = 'existentialism' AND lang = 'en'
  AND author = 'Jean-Paul Sartre'
  AND text ILIKE 'Hell is other people%'
  AND is_pack_preview = false;

-- ============================================================
-- PACK: existentialism | LANG: es
-- Mirror of EN using quality-ranked fallback for all 15 slots.
-- Ensures author variety across Sartre, Camus, Nietzsche, Kierkegaard, de Beauvoir.
-- ============================================================

WITH existential_es AS (
  SELECT id,
    ROW_NUMBER() OVER (
      ORDER BY
        CASE author
          WHEN 'Albert Camus'       THEN 1
          WHEN 'Jean-Paul Sartre'   THEN 2
          WHEN 'Friedrich Nietzsche' THEN 3
          WHEN 'Søren Kierkegaard'  THEN 4
          WHEN 'Soren Kierkegaard'  THEN 4
          WHEN 'Simone de Beauvoir' THEN 5
          WHEN 'Viktor Frankl'      THEN 6
          WHEN 'Fyodor Dostoevsky'  THEN 7
          WHEN 'Hannah Arendt'      THEN 8
          ELSE 9
        END,
        LENGTH(text) ASC,
        LENGTH(text) ASC
    ) AS slot
  FROM (
    SELECT DISTINCT ON (author) id, author, LENGTH(text) AS quality_score, text
    FROM quotes
    WHERE pack_name = 'existentialism'
      AND lang = 'es'
      AND LENGTH(text) < 180
    ORDER BY author, LENGTH(text) ASC
  ) best_per_author
),
additional_es AS (
  SELECT id,
    ROW_NUMBER() OVER (ORDER BY LENGTH(text) ASC) + 8 AS slot
  FROM quotes
  WHERE pack_name = 'existentialism'
    AND lang = 'es'
    AND LENGTH(text) < 150
    AND id NOT IN (SELECT id FROM existential_es WHERE slot <= 8)
  LIMIT 7
)
UPDATE quotes
SET is_pack_preview = true,
    pack_preview_rank = combined.slot
FROM (
  SELECT id, slot FROM existential_es WHERE slot <= 8
  UNION ALL
  SELECT id, slot FROM additional_es WHERE slot <= 15
) combined
WHERE quotes.id = combined.id
  AND quotes.pack_name = 'existentialism'
  AND quotes.lang = 'es';

-- ============================================================
-- PACK: zen_mindfulness | LANG: en
-- ============================================================

-- Rank 1: Thích Nhất Hạnh — most recognizable zen quote
WITH tnh AS (
  SELECT id FROM quotes
  WHERE pack_name = 'zen_mindfulness' AND lang = 'en'
    AND author IN ('Thích Nhất Hạnh','Thich Nhat Hanh')
    AND LENGTH(text) < 150
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 1
FROM tnh WHERE quotes.id = tnh.id;

-- Rank 2: Lao Tzu — the core of Taoism
WITH ltz AS (
  SELECT id FROM quotes
  WHERE pack_name = 'zen_mindfulness' AND lang = 'en'
    AND author = 'Lao Tzu'
    AND LENGTH(text) < 120
    AND is_pack_preview = false
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 2
FROM ltz WHERE quotes.id = ltz.id;

-- Rank 3: Rumi — most-loved mystical quote
WITH rm AS (
  SELECT id FROM quotes
  WHERE pack_name = 'zen_mindfulness' AND lang = 'en'
    AND author = 'Rumi'
    AND LENGTH(text) < 150
    AND is_pack_preview = false
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 3
FROM rm WHERE quotes.id = rm.id;

-- Rank 4: Alan Watts — consciousness/presence
WITH aw AS (
  SELECT id FROM quotes
  WHERE pack_name = 'zen_mindfulness' AND lang = 'en'
    AND author = 'Alan Watts'
    AND LENGTH(text) < 150
    AND is_pack_preview = false
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 4
FROM aw WHERE quotes.id = aw.id;

-- Rank 5: Buddha / The Buddha — impermanence
WITH bdh AS (
  SELECT id FROM quotes
  WHERE pack_name = 'zen_mindfulness' AND lang = 'en'
    AND author IN ('Buddha','The Buddha','Dhammapada')
    AND LENGTH(text) < 130
    AND is_pack_preview = false
  ORDER BY LENGTH(text) ASC
  LIMIT 1
)
UPDATE quotes SET is_pack_preview = true, pack_preview_rank = 5
FROM bdh WHERE quotes.id = bdh.id;

-- Ranks 6–15: fill remaining slots with best quotes by varied zen authors
WITH zen_en_pool AS (
  SELECT id,
    ROW_NUMBER() OVER (
      ORDER BY
        CASE author
          WHEN 'Eckhart Tolle'       THEN 1
          WHEN 'Dalai Lama'          THEN 2
          WHEN 'Pema Chödrön'        THEN 3
          WHEN 'Zhuang Zhou'         THEN 4
          WHEN 'Kahlil Gibran'       THEN 5
          WHEN 'Rabindranath Tagore' THEN 6
          WHEN 'Daisaku Ikeda'       THEN 7
          WHEN 'Eknath Easwaran'     THEN 8
          ELSE 9
        END,
        LENGTH(text) ASC,
        LENGTH(text) ASC
    ) AS slot
  FROM (
    SELECT DISTINCT ON (author) id, author, LENGTH(text) AS quality_score, text
    FROM quotes
    WHERE pack_name = 'zen_mindfulness'
      AND lang = 'en'
      AND is_pack_preview = false
      AND LENGTH(text) < 160
    ORDER BY author, LENGTH(text) ASC
  ) best_per_author
)
UPDATE quotes
SET is_pack_preview = true,
    pack_preview_rank = zen_en_pool.slot + 5
FROM zen_en_pool
WHERE quotes.id = zen_en_pool.id
  AND zen_en_pool.slot BETWEEN 1 AND 10
  AND quotes.is_pack_preview = false;

-- ============================================================
-- PACK: zen_mindfulness | LANG: es
-- ============================================================

WITH zen_es AS (
  SELECT id,
    ROW_NUMBER() OVER (
      ORDER BY
        CASE author
          WHEN 'Thích Nhất Hạnh'    THEN 1
          WHEN 'Thich Nhat Hanh'    THEN 1
          WHEN 'Lao Tzu'            THEN 2
          WHEN 'Rumi'               THEN 3
          WHEN 'Alan Watts'         THEN 4
          WHEN 'Buddha'             THEN 5
          WHEN 'The Buddha'         THEN 5
          WHEN 'Eckhart Tolle'      THEN 6
          WHEN 'Dalai Lama'         THEN 7
          WHEN 'Kahlil Gibran'      THEN 8
          WHEN 'Rabindranath Tagore' THEN 9
          ELSE 10
        END,
        LENGTH(text) ASC,
        LENGTH(text) ASC
    ) AS slot
  FROM (
    SELECT DISTINCT ON (author) id, author, LENGTH(text) AS quality_score, text
    FROM quotes
    WHERE pack_name = 'zen_mindfulness'
      AND lang = 'es'
      AND LENGTH(text) < 180
    ORDER BY author, LENGTH(text) ASC
  ) best_per_author
),
zen_es_extra AS (
  SELECT id,
    ROW_NUMBER() OVER (ORDER BY LENGTH(text) ASC) + (
      SELECT COUNT(*) FROM zen_es WHERE slot <= 15
    ) AS slot
  FROM quotes
  WHERE pack_name = 'zen_mindfulness'
    AND lang = 'es'
    AND LENGTH(text) < 150
    AND id NOT IN (SELECT id FROM zen_es WHERE slot <= 15)
    AND is_pack_preview = false
  LIMIT 5
)
UPDATE quotes
SET is_pack_preview = true,
    pack_preview_rank = combined.slot
FROM (
  SELECT id, slot FROM zen_es WHERE slot <= 15
  UNION ALL
  SELECT id, slot FROM zen_es_extra
) combined
WHERE quotes.id = combined.id
  AND quotes.pack_name = 'zen_mindfulness'
  AND quotes.lang = 'es'
  AND combined.slot <= 15;

-- ──────────────────────────────────────────────────────────────
-- VERIFICATION: Run after to confirm 15 per pack per lang
-- ──────────────────────────────────────────────────────────────
/*
SELECT
  pack_name,
  lang,
  COUNT(*)                                        AS total_previews,
  COUNT(*) FILTER (WHERE pack_preview_rank <= 5)  AS free_tier,
  COUNT(*) FILTER (WHERE pack_preview_rank > 5)   AS trial_tier
FROM quotes
WHERE is_pack_preview = true
GROUP BY pack_name, lang
ORDER BY pack_name, lang;
*/

-- Expected output:
-- pack_name        | lang | total_previews | free_tier | trial_tier
-- existentialism   | en   | 15             | 5         | 10
-- existentialism   | es   | 15             | 5         | 10
-- stoicism_deep    | en   | 15             | 5         | 10
-- stoicism_deep    | es   | 15             | 5         | 10
-- zen_mindfulness  | en   | 15             | 5         | 10
-- zen_mindfulness  | es   | 15             | 5         | 10
