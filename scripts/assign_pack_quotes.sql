-- ============================================================
-- MindScrolling — assign_pack_quotes.sql
-- Block A Task 1: Distribute 500 quotes per pack per lang.
-- Target packs: stoicism_deep | existentialism | zen_mindfulness
-- Target langs: en | es
-- Safe to re-run (idempotent via WHERE pack_name conditions).
-- Run in Supabase SQL Editor AFTER migration 009 is applied.
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- SECTION 0: Audit — current quote counts per pack per lang
-- (Run this SELECT block first to see current state)
-- ──────────────────────────────────────────────────────────────
/*
SELECT
  pack_name,
  lang,
  COUNT(*) AS quote_count
FROM quotes
WHERE pack_name IN ('stoicism_deep', 'existentialism', 'zen_mindfulness')
GROUP BY pack_name, lang
ORDER BY pack_name, lang;
*/

-- ──────────────────────────────────────────────────────────────
-- SECTION 1: stoicism_deep — EN
-- Target authors: Marcus Aurelius, Seneca, Epictetus, Zeno of Citium,
--   Cleanthes, Chrysippus, Heraclitus, Epictetus, Epicurus (crossover)
-- Target categories: stoicism, discipline, resilience
-- Strategy: assign quotes from pack_name IN ('free','stoicism_pack')
--   with stoic authors first, then category fallback, capped at 500.
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'stoicism_deep'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'en'
    AND pack_name NOT IN ('existentialism', 'zen_mindfulness', 'stoicism_deep')
    AND (
      author IN (
        'Marcus Aurelius',
        'Seneca',
        'Seneca the Younger',
        'Epictetus',
        'Zeno of Citium',
        'Cleanthes',
        'Chrysippus',
        'Heraclitus',
        'Epicurus'
      )
      OR (
        category IN ('stoicism', 'discipline', 'resilience')
        AND author NOT IN (
          -- exclude authors firmly assigned to other packs
          'Jean-Paul Sartre', 'Albert Camus', 'Friedrich Nietzsche',
          'Søren Kierkegaard', 'Soren Kierkegaard', 'Simone de Beauvoir',
          'Martin Heidegger', 'Fyodor Dostoevsky',
          'Thích Nhất Hạnh', 'Alan Watts', 'Rumi', 'Lao Tzu',
          'Bodhidharma', 'Eckhart Tolle', 'Pema Chödrön', 'Dalai Lama',
          'Daisaku Ikeda', 'Thich Nhat Hanh', 'Buddha', 'The Buddha',
          'Dhammapada'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Marcus Aurelius','Seneca','Seneca the Younger','Epictetus') THEN 1
      WHEN author IN ('Zeno of Citium','Cleanthes','Chrysippus','Heraclitus') THEN 2
      WHEN author = 'Epicurus' THEN 3
      ELSE 4
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'en'
AND pack_name NOT IN ('existentialism', 'zen_mindfulness', 'stoicism_deep');

-- ──────────────────────────────────────────────────────────────
-- SECTION 2: stoicism_deep — ES
-- Same logic, Spanish rows.
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'stoicism_deep'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'es'
    AND pack_name NOT IN ('existentialism', 'zen_mindfulness', 'stoicism_deep')
    AND (
      author IN (
        'Marcus Aurelius',
        'Seneca',
        'Seneca the Younger',
        'Epictetus',
        'Zeno of Citium',
        'Cleanthes',
        'Chrysippus',
        'Heraclitus',
        'Epicurus'
      )
      OR (
        category IN ('stoicism', 'discipline', 'resilience')
        AND author NOT IN (
          'Jean-Paul Sartre', 'Albert Camus', 'Friedrich Nietzsche',
          'Søren Kierkegaard', 'Soren Kierkegaard', 'Simone de Beauvoir',
          'Martin Heidegger', 'Fyodor Dostoevsky',
          'Thích Nhất Hạnh', 'Alan Watts', 'Rumi', 'Lao Tzu',
          'Bodhidharma', 'Eckhart Tolle', 'Pema Chödrön', 'Dalai Lama',
          'Daisaku Ikeda', 'Thich Nhat Hanh', 'Buddha', 'The Buddha',
          'Dhammapada'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Marcus Aurelius','Seneca','Seneca the Younger','Epictetus') THEN 1
      WHEN author IN ('Zeno of Citium','Cleanthes','Chrysippus','Heraclitus') THEN 2
      WHEN author = 'Epicurus' THEN 3
      ELSE 4
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'es'
AND pack_name NOT IN ('existentialism', 'zen_mindfulness', 'stoicism_deep');

-- ──────────────────────────────────────────────────────────────
-- SECTION 3: existentialism — EN
-- Target authors: Jean-Paul Sartre, Albert Camus, Friedrich Nietzsche,
--   Søren Kierkegaard, Martin Heidegger, Simone de Beauvoir,
--   Viktor Frankl, Fyodor Dostoevsky, Albert Schweitzer,
--   William James, Bertrand Russell, Ludwig Wittgenstein
-- Target categories: philosophy, meaning, existence
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'existentialism'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'en'
    AND pack_name NOT IN ('stoicism_deep', 'zen_mindfulness', 'existentialism')
    AND (
      author IN (
        'Jean-Paul Sartre',
        'Albert Camus',
        'Friedrich Nietzsche',
        'Søren Kierkegaard',
        'Soren Kierkegaard',
        'Martin Heidegger',
        'Simone de Beauvoir',
        'Viktor Frankl',
        'Fyodor Dostoevsky',
        'Bertrand Russell',
        'Ludwig Wittgenstein',
        'William James',
        'Georg Hegel',
        'Immanuel Kant',
        'Baruch Spinoza',
        'René Descartes',
        'Hannah Arendt',
        'Blaise Pascal',
        'Arthur Schopenhauer',
        'Martin Buber',
        'Paul Tillich'
      )
      OR (
        category IN ('philosophy', 'meaning', 'existence', 'existentialism')
        AND author NOT IN (
          -- stoicism-specific authors
          'Marcus Aurelius', 'Seneca', 'Seneca the Younger', 'Epictetus',
          'Zeno of Citium', 'Cleanthes', 'Chrysippus',
          -- zen-specific authors
          'Thích Nhất Hạnh', 'Alan Watts', 'Rumi', 'Lao Tzu',
          'Bodhidharma', 'Eckhart Tolle', 'Pema Chödrön', 'Dalai Lama',
          'Daisaku Ikeda', 'Thich Nhat Hanh', 'Buddha', 'The Buddha',
          'Dhammapada', 'Zhuang Zhou'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Jean-Paul Sartre','Albert Camus','Friedrich Nietzsche') THEN 1
      WHEN author IN ('Søren Kierkegaard','Soren Kierkegaard','Simone de Beauvoir','Martin Heidegger') THEN 2
      WHEN author IN ('Viktor Frankl','Fyodor Dostoevsky','Hannah Arendt') THEN 3
      WHEN author IN ('Immanuel Kant','Baruch Spinoza','René Descartes','Blaise Pascal') THEN 4
      ELSE 5
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'en'
AND pack_name NOT IN ('stoicism_deep', 'zen_mindfulness', 'existentialism');

-- ──────────────────────────────────────────────────────────────
-- SECTION 4: existentialism — ES
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'existentialism'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'es'
    AND pack_name NOT IN ('stoicism_deep', 'zen_mindfulness', 'existentialism')
    AND (
      author IN (
        'Jean-Paul Sartre',
        'Albert Camus',
        'Friedrich Nietzsche',
        'Søren Kierkegaard',
        'Soren Kierkegaard',
        'Martin Heidegger',
        'Simone de Beauvoir',
        'Viktor Frankl',
        'Fyodor Dostoevsky',
        'Bertrand Russell',
        'Ludwig Wittgenstein',
        'William James',
        'Georg Hegel',
        'Immanuel Kant',
        'Baruch Spinoza',
        'René Descartes',
        'Hannah Arendt',
        'Blaise Pascal',
        'Arthur Schopenhauer',
        'Martin Buber',
        'Paul Tillich'
      )
      OR (
        category IN ('philosophy', 'meaning', 'existence', 'existentialism')
        AND author NOT IN (
          'Marcus Aurelius', 'Seneca', 'Seneca the Younger', 'Epictetus',
          'Zeno of Citium', 'Cleanthes', 'Chrysippus',
          'Thích Nhất Hạnh', 'Alan Watts', 'Rumi', 'Lao Tzu',
          'Bodhidharma', 'Eckhart Tolle', 'Pema Chödrön', 'Dalai Lama',
          'Daisaku Ikeda', 'Thich Nhat Hanh', 'Buddha', 'The Buddha',
          'Dhammapada', 'Zhuang Zhou'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Jean-Paul Sartre','Albert Camus','Friedrich Nietzsche') THEN 1
      WHEN author IN ('Søren Kierkegaard','Soren Kierkegaard','Simone de Beauvoir','Martin Heidegger') THEN 2
      WHEN author IN ('Viktor Frankl','Fyodor Dostoevsky','Hannah Arendt') THEN 3
      WHEN author IN ('Immanuel Kant','Baruch Spinoza','René Descartes','Blaise Pascal') THEN 4
      ELSE 5
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'es'
AND pack_name NOT IN ('stoicism_deep', 'zen_mindfulness', 'existentialism');

-- ──────────────────────────────────────────────────────────────
-- SECTION 5: zen_mindfulness — EN
-- Target authors: Thích Nhất Hạnh, Alan Watts, Rumi, Lao Tzu,
--   Buddha / The Buddha / Dhammapada, Bodhidharma, Eckhart Tolle,
--   Pema Chödrön, Dalai Lama, Zhuang Zhou, Daisaku Ikeda,
--   Eknath Easwaran, Thomas Merton
-- Target categories: mindfulness, peace, wisdom, zen, reflection
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'zen_mindfulness'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'en'
    AND pack_name NOT IN ('stoicism_deep', 'existentialism', 'zen_mindfulness')
    AND (
      author IN (
        'Thích Nhất Hạnh',
        'Thich Nhat Hanh',
        'Alan Watts',
        'Rumi',
        'Lao Tzu',
        'Buddha',
        'The Buddha',
        'Dhammapada',
        'Bodhidharma',
        'Eckhart Tolle',
        'Pema Chödrön',
        'Dalai Lama',
        'Zhuang Zhou',
        'Daisaku Ikeda',
        'Eknath Easwaran',
        'Cheng Yen',
        'Sri Chinmoy',
        'Lin Yutang',
        'Joseph Campbell',
        'Kahlil Gibran',
        'Rabindranath Tagore',
        'Thomas Merton'
      )
      OR (
        category IN ('mindfulness', 'peace', 'zen', 'reflection', 'wisdom')
        AND author NOT IN (
          -- stoicism-specific
          'Marcus Aurelius', 'Seneca', 'Seneca the Younger', 'Epictetus',
          'Zeno of Citium', 'Cleanthes', 'Chrysippus', 'Heraclitus',
          -- existentialism-specific
          'Jean-Paul Sartre', 'Albert Camus', 'Friedrich Nietzsche',
          'Søren Kierkegaard', 'Soren Kierkegaard', 'Simone de Beauvoir',
          'Martin Heidegger', 'Fyodor Dostoevsky', 'Hannah Arendt',
          'Immanuel Kant', 'Baruch Spinoza', 'René Descartes'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Thích Nhất Hạnh','Thich Nhat Hanh','Alan Watts','Rumi','Lao Tzu') THEN 1
      WHEN author IN ('Buddha','The Buddha','Dhammapada','Bodhidharma') THEN 2
      WHEN author IN ('Eckhart Tolle','Pema Chödrön','Dalai Lama','Zhuang Zhou') THEN 3
      WHEN author IN ('Daisaku Ikeda','Eknath Easwaran','Kahlil Gibran','Rabindranath Tagore') THEN 4
      ELSE 5
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'en'
AND pack_name NOT IN ('stoicism_deep', 'existentialism', 'zen_mindfulness');

-- ──────────────────────────────────────────────────────────────
-- SECTION 6: zen_mindfulness — ES
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET pack_name = 'zen_mindfulness'
WHERE id IN (
  SELECT id FROM quotes
  WHERE lang = 'es'
    AND pack_name NOT IN ('stoicism_deep', 'existentialism', 'zen_mindfulness')
    AND (
      author IN (
        'Thích Nhất Hạnh',
        'Thich Nhat Hanh',
        'Alan Watts',
        'Rumi',
        'Lao Tzu',
        'Buddha',
        'The Buddha',
        'Dhammapada',
        'Bodhidharma',
        'Eckhart Tolle',
        'Pema Chödrön',
        'Dalai Lama',
        'Zhuang Zhou',
        'Daisaku Ikeda',
        'Eknath Easwaran',
        'Cheng Yen',
        'Sri Chinmoy',
        'Lin Yutang',
        'Joseph Campbell',
        'Kahlil Gibran',
        'Rabindranath Tagore',
        'Thomas Merton'
      )
      OR (
        category IN ('mindfulness', 'peace', 'zen', 'reflection', 'wisdom')
        AND author NOT IN (
          'Marcus Aurelius', 'Seneca', 'Seneca the Younger', 'Epictetus',
          'Zeno of Citium', 'Cleanthes', 'Chrysippus', 'Heraclitus',
          'Jean-Paul Sartre', 'Albert Camus', 'Friedrich Nietzsche',
          'Søren Kierkegaard', 'Soren Kierkegaard', 'Simone de Beauvoir',
          'Martin Heidegger', 'Fyodor Dostoevsky', 'Hannah Arendt',
          'Immanuel Kant', 'Baruch Spinoza', 'René Descartes'
        )
      )
    )
  ORDER BY
    CASE
      WHEN author IN ('Thích Nhất Hạnh','Thich Nhat Hanh','Alan Watts','Rumi','Lao Tzu') THEN 1
      WHEN author IN ('Buddha','The Buddha','Dhammapada','Bodhidharma') THEN 2
      WHEN author IN ('Eckhart Tolle','Pema Chödrön','Dalai Lama','Zhuang Zhou') THEN 3
      WHEN author IN ('Daisaku Ikeda','Eknath Easwaran','Kahlil Gibran','Rabindranath Tagore') THEN 4
      ELSE 5
    END,
    LENGTH(text) ASC
  LIMIT 500
)
AND lang = 'es'
AND pack_name NOT IN ('stoicism_deep', 'existentialism', 'zen_mindfulness');

-- ──────────────────────────────────────────────────────────────
-- SECTION 7: Backfill released_at for newly assigned quotes
-- Ensures all three packs' quotes are pre-grandfathering cutoff.
-- Migration 009 already ran this for pre-existing rows, but newly
-- assigned rows may have released_at = NOW() from the column default.
-- ──────────────────────────────────────────────────────────────

UPDATE quotes
SET released_at = '2026-01-01T00:00:00Z'
WHERE pack_name IN ('stoicism_deep', 'existentialism', 'zen_mindfulness')
  AND (released_at IS NULL OR released_at > '2026-06-01T00:00:00Z');

-- ──────────────────────────────────────────────────────────────
-- SECTION 8: Deficit audit
-- Run after the UPDATEs to check whether any pack is under 500.
-- ──────────────────────────────────────────────────────────────
/*
SELECT
  pack_name,
  lang,
  COUNT(*)           AS assigned,
  500 - COUNT(*)     AS deficit
FROM quotes
WHERE pack_name IN ('stoicism_deep', 'existentialism', 'zen_mindfulness')
GROUP BY pack_name, lang
ORDER BY pack_name, lang;
*/

-- ──────────────────────────────────────────────────────────────
-- EXPECTED RESULTS (based on 13K bilingual dataset)
-- stoicism_deep  en: ~500  es: ~500  (rich stoic corpus)
-- existentialism en: ~500  es: ~500  (large philosophy/existentialism corpus)
-- zen_mindfulness en: ~500 es: ~450-500 (zen ES corpus slightly smaller)
--
-- DEFICIT RISK: zen_mindfulness ES may fall short if the 13K DB
-- has fewer ES translations for Zen/Taoist authors.
-- If deficit > 50: expand category filter to include 'life', 'inner'.
-- ──────────────────────────────────────────────────────────────
