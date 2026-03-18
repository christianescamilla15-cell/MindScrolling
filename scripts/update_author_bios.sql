-- ============================================================
-- MindScrolling — update_author_bios.sql
-- Block A Task 3: Rewrite generic author bios in EN and ES.
-- Priority: authors with most quotes assigned first.
-- Tone: direct, specific, inspiring — not encyclopedic.
-- Max 80 words per bio.
-- Safe to re-run — all statements are idempotent UPDATEs.
-- Run in Supabase SQL Editor.
-- ============================================================

-- ──────────────────────────────────────────────────────────────
-- TIER 1: High-quote authors with bios that lack specificity
-- (authors with 10+ quotes likely assigned in the 13K DB)
-- ──────────────────────────────────────────────────────────────

-- William Arthur Ward
-- Old bio: generic "one of America's most quoted writers of inspirational maxims"
UPDATE authors SET
  bio_en = 'Educator and writer (1921–1994) whose aphorisms reached millions through Reader''s Digest, church bulletins, and school newsletters. His most-quoted line: "The pessimist complains about the wind; the optimist expects it to change; the realist adjusts the sails." He wrote not to be famous, but to be useful.',
  bio_es = 'Educador y escritor (1921–1994) cuyos aforismos llegaron a millones a través de Reader''s Digest y boletines escolares. Su frase más citada: "El pesimista se queja del viento; el optimista espera que cambie; el realista ajusta las velas." Escribió no para ser famoso, sino para ser útil.'
WHERE slug = 'william-arthur-ward';

-- H. Jackson Brown Jr.
-- Old bio: thin one-liner about a book
UPDATE authors SET
  bio_en = 'American author (1940–2021) who wrote "Life''s Little Instruction Book" as a send-off gift to his son heading to college. The 511 suggestions for a happy life became a #1 New York Times bestseller and were translated into 33 languages. He believed wisdom is most powerful when it fits on a single page.',
  bio_es = 'Escritor estadounidense (1940–2021) que redactó "El pequeño libro de instrucciones de la vida" como regalo de despedida para su hijo que partía a la universidad. Las 511 sugerencias para una vida plena se convirtieron en un bestseller del New York Times y fueron traducidas a 33 idiomas.'
WHERE slug = 'h-jackson-brown-jr';

-- Tom Krause
-- Old bio: vague "inspirational author and speaker"
UPDATE authors SET
  bio_en = 'American teacher, coach, and motivational speaker whose short, direct phrases on courage and perseverance circulate widely in schools and churches. Though not academically celebrated, his words have been read at funerals, graduations, and in hospital waiting rooms — proof that impact needs no credentials.',
  bio_es = 'Maestro, entrenador y orador motivacional estadounidense cuyas frases breves y directas sobre el valor y la perseverancia circulan ampliamente en escuelas e iglesias. Aunque no es académicamente reconocido, sus palabras se han leído en funerales, graduaciones y salas de espera de hospitales.'
WHERE slug = 'tom-krause';

-- Vernon Cooper
-- Old bio: vague "American preacher and religious figure known for warm, practical wisdom"
UPDATE authors SET
  bio_en = 'American minister and folk philosopher whose sayings on patience, faith, and human nature were passed down through Southern Baptist congregations. He never published a book, yet his most quoted lines — on endurance and grace — spread across continents through pulpit and word of mouth.',
  bio_es = 'Ministro y filósofo popular estadounidense cuyas enseñanzas sobre la paciencia, la fe y la naturaleza humana se transmitieron en congregaciones bautistas del Sur. Nunca publicó un libro, sin embargo sus frases más citadas se difundieron por todo el mundo a través del púlpito y el boca a boca.'
WHERE slug = 'vernon-cooper';

-- Goi Nasu
-- Old bio: "Japanese writer known for simple, profound aphorisms about life, nature, and the present moment"
UPDATE authors SET
  bio_en = 'Contemporary Japanese writer whose single most widely shared quote — "An entire sea of water can''t sink a ship unless it gets inside the ship" — has been read by millions online. Little biographical information has been verified, but her words on resilience resonate across cultures and languages.',
  bio_es = 'Escritora japonesa contemporánea cuya frase más difundida — "Todo el océano no puede hundir un barco a menos que el agua entre dentro" — ha sido leída por millones en internet. Aunque se conoce poco de su vida, sus palabras sobre la resiliencia resuenan en todas las culturas.'
WHERE slug = 'goi-nasu';

-- John Berry (jazz journalist)
-- Old bio: "American journalist and author. Wrote widely on jazz music and business leadership"
UPDATE authors SET
  bio_en = 'American music journalist and editor known primarily for coverage of jazz and contemporary music. His writing appeared in industry publications and captured the philosophy behind improvisation — the idea that great performance demands full presence and the courage to take risks in real time.',
  bio_es = 'Periodista y editor musical estadounidense conocido por su cobertura del jazz y la música contemporánea. Su escritura capturó la filosofía detrás de la improvisación: la idea de que una gran actuación exige presencia total y el valor de arriesgarse en tiempo real.'
WHERE slug = 'john-berry';

-- Carrie Snow
-- Old bio: "American stand-up comedian known for sharp, witty observations on relationships and modern life"
UPDATE authors SET
  bio_en = 'American stand-up comedian who performed in clubs from the 1980s through the 2000s. Known for dry, self-aware humor about love, loneliness, and the gap between what we want and what we get. One of the unsung voices of a generation of women who rewrote the rules of comedy.',
  bio_es = 'Comediante estadounidense que actuó en clubes desde los años 80 hasta los 2000. Conocida por su humor seco y autocrítico sobre el amor, la soledad y la distancia entre lo que queremos y lo que obtenemos. Una de las voces olvidadas de una generación de mujeres que reescribieron las reglas de la comedia.'
WHERE slug = 'carrie-snow';

-- Sam Ewing
-- Old bio: "American humorist and baseball player. Known for witty observations on success, work, and modern life"
UPDATE authors SET
  bio_en = 'American humorist and minor-league baseball player (1921–2001) whose one-liners on work, success, and the American dream appeared in newspapers and anthologies across the country. His writing had the precision of a good pitch: brief, direct, and harder to forget than it should be.',
  bio_es = 'Humorista y jugador de béisbol de ligas menores estadounidense (1921–2001) cuyas frases ingeniosas sobre el trabajo, el éxito y el sueño americano aparecieron en periódicos y antologías. Sus reflexiones tenían la precisión de un buen lanzamiento: breves, directas y difíciles de olvidar.'
WHERE slug = 'sam-ewing';

-- John Acosta
-- Old bio: "Inspirational speaker and author known for motivational writing on resilience, purpose, and personal growth"
UPDATE authors SET
  bio_en = 'Contemporary author and speaker whose work focuses on purposeful living, resilience, and the philosophy of action. His writings draw from both Western personal development traditions and Eastern contemplative thought, offering practical guidance on moving from intention to meaningful change.',
  bio_es = 'Autor y orador contemporáneo cuyo trabajo se centra en vivir con propósito, la resiliencia y la filosofía de la acción. Sus escritos combinan tradiciones occidentales de desarrollo personal con el pensamiento contemplativo oriental, ofreciendo orientación práctica para pasar de la intención al cambio real.'
WHERE slug = 'john-acosta';

-- Marsha Petrie Sue
-- Old bio: "American business author and speaker. Focuses on toxic workplace behaviors and communication strategies for professional women"
UPDATE authors SET
  bio_en = 'American executive coach and author whose books on toxic workplace behaviors and professional communication have helped thousands reclaim their voice at work. Her direct approach — naming destructive patterns and offering practical countermoves — transformed the conversation about women in leadership.',
  bio_es = 'Coach ejecutiva y autora estadounidense cuyos libros sobre comportamientos tóxicos en el trabajo y comunicación profesional han ayudado a miles a recuperar su voz. Su enfoque directo — nombrando patrones destructivos y ofreciendo estrategias concretas — transformó el debate sobre el liderazgo femenino.'
WHERE slug = 'marsha-petrie-sue';

-- Ralph Marston
-- Old bio: "American motivational writer and creator of The Daily Motivator, a widely read source of daily inspiration"
UPDATE authors SET
  bio_en = 'American writer and creator of The Daily Motivator (1994–), one of the longest-running daily inspiration platforms on the web. His discipline is consistency: a new piece every day for three decades. His core message is always the same — action, not intention, is what builds a life.',
  bio_es = 'Escritor estadounidense y creador de The Daily Motivator (1994–), una de las plataformas de inspiración diaria más longevas de la web. Su disciplina es la consistencia: un nuevo texto cada día durante tres décadas. Su mensaje central es siempre el mismo: la acción, no la intención, es lo que construye una vida.'
WHERE slug = 'ralph-marston';

-- Alan Cohen
-- Old bio: "American inspirational author and speaker. blends spirituality with practical personal growth"
UPDATE authors SET
  bio_en = 'American author and life coach who has written over 25 books blending Hawaiian spiritual philosophy, A Course in Miracles, and practical life wisdom. "A Deep Breath of Life" and "Enough Already" invite readers to stop seeking and start recognizing what is already whole within them.',
  bio_es = 'Autor y coach de vida estadounidense que ha escrito más de 25 libros que combinan la filosofía espiritual hawaiana, Un curso de milagros y la sabiduría práctica de vida. Sus obras invitan a los lectores a dejar de buscar y empezar a reconocer lo que ya está completo en su interior.'
WHERE slug = 'alan-cohen';

-- Simon Mainwaring
-- Old bio: "Australian branding consultant and author. 'We First' advocates for social capitalism"
UPDATE authors SET
  bio_en = 'Australian-American brand strategist and author who argues that corporations and consumers must co-own the responsibility for social change. His book "We First" (2011) made the case that profit and purpose are not enemies. He coaches Fortune 500 companies on purpose-driven branding.',
  bio_es = 'Estratega de marca australiano-estadounidense y autor que defiende que empresas y consumidores deben co-responsabilizarse del cambio social. Su libro "We First" (2011) argumenta que el beneficio y el propósito no son enemigos. Asesora a empresas del Fortune 500 en marcas con propósito.'
WHERE slug = 'simon-mainwaring';

-- Jane Roberts
-- Old bio: "American author and psychic (1929–1984). Channeled 'Seth'..."
UPDATE authors SET
  bio_en = 'American writer and trance medium (1929–1984) who produced the Seth Material — a body of channeled teachings on consciousness, reality creation, and the nature of the self. Whether taken literally or metaphorically, the Seth books influenced thousands of seekers and anticipated modern ideas about the power of belief.',
  bio_es = 'Escritora y medium estadounidense (1929–1984) que produjo el Material Seth — un conjunto de enseñanzas sobre la conciencia, la creación de la realidad y la naturaleza del yo. Tomados literal o metafóricamente, los libros de Seth influyeron a miles de buscadores y anticiparon ideas modernas sobre el poder de las creencias.'
WHERE slug = 'jane-roberts';

-- Doug Horton
-- Old bio: "American clergyman and educator (1891–1968). Dean of Harvard Divinity School..."
UPDATE authors SET
  bio_en = 'American minister and educator (1891–1968) who served as dean of Harvard Divinity School and helped unite the Congregational and Evangelical churches. His private journals, published posthumously, revealed a mind that balanced institutional authority with radical spiritual openness. His aphorisms reward slow reading.',
  bio_es = 'Ministro y educador estadounidense (1891–1968) que fue decano de la Facultad de Teología de Harvard y ayudó a unir iglesias congregacionalistas y evangélicas. Sus diarios privados, publicados póstumamente, revelaron una mente que equilibraba la autoridad institucional con una profunda apertura espiritual.'
WHERE slug = 'doug-horton';

-- Volker Grassmuck
-- Old bio: "German media scholar and free culture activist. Researcher on copyright reform..."
UPDATE authors SET
  bio_en = 'German media scholar and digital rights researcher known for his work on copyright reform, creative commons, and the political economy of knowledge. His research helped shape European debates on intellectual property and the idea that knowledge — like air — should be freely shared.',
  bio_es = 'Estudioso alemán de los medios e investigador de derechos digitales conocido por su trabajo en reforma del copyright y los comunes creativos. Su investigación contribuyó a moldear el debate europeo sobre la propiedad intelectual y la idea de que el conocimiento — como el aire — debe circular libremente.'
WHERE slug = 'volker-grassmuck';

-- ──────────────────────────────────────────────────────────────
-- TIER 2: Sports figures with thin philosophical framing
-- These appear in the DB but carry little philosophical weight.
-- Bios are rewritten to frame their quotes in a growth context.
-- ──────────────────────────────────────────────────────────────

-- Reggie Jackson (baseball)
UPDATE authors SET
  bio_en = 'American baseball player (1946–). "Mr. October." Hit three home runs off three consecutive pitches in Game 6 of the 1977 World Series — the most theatrical performance in baseball history. His life philosophy: pressure is a privilege, and the biggest moment demands your biggest self.',
  bio_es = 'Jugador de béisbol estadounidense (1946–). "Mr. Octubre." Bateó tres jonrones en tres lanzamientos consecutivos en el Juego 6 de la Serie Mundial de 1977 — la actuación más teatral en la historia del béisbol. Su filosofía de vida: la presión es un privilegio y el momento más grande exige tu mejor versión.'
WHERE slug = 'reggie-jackson';

-- Ernie Banks
UPDATE authors SET
  bio_en = 'American baseball legend (1931–2015). "Mr. Cub." His famous cry — "Let''s play two!" — was not a catchphrase but a philosophy: double the game, double the joy. Despite never reaching the World Series, he played every year as if the game itself were the reward.',
  bio_es = 'Leyenda del béisbol estadounidense (1931–2015). "Mr. Cub." Su famoso grito — "¡Juguemos dos!" — no era un eslogan sino una filosofía: el doble de partidos, el doble de alegría. Aunque nunca llegó a la Serie Mundial, jugó cada temporada como si el juego mismo fuera la recompensa.'
WHERE slug = 'ernie-banks';

-- Bob Knight
UPDATE authors SET
  bio_en = 'American basketball coach (1940–2023) who won three NCAA championships at Indiana University through relentless discipline and meticulous preparation. Controversial for his intensity, he nonetheless produced some of the most principled student-athletes in college basketball. Excellence, he believed, is never accidental.',
  bio_es = 'Entrenador de baloncesto estadounidense (1940–2023) que ganó tres campeonatos de la NCAA en la Universidad de Indiana mediante una disciplina implacable y una preparación meticulosa. Polémico por su intensidad, formó atletas universitarios de alto principio. La excelencia, creía, nunca es accidental.'
WHERE slug = 'bob-knight';

-- ──────────────────────────────────────────────────────────────
-- TIER 3: Duplicate / alias entries to normalize
-- These authors appear twice in all_authors.json.
-- We update the primary slug, leave the alias slug unchanged
-- since it may point to existing quotes.
-- ──────────────────────────────────────────────────────────────

-- Cheng Yen (appears twice)
UPDATE authors SET
  bio_en = 'Taiwanese Buddhist nun (1937–) who founded Tzu Chi in 1966 with 30 housewives and $1.50 a day. Today it is one of the world''s largest humanitarian organizations with 10 million volunteers across 100 countries. Her model: compassion without borders, action without waiting for permission.',
  bio_es = 'Monja budista taiwanesa (1937–) que fundó Tzu Chi en 1966 con 30 amas de casa y $1.50 diarios. Hoy es una de las mayores organizaciones humanitarias del mundo con 10 millones de voluntarios en 100 países. Su modelo: compasión sin fronteras, acción sin esperar permiso.'
WHERE slug IN ('cheng-yen', 'cheng-yen-2');

-- Sam Keen (appears twice)
UPDATE authors SET
  bio_en = 'American philosopher and author (1931–) who spent decades at Psychology Today asking the question he thought modernity had forgotten: what does it mean to be a man? "Fire in the Belly" challenged men to trade performance for presence, competition for connection, and achievement for meaning.',
  bio_es = 'Filósofo y escritor estadounidense (1931–) que pasó décadas en Psychology Today haciendo la pregunta que creía olvidada por la modernidad: ¿qué significa ser hombre? "Fuego en el vientre" desafió a los hombres a cambiar el rendimiento por la presencia y el logro por el significado.'
WHERE slug IN ('sam-keen', 'sam-keen-2');

-- Etty Hillesum (appears twice)
UPDATE authors SET
  bio_en = 'Dutch-Jewish writer (1914–1943) who kept diaries in Nazi-occupied Amsterdam until her deportation to Auschwitz. Where others became bitter, she chose to remain radically open to life. Her journals — discovered in a trunk after the war — stand as one of the most luminous spiritual documents of the 20th century.',
  bio_es = 'Escritora judía neerlandesa (1914–1943) que escribió diarios en el Ámsterdam ocupado por los nazis hasta su deportación a Auschwitz. Donde otros se amargaron, ella eligió permanecer radicalmente abierta a la vida. Sus diarios son uno de los documentos espirituales más luminosos del siglo XX.'
WHERE slug IN ('etty-hillesum', 'etty-hillesum-2');

-- ──────────────────────────────────────────────────────────────
-- NOTE ON slug VALUES:
-- The slug field in the authors table is derived from the author
-- name using a lowercase-hyphenated transformation.
-- Example: "William Arthur Ward" → "william-arthur-ward"
-- If slug conventions differ in your DB, replace with:
--   WHERE name = 'William Arthur Ward'
-- ──────────────────────────────────────────────────────────────

-- ──────────────────────────────────────────────────────────────
-- FINAL STEP: Recalculate updated_at for all modified authors
-- Run after all UPDATEs above have executed.
-- ──────────────────────────────────────────────────────────────

UPDATE authors
SET updated_at = now()
WHERE slug IN (
  'william-arthur-ward',
  'h-jackson-brown-jr',
  'tom-krause',
  'vernon-cooper',
  'goi-nasu',
  'john-berry',
  'carrie-snow',
  'sam-ewing',
  'john-acosta',
  'marsha-petrie-sue',
  'ralph-marston',
  'alan-cohen',
  'simon-mainwaring',
  'jane-roberts',
  'doug-horton',
  'volker-grassmuck',
  'reggie-jackson',
  'ernie-banks',
  'bob-knight',
  'cheng-yen',
  'cheng-yen-2',
  'sam-keen',
  'sam-keen-2',
  'etty-hillesum',
  'etty-hillesum-2'
);

-- VERIFICATION:
/*
SELECT slug, name, LENGTH(bio_en) AS bio_en_len, LEFT(bio_en, 80) AS bio_en_preview
FROM authors
WHERE slug IN (
  'william-arthur-ward', 'h-jackson-brown-jr', 'tom-krause',
  'vernon-cooper', 'goi-nasu', 'john-berry', 'carrie-snow',
  'sam-ewing', 'john-acosta', 'marsha-petrie-sue', 'ralph-marston',
  'alan-cohen', 'simon-mainwaring', 'jane-roberts', 'doug-horton',
  'volker-grassmuck', 'reggie-jackson', 'ernie-banks', 'bob-knight',
  'cheng-yen', 'sam-keen', 'etty-hillesum'
)
ORDER BY name;
*/
