-- 033_science_math_en.sql
-- MindScrolling — Science Mode: Mathematics batch (English)
-- 250 quotes: logic, number theory, geometry, algebra, calculus, statistics,
--   probability, set theory, topology, game theory, cryptography, fractals,
--   infinity, proofs, mathematical beauty, applied math
--
-- All rows:
--   category       = 'philosophy'
--   lang           = 'en'
--   swipe_dir      = 'down'
--   pack_name      = 'free'
--   is_premium     = false
--   content_type   = 'science'
--   sub_category   = 'mathematics'
--   is_hidden_mode = true
--   locked_by      = 'science'
-- Run in Supabase SQL Editor

BEGIN;

-- ══════════════════════════════════════════════════════════════════════════════
-- MATHEMATICS — ENGLISH (250 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by) VALUES

-- Archimedes (1–10)
(gen_random_uuid(), 'Give me a place to stand and I will move the earth.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Mathematics reveals its secrets only to those who approach it with pure love.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The shortest distance between two points is a straight line.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','logic'], true, 'science'),
(gen_random_uuid(), 'Eureka! I have found it.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),
(gen_random_uuid(), 'The circle is the most perfect of all figures.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'In every proof lies the seed of a greater truth.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Numbers do not lie; only those who misread them do.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'To measure is to know, and to know is to master.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'The lever of thought lifts every physical constraint.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Geometry is the art of correct reasoning on incorrect figures.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),

-- Euclid (11–20)
(gen_random_uuid(), 'There is no royal road to geometry.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'A point is that which has no part.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The whole is greater than the part.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Things equal to the same thing are equal to each other.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'A line is breadthless length.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The laws of nature are the laws of geometry made manifest.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'From a single axiom, an entire world of truth may be derived.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'Every theorem rests upon the shoulders of its postulates.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Parallel lines meet only at infinity, and so do some minds.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'To construct a proof is to build a bridge from assumption to certainty.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),

-- Pythagoras (21–28)
(gen_random_uuid(), 'Number is the ruler of forms and ideas.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'All is number.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'The highest form of pure thought is in mathematics.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','beauty'], true, 'science'),
(gen_random_uuid(), 'Reason is immortal, all else mortal.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Numbers have personalities; learn their character and they serve you well.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Geometry is knowledge of the eternally existent.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','truth'], true, 'science'),
(gen_random_uuid(), 'The square of the hypotenuse holds the secret of all right proportion.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'Mathematics is the music of reason.', 'Pythagoras', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),

-- Carl Friedrich Gauss (29–38)
(gen_random_uuid(), 'Mathematics is the queen of the sciences.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'It is not knowledge but the act of learning that grants the greatest enjoyment.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),
(gen_random_uuid(), 'I have had my results for a long time, but I do not yet know how I am to arrive at them.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Few but ripe.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'God does arithmetic.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'When a philosopher says something that is true then it is trivial; when he says something that is not trivial then it is false.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'Number theory is the queen of mathematics, and arithmetic is her crown.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The enchanting charms of this sublime science reveal only to those who have the courage to go deeply into it.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','beauty'], true, 'science'),
(gen_random_uuid(), 'A great truth is a truth whose opposite is also a great truth.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Ask her to wait a moment; I am almost done.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','focus'], true, 'science'),

-- Leonhard Euler (39–48)
(gen_random_uuid(), 'e to the power of i times pi plus one equals zero.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'Mathematicians have tried in vain to this day to discover some order in the sequence of prime numbers.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Nothing takes place in the world whose meaning is not that of some maximum or minimum.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'For the sake of brevity, we will always represent this number 2.718... by the letter e.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'The kind of knowledge which is supported only by observations and is not yet proved must be carefully distinguished from the truth.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','logic'], true, 'science'),
(gen_random_uuid(), 'Logic is the foundation on which all mathematics is built.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'To those who ask what the infinitely small quantity in mathematics is, we answer that it is actually zero.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Infinity is not a destination but a direction.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Every function has a power series lurking within it, waiting to be discovered.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),
(gen_random_uuid(), 'The study of Euler''s identity is the gateway to the beauty of complex analysis.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),

-- Henri Poincaré (49–58)
(gen_random_uuid(), 'Mathematics is the art of giving the same name to different things.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'It is by logic that we prove, but by intuition that we discover.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Science is built up of facts, as a house is built of stones; but an accumulation of facts is no more a science than a heap of stones is a house.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'Doubt everything or believe everything: these are two equally convenient strategies that both dispense with the necessity of reflection.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'The mathematician does not study pure mathematics because it is useful; he studies it because he delights in it.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'Topology is the geometry left behind when you take away all constraints except continuity.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'The object of mathematics is the honor of the human spirit.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'A small error in the beginning will lead to a great error in the end.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'Invention consists in avoiding the constructing of useless contraptions and in directly constructing the useful combinations.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Mathematical creativity is just the ability to connect ideas that have never been connected before.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),

-- Alan Turing (59–68)
(gen_random_uuid(), 'We can only see a short distance ahead, but we can see plenty there that needs to be done.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'A computer would deserve to be called intelligent if it could deceive a human into believing it was human.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Sometimes it is the people no one imagines anything of who do the things that no one can imagine.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Mathematical reasoning may be regarded as the exercise of a combination of intuition and ingenuity.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'The original question ''Can machines think?'' is too meaningless to deserve discussion.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Science is a differential equation; religion is a boundary condition.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Cryptography is the art of hiding information in plain sight.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'A proof is a sequence of steps that leaves no room for doubt.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'The halting problem teaches us that some questions are unanswerable by design.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Intuition without logic is blind; logic without intuition is empty.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Georg Cantor (69–78)
(gen_random_uuid(), 'The essence of mathematics lies in its freedom.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','beauty'], true, 'science'),
(gen_random_uuid(), 'I see it but I don''t believe it.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),
(gen_random_uuid(), 'In mathematics the art of proposing a question must be held of higher value than solving it.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'There are infinitely many infinities, each larger than the last.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'The fear of infinity is a form of myopia that destroys the possibility of seeing the actual infinite.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'A set is a Many which allows itself to be thought of as a One.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The transfinite numbers are in a certain sense the new irrationals.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'In asking about infinity, we ask about the very nature of existence.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Set theory is the language in which all other mathematics is written.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','logic'], true, 'science'),
(gen_random_uuid(), 'The diagonal argument shows that some truths cannot be counted.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),

-- David Hilbert (79–88)
(gen_random_uuid(), 'We must know, we will know.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Mathematics knows no races or geographic boundaries; for mathematics, the cultural world is one country.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'No one shall expel us from the paradise that Cantor has created.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','curiosity'], true, 'science'),
(gen_random_uuid(), 'Physics is too hard for physicists.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'The art of doing mathematics consists in finding that special case which contains all the germs of generality.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'A mathematical problem should be difficult in order to entice us, yet not completely inaccessible.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discipline'], true, 'science'),
(gen_random_uuid(), 'Ignorance is no disgrace; the disgrace is to take no interest in removing it.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),
(gen_random_uuid(), 'An axiomatic system must be consistent, complete, and decidable — so Hilbert demanded.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'Every mathematical discipline begins with the posing of a question.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The infinite is nowhere to be found in reality, but exists only in thought.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),

-- Emmy Noether (89–96)
(gen_random_uuid(), 'My methods are really methods of working and thinking; this is why they have crept in everywhere anonymously.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'Algebra is the language through which all science speaks.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','wisdom'], true, 'science'),
(gen_random_uuid(), 'Symmetry, in its mathematical form, is the deepest law of nature.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'Abstract algebra reveals the hidden skeletons of all mathematical structures.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Every conservation law in physics corresponds to a symmetry in mathematics.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','beauty'], true, 'science'),
(gen_random_uuid(), 'The beauty of a theorem lies not in its complexity but in its inevitability.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'To understand a ring is to understand the arithmetic of the universe.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Women belong in all places where decisions are being made, including the halls of mathematics.', 'Emmy Noether', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','wisdom'], true, 'science'),

-- Srinivasa Ramanujan (97–106)
(gen_random_uuid(), 'An equation for me has no meaning unless it expresses a thought of God.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'I have not trodden through a conventional university course, but I am striking out a new path for myself.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','discipline'], true, 'science'),
(gen_random_uuid(), 'Every positive integer is one of Ramanujan''s personal friends.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'The number 1729 is the smallest number expressible as the sum of two cubes in two different ways.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),
(gen_random_uuid(), 'In mathematics, there are no shortcuts that bypass understanding.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Mathematics, rightly viewed, possesses not only truth but supreme beauty.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'Intuition is the ladder; rigour is the proof that the ladder stands.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Number theory is the poetry of mathematics.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'The infinite series is a river whose source is hidden but whose flow never ends.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'A formula discovered in a dream is still subject to the test of proof.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),

-- Benoit Mandelbrot (107–114)
(gen_random_uuid(), 'Clouds are not spheres, mountains are not cones, coastlines are not circles.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Fractals are not a branch of mathematics but mathematics looking at nature.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'Roughness is the rule, smoothness the exception.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'The Mandelbrot set is the most complicated object in mathematics.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'Self-similarity is the fingerprint of nature''s deepest patterns.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'Between order and chaos lies the fractal dimension where beauty lives.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'I conceived, developed, and applied fractal geometry to a host of fields.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),
(gen_random_uuid(), 'Nature is not simply complex; it is fractally complex at every scale.', 'Benoit Mandelbrot', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),

-- Bertrand Russell (115–124)
(gen_random_uuid(), 'Mathematics, rightly viewed, possesses not only truth but supreme beauty — a beauty cold and austere.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'Pure mathematics consists entirely of assertions to the effect that if such and such a proposition is true, then such and such another proposition is also true.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'The fact that all mathematics is symbolic logic is one of the greatest discoveries of our age.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'Mathematics takes us into the region of absolute necessity, to which not only the actual world but every possible world must conform.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','logic'], true, 'science'),
(gen_random_uuid(), 'In mathematics, existence is proved by construction.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The whole problem with the world is that fools and fanatics are always so certain of themselves, and wiser people so full of doubts.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'Not to be absolutely certain is one of the essential things in rationality.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'The point of philosophy is to start with something so simple as not to seem worth stating and end with something so paradoxical that no one will believe it.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Paradoxes are the growing pains of logic.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Logic is the anatomy of thought.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Kurt Gödel (125–132)
(gen_random_uuid(), 'Either mathematics is too big for the human mind, or the human mind is more than a machine.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'The more I think about language, the more it amazes me that people ever understand each other at all.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'No consistent system of axioms can prove all truths about arithmetic.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'The incompleteness theorems show that truth transcends proof.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Consciousness is not a theorem; it is the axiom from which all else follows.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Self-reference is the source of all paradox and all richness in formal systems.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','curiosity'], true, 'science'),
(gen_random_uuid(), 'Completeness and consistency cannot both be satisfied in a sufficiently powerful system.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'The limits of formal proof are the beginning of mathematical philosophy.', 'Kurt Gödel', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),

-- John von Neumann (133–142)
(gen_random_uuid(), 'In mathematics you don''t understand things, you just get used to them.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'If people do not believe that mathematics is simple, it is only because they do not realize how complicated life is.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'Young man, in mathematics you don''t understand things, you just get used to them.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','growth'], true, 'science'),
(gen_random_uuid(), 'The sciences do not try to explain; they hardly even try to interpret; they mainly make models.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','wisdom'], true, 'science'),
(gen_random_uuid(), 'Truth is much too complicated to allow anything but approximations.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Game theory is the study of rational conflict and cooperation.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'A zero-sum game has no room for mutual gain; real life rarely is zero-sum.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'The computer is the microscope of the mathematical scientist.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Any mathematical result is only as strong as its weakest assumption.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'Monte Carlo methods show that randomness can illuminate deterministic truth.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),

-- Pierre-Simon Laplace (143–150)
(gen_random_uuid(), 'Nature laughs at the difficulties of integration.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'We may regard the present state of the universe as the effect of its past and the cause of its future.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'The probability of an event is the ratio of the favorable cases to the total number of equally possible cases.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'It is remarkable that a science which began with the consideration of games of chance should have become the most important object of human knowledge.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'The weight of evidence for an extraordinary claim must be proportioned to its strangeness.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'Probability theory is nothing but common sense reduced to calculation.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Celestial mechanics is the triumph of the calculus over the mysteries of the heavens.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','beauty'], true, 'science'),
(gen_random_uuid(), 'I had no need of that hypothesis.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),

-- Blaise Pascal (151–160)
(gen_random_uuid(), 'Man is but a reed, the most feeble thing in nature; but he is a thinking reed.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'The heart has its reasons which reason knows not of.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'All of humanity''s problems stem from man''s inability to sit quietly in a room alone.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','reflection'], true, 'science'),
(gen_random_uuid(), 'The last thing one discovers in composing a work is what to put first.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'In faith there is enough light for those who want to believe, and enough darkness for those who don''t.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Probability is the language of uncertainty made precise.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The triangle of numbers is infinite; every row contains multiples of its row number.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'We know the truth not only by reason but also by the heart.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Our nature consists in movement; absolute rest is death.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'Clarity of mind means clarity of passion; this is why a great and clear mind loves ardently.', 'Blaise Pascal', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),

-- René Descartes (161–168)
(gen_random_uuid(), 'I think, therefore I am.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','wisdom'], true, 'science'),
(gen_random_uuid(), 'Each problem that I solved became a rule which served afterwards to solve other problems.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'The reading of all good books is like conversation with the finest men of past centuries.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'To enumerate all possibilities and review them so carefully that nothing is left out.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'Divide each difficulty into as many parts as is feasible and necessary to resolve it.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'With me everything turns into mathematics.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Cogito ergo sum: the one certainty that anchors all other knowledge.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['truth','logic'], true, 'science'),
(gen_random_uuid(), 'The coordinate plane is the bridge between geometry and algebra.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),

-- Gottfried Leibniz (169–176)
(gen_random_uuid(), 'Music is the pleasure the human mind experiences from counting without being aware it is counting.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'The calculus of infinitesimals is the key that unlocks the mechanics of nature.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'This is the best of all possible worlds.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'The art of discovering the causes of phenomena is the art of all sciences.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Nothing is without reason; everything has a sufficient cause.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'Binary arithmetic is the foundation of all modern computation.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'To love is to find pleasure in the happiness of others.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'The differential and integral are two faces of the same mathematical coin.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','beauty'], true, 'science'),

-- G.H. Hardy (177–186)
(gen_random_uuid(), 'A mathematician, like a painter or a poet, is a maker of patterns.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'Beauty is the first test: there is no permanent place in the world for ugly mathematics.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'I have never done anything useful. No discovery of mine has made, or is likely to make, any difference to the amenities of the world.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Pure mathematics is on the whole distinctly more useful than applied.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),
(gen_random_uuid(), 'There is no scorn more profound than that of the man who has real mathematics for the applications.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'A mathematician is young enough as long as there is still mathematics to discover.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),
(gen_random_uuid(), 'The mathematical mind is its own place, and in itself can make a heaven of hell.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','beauty'], true, 'science'),
(gen_random_uuid(), 'Real mathematics must be justified as art if it can be justified at all.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'The mathematician''s patterns, like the painter''s or the poet''s, must be beautiful.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'Exposition, criticism, appreciation: these are the tools of the mathematical critic.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),

-- Paul Erdős (187–196)
(gen_random_uuid(), 'A mathematician is a device for turning coffee into theorems.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'My brain is open.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),
(gen_random_uuid(), 'Another roof, another proof.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'You don''t have to believe in God, but you should believe in The Book.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science'),
(gen_random_uuid(), 'The Book holds the most elegant proof of every theorem.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'Mathematics is not a spectator sport.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','curiosity'], true, 'science'),
(gen_random_uuid(), 'Collaboration is not a weakness; it is how mathematics progresses fastest.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','growth'], true, 'science'),
(gen_random_uuid(), 'Property is a nuisance; mathematics is freedom.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'The Erdős number measures not fame but collaboration in the pursuit of truth.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'Every child is born a mathematician; education must not extinguish that spark.', 'Paul Erdős', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),

-- Andrew Wiles (197–204)
(gen_random_uuid(), 'Perhaps I can best describe my experience of doing mathematics in terms of entering a dark mansion.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Fermat''s Last Theorem stood for 358 years until a single proof finally closed the door.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','truth'], true, 'science'),
(gen_random_uuid(), 'The moment of finding the proof is like stumbling out of the dark into brilliant light.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discovery','beauty'], true, 'science'),
(gen_random_uuid(), 'There is no mathematician who has not wondered if their proof is truly correct.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'The greatest thrill in mathematics is the sudden illumination that makes everything clear.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'Seven years of solitary work can end in one extraordinary morning.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','discovery'], true, 'science'),
(gen_random_uuid(), 'A failed proof is not a wasted effort; it maps the territory of what doesn''t work.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'Elliptic curves and modular forms were the unexpected bridge that proved the unprovable.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','discovery'], true, 'science'),

-- Terence Tao (205–212)
(gen_random_uuid(), 'Good mathematics is not just about solving problems, but about changing how you see them.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'The process of mathematics is as important as its results.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'Rigor is not the enemy of intuition; it is its most faithful companion.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'The best mathematicians are those who can move fluidly between intuition and formalism.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','curiosity'], true, 'science'),
(gen_random_uuid(), 'Mathematics rewards persistence and punishes complacency.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['discipline','wisdom'], true, 'science'),
(gen_random_uuid(), 'Every unsolved problem is an open door; every proof is a closed one you never need to reopen.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Pattern recognition is not enough; you must prove why the pattern holds.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),
(gen_random_uuid(), 'The Green-Tao theorem says primes contain arbitrarily long arithmetic progressions.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),

-- Maryam Mirzakhani (213–218)
(gen_random_uuid(), 'The beauty of mathematics only shows itself to more patient followers.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','discipline'], true, 'science'),
(gen_random_uuid(), 'You have to spend some energy and effort to see the beauty of math.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','discipline'], true, 'science'),
(gen_random_uuid(), 'I don''t have any particular recipe for finding the right questions; it is a matter of luck and instinct.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'The more I spend time on mathematics, the more it feels like a vast, beautiful landscape.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','curiosity'], true, 'science'),
(gen_random_uuid(), 'It is not about being the fastest; it is about seeing the deepest.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','discipline'], true, 'science'),
(gen_random_uuid(), 'I like crossing the imaginary boundaries people set up between different fields.', 'Maryam Mirzakhani', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','growth'], true, 'science'),

-- John Nash (219–224)
(gen_random_uuid(), 'Classes will dull your mind, destroy the potential for authentic creativity.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'I always believed in numbers and the equations and logics that lead to reason.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'In a Nash equilibrium, no player can benefit by changing only their own strategy.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'Rational behavior in an irrational world is itself a kind of proof.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Game theory illuminates the hidden mathematics of human cooperation and conflict.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','wisdom'], true, 'science'),
(gen_random_uuid(), 'The mind that seeks equilibrium finds it first in mathematics.', 'John Nash', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','truth'], true, 'science'),

-- Thematic — Logic & Proofs (225–232)
(gen_random_uuid(), 'A proof is not a picture of truth; it is a path to it.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'The elegance of a proof is measured by how much it reveals with how little it assumes.', 'G.H. Hardy', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','logic'], true, 'science'),
(gen_random_uuid(), 'A theorem is not truly proven until its proof is understood, not just verified.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Every great proof begins with a moment of believing the impossible might be true.', 'Andrew Wiles', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['courage','wisdom'], true, 'science'),
(gen_random_uuid(), 'Induction is the mathematical art of climbing an infinite staircase one step at a time.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'A counterexample defeats a conjecture more decisively than any proof confirms it.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','truth'], true, 'science'),
(gen_random_uuid(), 'Proof by contradiction is the art of showing that denial of truth leads to absurdity.', 'Euclid', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','wisdom'], true, 'science'),
(gen_random_uuid(), 'The shortest proof is not always the most illuminating.', 'Terence Tao', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),

-- Thematic — Infinity & Set Theory (233–238)
(gen_random_uuid(), 'Infinity is not a number; it is a direction toward which numbers point.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','wisdom'], true, 'science'),
(gen_random_uuid(), 'Between any two real numbers lies an entire uncountable infinity.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'The continuum hypothesis asks whether there is a size of infinity between integers and reals.', 'David Hilbert', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Transfinite arithmetic is the mathematics of the truly boundless.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'The empty set is the foundation upon which all of mathematics is built.', 'Bertrand Russell', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'Every mathematical object is ultimately a set in disguise.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),

-- Thematic — Calculus & Analysis (239–244)
(gen_random_uuid(), 'The derivative tells you where you are going; the integral tells you where you have been.', 'Gottfried Leibniz', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','wisdom'], true, 'science'),
(gen_random_uuid(), 'The fundamental theorem of calculus is the most beautiful result in all of analysis.', 'Leonhard Euler', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','truth'], true, 'science'),
(gen_random_uuid(), 'A limit is not a destination but the boundary between the finite and the infinite.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'Continuity is the promise that small changes produce small effects.', 'René Descartes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','knowledge'], true, 'science'),
(gen_random_uuid(), 'The Taylor series allows every smooth function to be approximated by polynomials.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'Epsilon and delta are the watchdogs of mathematical rigor in analysis.', 'Carl Friedrich Gauss', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['logic','discipline'], true, 'science'),

-- Thematic — Mathematical Beauty & Applied Math (245–250)
(gen_random_uuid(), 'Applied mathematics is pure mathematics finding its way home to reality.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','knowledge'], true, 'science'),
(gen_random_uuid(), 'Statistics is the grammar of science.', 'Karl Pearson', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','wisdom'], true, 'science'),
(gen_random_uuid(), 'Probability is the measure of our ignorance made quantitative.', 'Pierre-Simon Laplace', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom','logic'], true, 'science'),
(gen_random_uuid(), 'Topology is geometry freed from the tyranny of rigid measurement.', 'Henri Poincaré', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['curiosity','knowledge'], true, 'science'),
(gen_random_uuid(), 'Cryptography is the mathematics of secrets.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['knowledge','curiosity'], true, 'science'),
(gen_random_uuid(), 'The unreasonable effectiveness of mathematics in describing nature is the deepest mystery of science.', 'Srinivasa Ramanujan', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['beauty','wisdom'], true, 'science')

ON CONFLICT (text, author) DO NOTHING;

COMMIT;
