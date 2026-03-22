-- 028_seed_hidden_mode_content.sql
-- MindScrolling — Hidden Mode content seed
-- Science Mode:  80 quotes (40 EN + 40 ES), sub-categories: general_science, physics, mathematics, technology
-- Coding Mode:   80 quotes (40 EN + 40 ES), sub-categories: frontend, backend, fundamentals, devops_tools
-- Total: 160 quotes
--
-- All rows:
--   category     = 'philosophy'   (base category; swipe_dir follows → 'down')
--   swipe_dir    = 'down'
--   pack_name    = 'free'         (locked by quiz, not paywall)
--   is_premium   = false
--   is_hidden_mode = true
--   locked_by    = 'science' | 'coding'
-- Run in Supabase SQL Editor

BEGIN;

-- ══════════════════════════════════════════════════════════════════════════════
-- SCIENCE MODE — ENGLISH (40 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── general_science · EN (10) ─────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'The good thing about science is that it''s true whether or not you believe in it.', 'Neil deGrasse Tyson', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Science is not only a disciple of reason but also one of romance and passion.', 'Stephen Hawking', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'creativity', 'learning'], true, 'science'),
(gen_random_uuid(), 'I have no special talent. I am only passionately curious.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'self_improvement', 'learning'], true, 'science'),
(gen_random_uuid(), 'Somewhere, something incredible is waiting to be known.', 'Carl Sagan', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'learning', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'The most exciting phrase to hear in science is not "Eureka!" but "That''s funny."', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'learning', 'creativity'], true, 'science'),
(gen_random_uuid(), 'Nothing in life is to be feared; it is only to be understood.', 'Marie Curie', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'An experiment is a question which science poses to Nature, and a measurement is the recording of Nature''s answer.', 'Max Planck', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['learning', 'curiosity', 'focus'], true, 'science'),
(gen_random_uuid(), 'In questions of science, the authority of a thousand is not worth the humble reasoning of a single individual.', 'Galileo Galilei', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'A man who dares to waste one hour of time has not discovered the value of life.', 'Charles Darwin', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['discipline', 'focus', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'Science and everyday life cannot and should not be separated.', 'Rosalind Franklin', 'philosophy', 'en', 'down', 'free', false, 'science', 'general_science', ARRAY['learning', 'wisdom', 'curiosity'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── physics · EN (10) ─────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Imagination is more important than knowledge. Knowledge is limited. Imagination encircles the world.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['creativity', 'curiosity', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'The universe is under no obligation to make sense to you.', 'Neil deGrasse Tyson', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'If you thought that science was certain — well, that is just an error on your part.', 'Richard Feynman', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['wisdom', 'learning', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'Not only is the universe stranger than we think, it is stranger than we can think.', 'Werner Heisenberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'What we observe is not nature itself, but nature exposed to our method of questioning.', 'Werner Heisenberg', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'God does not play dice with the universe.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['wisdom', 'curiosity', 'focus'], true, 'science'),
(gen_random_uuid(), 'The cosmos is within us. We are made of star-stuff. We are a way for the universe to know itself.', 'Carl Sagan', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'If I have seen further, it is by standing on the shoulders of giants.', 'Isaac Newton', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['learning', 'wisdom', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'Nature is pleased with simplicity, and nature is no dummy.', 'Isaac Newton', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'My goal is simple: complete understanding of the universe, why it is as it is and why it exists at all.', 'Stephen Hawking', 'philosophy', 'en', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'focus', 'learning'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── mathematics · EN (10) ─────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Mathematics is the language in which God has written the universe.', 'Galileo Galilei', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Pure mathematics is, in its way, the poetry of logical ideas.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Do not worry about your difficulties in mathematics. I can assure you mine are still greater.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['self_improvement', 'discipline', 'learning'], true, 'science'),
(gen_random_uuid(), 'God made the integers; all the rest is the work of man.', 'Leopold Kronecker', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Mathematics is not about numbers, equations, or algorithms: it is about understanding.', 'William Paul Thurston', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'learning', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'Give me a lever long enough and a fulcrum on which to place it, and I shall move the world.', 'Archimedes', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'focus', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'In mathematics you don''t understand things. You just get used to them.', 'John von Neumann', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['learning', 'discipline', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'The essence of mathematics lies in its freedom.', 'Georg Cantor', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'A mathematician who is not also something of a poet will never be a complete mathematician.', 'Karl Weierstrass', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Without mathematics, there is nothing you can do. Everything around you is mathematics.', 'Shakuntala Devi', 'philosophy', 'en', 'down', 'free', false, 'science', 'mathematics', ARRAY['learning', 'curiosity', 'wisdom'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── technology · EN (10) ──────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'The present is theirs; the future, for which I really worked, is mine.', 'Nikola Tesla', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus', 'discipline', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'Science can amuse and fascinate us all, but it is engineering that changes the world.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity', 'learning', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'The machine does not isolate man from the great problems of nature but plunges him more deeply into them.', 'Antoine de Saint-Exupery', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'We can only see a short distance ahead, but we can see plenty there that needs to be done.', 'Alan Turing', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['focus', 'discipline', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'The Analytical Engine has no pretensions whatever to originate anything. It can only do what we know how to order it to perform.', 'Ada Lovelace', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'learning', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'I do not fear computers. I fear the lack of them.', 'Isaac Asimov', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'The question of whether a computer can think is no more interesting than the question of whether a submarine can swim.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Any sufficiently advanced technology is indistinguishable from magic.', 'Arthur C. Clarke', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity', 'creativity', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'The advance of technology is based on making it fit in so that you don''t really even notice it.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['creativity', 'focus', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'It has become appallingly obvious that our technology has exceeded our humanity.', 'Albert Einstein', 'philosophy', 'en', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ══════════════════════════════════════════════════════════════════════════════
-- SCIENCE MODE — SPANISH (40 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── general_science · ES (10) ─────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Lo bueno de la ciencia es que es verdad tanto si crees en ella como si no.', 'Neil deGrasse Tyson', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'La ciencia no es solo una disciplina de la razón, sino también del romance y la pasión.', 'Stephen Hawking', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'creativity', 'learning'], true, 'science'),
(gen_random_uuid(), 'No tengo ningún talento especial. Solo soy apasionadamente curioso.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'self_improvement', 'learning'], true, 'science'),
(gen_random_uuid(), 'En algún lugar algo increíble espera ser descubierto.', 'Carl Sagan', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['curiosity', 'learning', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'Nada en la vida debe ser temido; solo debe ser comprendido.', 'Marie Curie', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'La vida no es fácil para ninguno de nosotros. ¿Y qué? Hay que tener perseverancia y, sobre todo, confianza en uno mismo.', 'Marie Curie', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['discipline', 'self_improvement', 'focus'], true, 'science'),
(gen_random_uuid(), 'Un experimento es una pregunta que la ciencia le hace a la Naturaleza, y una medición es el registro de la respuesta de la Naturaleza.', 'Max Planck', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['learning', 'curiosity', 'focus'], true, 'science'),
(gen_random_uuid(), 'En cuestiones de ciencia, la autoridad de mil no vale el razonamiento humilde de un solo individuo.', 'Galileo Galilei', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Un hombre que se atreve a desperdiciar una hora de su tiempo no ha descubierto el valor de la vida.', 'Charles Darwin', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['discipline', 'focus', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'La ciencia y la vida cotidiana no pueden ni deben estar separadas.', 'Rosalind Franklin', 'philosophy', 'es', 'down', 'free', false, 'science', 'general_science', ARRAY['learning', 'wisdom', 'curiosity'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── physics · ES (10) ─────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'La imaginación es más importante que el conocimiento. El conocimiento es limitado; la imaginación rodea al mundo.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['creativity', 'curiosity', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'El universo no tiene ninguna obligación de tener sentido para ti.', 'Neil deGrasse Tyson', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'No solo el universo es más extraño de lo que pensamos, es más extraño de lo que podemos pensar.', 'Werner Heisenberg', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Dios no juega a los dados con el universo.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['wisdom', 'curiosity', 'focus'], true, 'science'),
(gen_random_uuid(), 'El cosmos está en nosotros. Estamos hechos de materia estelar. Somos una forma en que el universo se conoce a sí mismo.', 'Carl Sagan', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Si he podido ver más lejos, es porque me he subido a los hombros de gigantes.', 'Isaac Newton', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['learning', 'wisdom', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'Mi objetivo es simple: comprender completamente el universo, por qué es como es y por qué existe en absoluto.', 'Stephen Hawking', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'focus', 'learning'], true, 'science'),
(gen_random_uuid(), 'Lo que observamos no es la naturaleza en sí misma, sino la naturaleza expuesta a nuestro método de interrogación.', 'Werner Heisenberg', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'La naturaleza se complace en la simplicidad, y la naturaleza no es tonta.', 'Isaac Newton', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Si la ciencia no puede responder, la imaginación debe explorar.', 'Richard Feynman', 'philosophy', 'es', 'down', 'free', false, 'science', 'physics', ARRAY['creativity', 'curiosity', 'learning'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── mathematics · ES (10) ─────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'La matemática es el lenguaje en que Dios ha escrito el universo.', 'Galileo Galilei', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas puras son, a su manera, la poesía de las ideas lógicas.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'No te preocupes por tus dificultades en matemáticas. Te aseguro que las mías son aún mayores.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['self_improvement', 'discipline', 'learning'], true, 'science'),
(gen_random_uuid(), 'En matemáticas no entiendes las cosas. Solo te acostumbras a ellas.', 'John von Neumann', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['learning', 'discipline', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'La esencia de las matemáticas reside en su libertad.', 'Georg Cantor', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'Dame un punto de apoyo y moveré el mundo.', 'Archimedes', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'focus', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'Un matemático que no sea también algo poeta nunca será un matemático completo.', 'Karl Weierstrass', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['creativity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Sin matemáticas no puedes hacer nada. Todo lo que te rodea son matemáticas.', 'Shakuntala Devi', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['learning', 'curiosity', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'Dios hizo los enteros; todo lo demás es obra del hombre.', 'Leopold Kronecker', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Las matemáticas no son sobre números, ecuaciones ni algoritmos: son sobre entender.', 'William Paul Thurston', 'philosophy', 'es', 'down', 'free', false, 'science', 'mathematics', ARRAY['wisdom', 'learning', 'curiosity'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ── technology · ES (10) ──────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'El presente es de ellos; el futuro, por el que realmente trabajé, es mío.', 'Nikola Tesla', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['focus', 'discipline', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'Podemos ver poco en el futuro, pero podemos ver bastante allí que necesita hacerse.', 'Alan Turing', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['focus', 'discipline', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'El Motor Analítico no tiene ninguna pretensión de originar nada. Solo puede hacer lo que nosotros sabemos ordenarle que haga.', 'Ada Lovelace', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'learning', 'curiosity'], true, 'science'),
(gen_random_uuid(), 'No temo a las computadoras. Temo la falta de ellas.', 'Isaac Asimov', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity', 'wisdom', 'learning'], true, 'science'),
(gen_random_uuid(), 'Cualquier tecnología suficientemente avanzada es indistinguible de la magia.', 'Arthur C. Clarke', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['curiosity', 'creativity', 'wisdom'], true, 'science'),
(gen_random_uuid(), 'La pregunta de si una computadora puede pensar no es más interesante que si un submarino puede nadar.', 'Edsger Dijkstra', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'La máquina no aísla al hombre de los grandes problemas de la naturaleza, sino que lo sumerge más profundamente en ellos.', 'Antoine de Saint-Exupery', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'Se ha vuelto dolorosamente obvio que nuestra tecnología ha superado a nuestra humanidad.', 'Albert Einstein', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['wisdom', 'curiosity', 'learning'], true, 'science'),
(gen_random_uuid(), 'La ciencia puede divertirnos y fascinarnos, pero es la ingeniería la que cambia el mundo.', 'Isaac Asimov', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['creativity', 'learning', 'self_improvement'], true, 'science'),
(gen_random_uuid(), 'El avance de la tecnología se basa en hacer que encaje de modo que ni siquiera te das cuenta.', 'Bill Gates', 'philosophy', 'es', 'down', 'free', false, 'science', 'technology', ARRAY['creativity', 'focus', 'self_improvement'], true, 'science')
ON CONFLICT (text, author) DO NOTHING;

-- ══════════════════════════════════════════════════════════════════════════════
-- CODING MODE — ENGLISH (40 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── frontend · EN (10) ────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Design is not just what it looks like and feels like. Design is how it works.', 'Steve Jobs', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'The web is more a social creation than a technical one. I designed it for a social effect.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'wisdom', 'learning'], true, 'coding'),
(gen_random_uuid(), 'Good design is obvious. Great design is transparent.', 'Joe Sparano', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'wisdom', 'focus'], true, 'coding'),
(gen_random_uuid(), 'The user interface is the product. If the experience is bad, the product is bad.', 'Jared Spool', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['focus', 'discipline', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away.', 'Antoine de Saint-Exupery', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'The Web as I envisaged it, we have not seen it yet. The future is still so much bigger than the past.', 'Tim Berners-Lee', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['curiosity', 'creativity', 'learning'], true, 'coding'),
(gen_random_uuid(), 'Programs must be written for people to read, and only incidentally for machines to execute.', 'Harold Abelson', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'discipline', 'learning'], true, 'coding'),
(gen_random_uuid(), 'The most important property of a program is whether it accomplishes the intention of its user.', 'C. A. R. Hoare', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['focus', 'discipline', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'Make it work, make it right, make it fast — in that order.', 'Kent Beck', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Any fool can write code that a computer can understand. Good programmers write code that humans can understand.', 'Martin Fowler', 'philosophy', 'en', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'discipline', 'learning'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── backend · EN (10) ─────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Premature optimization is the root of all evil.', 'Donald Knuth', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'The art of programming is the art of organizing complexity.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'First, solve the problem. Then, write the code.', 'John Johnson', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'The function of good software is to make the complex appear to be simple.', 'Grady Booch', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'creativity', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'Good architecture is the result of countless small decisions made correctly over time.', 'Martin Fowler', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'A distributed system is one in which the failure of a computer you didn''t even know existed can render your own computer unusable.', 'Leslie Lamport', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'The most effective debugging tool is still careful thought, coupled with judiciously placed print statements.', 'Brian Kernighan', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'Software is a great combination between artistry and engineering.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['creativity', 'discipline', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'Simplicity is prerequisite for reliability.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'The best code is no code at all.', 'Jeff Atwood', 'philosophy', 'en', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'wisdom', 'focus'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── fundamentals · EN (10) ────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Computer science is no more about computers than astronomy is about telescopes.', 'Edsger Dijkstra', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'An algorithm must be seen to be believed.', 'Donald Knuth', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'Debugging is twice as hard as writing the code in the first place. Therefore, if you write the code as cleverly as possible, you are, by definition, not smart enough to debug it.', 'Brian Kernighan', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'discipline', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'The most powerful programming language is the one you know best.', 'Alan Kay', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'self_improvement', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Clean code always looks like it was written by someone who cares.', 'Robert C. Martin', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'You can''t write perfect software. Did that hurt? It shouldn''t. Accept it as an axiom of life.', 'Andrew Hunt', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'self_improvement', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'Talk is cheap. Show me the code.', 'Linus Torvalds', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'The key to performance is elegance, not battalions of special cases.', 'Jon Bentley', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Before software can be reusable it first has to be usable.', 'Ralph Johnson', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'wisdom', 'focus'], true, 'coding'),
(gen_random_uuid(), 'The most important skill in computer science is knowing how to think about problems.', 'Alan Kay', 'philosophy', 'en', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── devops_tools · EN (10) ────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'To iterate is human, to recurse divine.', 'L. Peter Deutsch', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'wisdom', 'learning'], true, 'coding'),
(gen_random_uuid(), 'Continuous improvement is better than delayed perfection.', 'Mark Twain', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['discipline', 'self_improvement', 'focus'], true, 'coding'),
(gen_random_uuid(), 'The automation of routine tasks gives humans space to do what only humans can do.', 'Margaret Hamilton', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'Software is eating the world.', 'Marc Andreessen', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['curiosity', 'learning', 'creativity'], true, 'coding'),
(gen_random_uuid(), 'Measuring programming progress by lines of code is like measuring aircraft building progress by weight.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Release early. Release often. And listen to your customers.', 'Eric S. Raymond', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Most of the good programmers do programming not because they expect to get paid, but because it is fun to program.', 'Linus Torvalds', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'discipline', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Systems that are broken by design cannot be fixed by policy.', 'Jeff Dean', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'One bad programmer can easily create two new jobs a year.', 'David Parnas', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'learning', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'The computer was born to solve problems that did not exist before.', 'Bill Gates', 'philosophy', 'en', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'curiosity', 'learning'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ══════════════════════════════════════════════════════════════════════════════
-- CODING MODE — SPANISH (40 quotes)
-- ══════════════════════════════════════════════════════════════════════════════

-- ── frontend · ES (10) ────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'El diseño no es solo cómo se ve y se siente. El diseño es cómo funciona.', 'Steve Jobs', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'La web es más una creación social que técnica. La diseñé para lograr un efecto social.', 'Tim Berners-Lee', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'wisdom', 'learning'], true, 'coding'),
(gen_random_uuid(), 'La perfección se logra no cuando no hay nada más que agregar, sino cuando no queda nada por quitar.', 'Antoine de Saint-Exupery', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'Los programas deben ser escritos para que la gente los lea, y solo incidentalmente para que las máquinas los ejecuten.', 'Harold Abelson', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'discipline', 'learning'], true, 'coding'),
(gen_random_uuid(), 'Hazlo funcionar, hazlo correcto, hazlo rápido — en ese orden.', 'Kent Beck', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Cualquier tonto puede escribir código que una computadora pueda entender. Los buenos programadores escriben código que los humanos puedan entender.', 'Martin Fowler', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['wisdom', 'discipline', 'learning'], true, 'coding'),
(gen_random_uuid(), 'La Web que imaginé aún no la hemos visto. El futuro es todavía mucho más grande que el pasado.', 'Tim Berners-Lee', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['curiosity', 'creativity', 'learning'], true, 'coding'),
(gen_random_uuid(), 'La propiedad más importante de un programa es si logra la intención de su usuario.', 'C. A. R. Hoare', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['focus', 'discipline', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'El buen diseño es obvio. El gran diseño es transparente.', 'Joe Sparano', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['creativity', 'wisdom', 'focus'], true, 'coding'),
(gen_random_uuid(), 'La interfaz de usuario es el producto. Si la experiencia es mala, el producto es malo.', 'Jared Spool', 'philosophy', 'es', 'down', 'free', false, 'coding', 'frontend', ARRAY['focus', 'discipline', 'self_improvement'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── backend · ES (10) ─────────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'La optimización prematura es la raíz de todo mal.', 'Donald Knuth', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'El arte de programar es el arte de organizar la complejidad.', 'Edsger Dijkstra', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'Primero, resuelve el problema. Luego, escribe el código.', 'John Johnson', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'La función del buen software es hacer que lo complejo parezca simple.', 'Grady Booch', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'creativity', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'La herramienta de depuración más eficaz sigue siendo el pensamiento cuidadoso, combinado con sentencias de impresión bien ubicadas.', 'Brian Kernighan', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'La simplicidad es un requisito previo para la fiabilidad.', 'Edsger Dijkstra', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'El software es una gran combinación entre el arte y la ingeniería.', 'Bill Gates', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['creativity', 'discipline', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'La buena arquitectura es el resultado de innumerables pequeñas decisiones tomadas correctamente con el tiempo.', 'Martin Fowler', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'Un sistema distribuido es aquel en el que el fallo de una computadora que ni siquiera sabías que existía puede inutilizar la tuya.', 'Leslie Lamport', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'El mejor código no es código en absoluto.', 'Jeff Atwood', 'philosophy', 'es', 'down', 'free', false, 'coding', 'backend', ARRAY['discipline', 'wisdom', 'focus'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── fundamentals · ES (10) ────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'La informática no tiene más que ver con las computadoras que la astronomía con los telescopios.', 'Edsger Dijkstra', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'Un algoritmo debe verse para creerlo.', 'Donald Knuth', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'El código limpio siempre parece haber sido escrito por alguien que se preocupa.', 'Robert C. Martin', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'focus', 'wisdom'], true, 'coding'),
(gen_random_uuid(), 'No puedes escribir software perfecto. ¿Eso duele? No debería. Acéptalo como un axioma de vida.', 'Andrew Hunt', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'self_improvement', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'Las palabras son baratas. Muéstrame el código.', 'Linus Torvalds', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'La clave del rendimiento es la elegancia, no batallones de casos especiales.', 'Jon Bentley', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Antes de que el software pueda reutilizarse, primero tiene que poder usarse.', 'Ralph Johnson', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'wisdom', 'focus'], true, 'coding'),
(gen_random_uuid(), 'El lenguaje de programación más poderoso es aquel que conoces mejor.', 'Alan Kay', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['discipline', 'self_improvement', 'focus'], true, 'coding'),
(gen_random_uuid(), 'La habilidad más importante en informática es saber cómo pensar en los problemas.', 'Alan Kay', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'learning', 'curiosity'], true, 'coding'),
(gen_random_uuid(), 'Depurar es el doble de difícil que escribir el código. Por tanto, si escribes el código lo más hábilmente posible, por definición no serás lo suficientemente inteligente para depurarlo.', 'Brian Kernighan', 'philosophy', 'es', 'down', 'free', false, 'coding', 'fundamentals', ARRAY['wisdom', 'discipline', 'self_improvement'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

-- ── devops_tools · ES (10) ────────────────────────────────────────────────

INSERT INTO quotes (id, text, author, category, lang, swipe_dir, pack_name, is_premium, content_type, sub_category, tags, is_hidden_mode, locked_by)
VALUES
(gen_random_uuid(), 'Iterar es humano; recurrir es divino.', 'L. Peter Deutsch', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'wisdom', 'learning'], true, 'coding'),
(gen_random_uuid(), 'La mejora continua es mejor que la perfección tardía.', 'Mark Twain', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['discipline', 'self_improvement', 'focus'], true, 'coding'),
(gen_random_uuid(), 'La automatización de las tareas rutinarias da a los humanos espacio para hacer lo que solo los humanos pueden hacer.', 'Margaret Hamilton', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'focus', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'El software se está comiendo el mundo.', 'Marc Andreessen', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['curiosity', 'learning', 'creativity'], true, 'coding'),
(gen_random_uuid(), 'Medir el progreso de la programación por líneas de código es como medir el avance de la construcción de aviones por peso.', 'Bill Gates', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Lanza pronto. Lanza a menudo. Y escucha a tus usuarios.', 'Eric S. Raymond', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['discipline', 'focus', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'La mayoría de los buenos programadores programan no porque esperen que les paguen, sino porque es divertido programar.', 'Linus Torvalds', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'discipline', 'self_improvement'], true, 'coding'),
(gen_random_uuid(), 'Los sistemas que están rotos por diseño no pueden arreglarse con políticas.', 'Jeff Dean', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'discipline', 'focus'], true, 'coding'),
(gen_random_uuid(), 'Un mal programador puede crear fácilmente dos nuevos puestos de trabajo al año.', 'David Parnas', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['wisdom', 'learning', 'discipline'], true, 'coding'),
(gen_random_uuid(), 'La computadora nació para resolver problemas que antes no existían.', 'Bill Gates', 'philosophy', 'es', 'down', 'free', false, 'coding', 'devops_tools', ARRAY['creativity', 'curiosity', 'learning'], true, 'coding')
ON CONFLICT (text, author) DO NOTHING;

COMMIT;
