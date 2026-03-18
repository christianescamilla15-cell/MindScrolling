-- Migration 018: Fix Spanish quote author names to match the authors table.
-- The hardcode_es.js fallback script inserted quotes with Spanish author names
-- (Marco Aurelio, Séneca, etc.) but the authors table only has English names.
-- This causes author detail 404s when the app derives a slug from the Spanish name.
-- Safe to re-run (idempotent — only updates rows that match).

UPDATE quotes SET author = 'Marcus Aurelius' WHERE author = 'Marco Aurelio' AND lang = 'es';
UPDATE quotes SET author = 'Seneca'          WHERE author = 'Séneca'        AND lang = 'es';
UPDATE quotes SET author = 'Epictetus'       WHERE author = 'Epicteto'      AND lang = 'es';
UPDATE quotes SET author = 'Socrates'        WHERE author = 'Sócrates'      AND lang = 'es';
UPDATE quotes SET author = 'Buddha'          WHERE author = 'Buda'          AND lang = 'es';
