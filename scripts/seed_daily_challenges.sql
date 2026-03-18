-- MindScrolling — Daily Challenges Seed
-- Inserts 30 days of challenges starting from today (2026-03-18).
-- Run in Supabase SQL Editor. Safe to re-run (ON CONFLICT DO NOTHING).
-- Each challenge requires 8 quote swipes to complete (TARGET_QUOTES = 8).

INSERT INTO daily_challenges (code, title, description, category, active_date)
VALUES
  ('stoic_morning',        'Stoic Morning',             'Swipe 8 quotes before noon. Let Stoic wisdom set the tone for your day.',                                    'stoicism',     '2026-03-18'),
  ('reflect_on_loss',      'Reflect on Loss',           'Read 8 quotes about impermanence. What in your life are you holding on to that you should release?',         'reflection',   '2026-03-19'),
  ('discipline_daily',     'Daily Discipline',          'Swipe 8 quotes on self-discipline. Choose one principle to apply in the next 24 hours.',                     'discipline',   '2026-03-20'),
  ('philosophy_of_time',   'Philosophy of Time',        'Read 8 quotes about time and mortality. How are you spending yours?',                                        'philosophy',   '2026-03-21'),
  ('stoic_evening',        'Stoic Evening Review',      'Swipe 8 quotes and reflect: What went well today? What would you do differently?',                           'stoicism',     '2026-03-22'),
  ('question_everything',  'Question Everything',       'Read 8 philosophical quotes that challenge assumptions. Which belief do you hold that you've never examined?','philosophy',   '2026-03-23'),
  ('mindful_swipe',        'Mindful Swipe',             'Swipe 8 quotes slowly. For each one, pause 5 seconds before continuing.',                                    'reflection',   '2026-03-24'),
  ('virtue_in_action',     'Virtue in Action',          'Read 8 quotes about virtue and character. What does your best self look like?',                              'stoicism',     '2026-03-25'),
  ('meaning_seeker',       'Seek Meaning',              'Explore 8 existentialist quotes. Write one sentence about what makes your life meaningful.',                  'philosophy',   '2026-03-26'),
  ('control_what_you_can', 'Control What You Can',      'Swipe 8 quotes on agency and acceptance. List 3 things outside your control that you will stop worrying about.','stoicism',  '2026-03-27'),
  ('deep_reflection',      'Deep Reflection',           'Read 8 quotes on introspection. What is one thing you know about yourself that most people do not?',         'reflection',   '2026-03-28'),
  ('philosophy_of_pain',   'Philosophy of Pain',        'Swipe 8 quotes about suffering and resilience. What difficulty has made you stronger?',                      'philosophy',   '2026-03-29'),
  ('present_moment',       'The Present Moment',        'Read 8 quotes about living in the now. Notice 3 things around you right now with full attention.',           'reflection',   '2026-03-30'),
  ('courage_to_act',       'Courage to Act',            'Swipe 8 quotes on courage and fear. What is one action you have been postponing out of fear?',               'discipline',   '2026-03-31'),
  ('examine_your_life',    'Examine Your Life',         'Read 8 philosophical quotes. Choose one to meditate on for the rest of the day.',                            'philosophy',   '2026-04-01'),
  ('stoic_resilience',     'Stoic Resilience',          'Swipe 8 quotes on adversity. Recall a past difficulty — what did it teach you?',                             'stoicism',     '2026-04-02'),
  ('freedom_and_choice',   'Freedom and Choice',        'Read 8 existentialist quotes on freedom. What choice are you avoiding that only you can make?',              'philosophy',   '2026-04-03'),
  ('gratitude_practice',   'Gratitude Practice',        'Swipe 8 quotes on gratitude and abundance. List 5 things you are grateful for right now.',                   'reflection',   '2026-04-04'),
  ('focus_and_attention',  'Focus and Attention',       'Read 8 quotes on concentration. Close all other apps while you swipe. Be fully here.',                       'discipline',   '2026-04-05'),
  ('mortality_reminder',   'Memento Mori',              'Swipe 8 quotes about mortality. How would you live differently if you had one year left?',                   'stoicism',     '2026-04-06'),
  ('inner_voice',          'Your Inner Voice',          'Read 8 quotes on authenticity. Are you living your values, or someone else''s expectations?',                'reflection',   '2026-04-07'),
  ('nature_of_mind',       'Nature of Mind',            'Swipe 8 philosophical quotes about consciousness. What is one thought pattern you want to change?',           'philosophy',   '2026-04-08'),
  ('persistence',          'The Art of Persistence',   'Read 8 quotes on perseverance. What worthwhile goal have you almost given up on?',                            'discipline',   '2026-04-09'),
  ('acceptance',           'Radical Acceptance',        'Swipe 8 quotes on acceptance and letting go. What situation in your life needs acceptance, not resistance?',  'reflection',   '2026-04-10'),
  ('love_and_connection',  'Love and Connection',       'Read 8 quotes on human connection. Who in your life have you neglected to appreciate?',                       'philosophy',   '2026-04-11'),
  ('morning_intention',    'Set Your Intention',        'Swipe 8 quotes before starting your day. Choose one phrase as your intention for today.',                     'discipline',   '2026-04-12'),
  ('impermanence',         'Everything Passes',         'Read 8 quotes about impermanence. What are you clinging to that is already changing?',                       'stoicism',     '2026-04-13'),
  ('philosophical_doubt',  'Embrace Uncertainty',       'Swipe 8 quotes on uncertainty and doubt. What do you hold as certain that may not be?',                      'philosophy',   '2026-04-14'),
  ('daily_audit',          'The Daily Audit',           'Read 8 quotes on self-awareness. At day''s end: did your actions align with your values today?',             'stoicism',     '2026-04-15'),
  ('wisdom_in_silence',    'Wisdom in Silence',         'Swipe 8 quotes. After each one, stay silent for 10 seconds before swiping again.',                           'reflection',   '2026-04-16')
ON CONFLICT (code) DO NOTHING;
