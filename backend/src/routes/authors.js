import { supabase } from "../db/client.js";

export default async function authorsRoutes(fastify) {
  /**
   * GET /authors/:name
   * Returns author profile with bio and top quotes.
   * Query: ?lang=en|es
   */
  fastify.get("/:name", async (request, reply) => {
    const { name } = request.params;
    const lang = request.query.lang || "en";

    if (!name) {
      return reply.status(400).send({ error: "Author name required", code: "MISSING_FIELD" });
    }

    const decodedName = decodeURIComponent(name);

    // Get quotes by this author
    const { data: quotes, error } = await supabase
      .from("quotes")
      .select("id, text, category, lang")
      .eq("author", decodedName)
      .eq("lang", lang)
      .order("created_at", { ascending: false })
      .limit(20);

    if (error) {
      return reply.status(500).send({ error: "Failed to fetch author", code: "DB_ERROR" });
    }

    // Count total quotes
    const { count } = await supabase
      .from("quotes")
      .select("*", { count: "exact", head: true })
      .eq("author", decodedName)
      .eq("lang", lang);

    // Category distribution
    const categories = {};
    (quotes || []).forEach((q) => {
      categories[q.category] = (categories[q.category] || 0) + 1;
    });

    // Dominant category
    const dominant = Object.entries(categories)
      .sort(([, a], [, b]) => b - a)[0]?.[0] ?? "philosophy";

    // Generate bio from known authors
    const bio = getAuthorBio(decodedName, lang);

    return reply.send({
      name: decodedName,
      bio,
      total_quotes: count || 0,
      dominant_category: dominant,
      categories,
      top_quotes: (quotes || []).slice(0, 5).map((q) => ({
        id: q.id,
        text: q.text,
        category: q.category,
      })),
    });
  });
}

/**
 * Returns a short bio for known authors. Falls back to a generic description.
 */
function getAuthorBio(name, lang) {
  const bios = {
    en: {
      "Marcus Aurelius": "Roman Emperor (161–180 AD) and the last of the Five Good Emperors. His private journal 'Meditations', written during military campaigns, became one of the greatest Stoic texts ever composed.",
      "Seneca": "Roman Stoic philosopher, statesman, and playwright (4 BC–65 AD). Advisor to Emperor Nero. His 'Letters to Lucilius' and 'On the Shortness of Life' remain essential reading on how to live well.",
      "Epictetus": "Born into slavery in Phrygia (c. 50–135 AD), he gained freedom and founded a school of philosophy. His 'Discourses' and 'Enchiridion' teach that freedom comes from mastering our reactions.",
      "Plato": "Athenian philosopher (428–348 BC), student of Socrates, teacher of Aristotle. Founded the Academy in Athens. His dialogues — 'The Republic', 'Symposium', 'Phaedo' — shaped Western thought for 2,400 years.",
      "Aristotle": "Greek philosopher and polymath (384–322 BC). Studied under Plato, tutored Alexander the Great. Created formal logic, wrote on ethics, politics, biology, and poetics. Called 'The Philosopher' in the Middle Ages.",
      "Socrates": "Athenian philosopher (470–399 BC) who wrote nothing but changed everything. His method of relentless questioning exposed contradictions in people's beliefs. Sentenced to death for 'corrupting the youth.'",
      "Friedrich Nietzsche": "German philosopher (1844–1900) who declared 'God is dead' and challenged all conventional morality. His concepts of the Übermensch, eternal recurrence, and will to power reshaped modern philosophy.",
      "Albert Einstein": "German-born theoretical physicist (1879–1955) who revolutionized physics with the theory of relativity and E=mc². Nobel Prize in 1921. Fled Nazi Germany, became an American citizen and peace advocate.",
      "Confucius": "Chinese philosopher and teacher (551–479 BC) whose ideas on ethics, family, and governance became the foundation of East Asian civilization. His 'Analects' have guided billions of lives across 25 centuries.",
      "Buddha": "Siddhartha Gautama (c. 563–483 BC), born a prince in Nepal, renounced wealth to seek enlightenment. Founded Buddhism. His Four Noble Truths and Eightfold Path offer a practical guide to ending suffering.",
      "Lao Tzu": "Semi-legendary Chinese philosopher (6th century BC), traditionally credited as author of the 'Tao Te Ching'. His philosophy of wu wei (effortless action) and living in harmony with the Tao shaped Taoism.",
      "Albert Camus": "French-Algerian philosopher and novelist (1913–1960). Nobel Prize in Literature at age 44. His works 'The Stranger', 'The Plague', and 'The Myth of Sisyphus' explore the absurdity of existence and human revolt.",
      "Ralph Waldo Emerson": "American essayist, poet, and leader of the Transcendentalist movement (1803–1882). His essays 'Self-Reliance' and 'Nature' championed individualism, nonconformity, and the divinity within every person.",
      "Winston Churchill": "British Prime Minister (1874–1965) who led Britain through World War II. Nobel Prize in Literature. Known for his defiant speeches: 'We shall never surrender.' Also a painter, historian, and wit.",
      "Richard Bach": "American writer (1936–) best known for 'Jonathan Livingston Seagull' (1970), a fable about a seagull who seeks perfection in flight. His works explore themes of self-discovery, freedom, and transcendence.",
      "Abraham Lincoln": "16th President of the United States (1809–1865). Led the nation through the Civil War and abolished slavery. Self-educated from frontier poverty to become one of history's greatest leaders.",
      "Wayne Dyer": "American self-help author and motivational speaker (1940–2015). Known as 'the father of motivation.' His book 'Your Erroneous Zones' sold 100 million copies. Later works explored Taoist and spiritual philosophy.",
      "Thomas Edison": "American inventor (1847–1931) who held 1,093 patents. Created the phonograph, practical light bulb, and motion picture camera. His Menlo Park laboratory was the world's first industrial research lab.",
      "Woody Allen": "American filmmaker, writer, and comedian (1935–). Directed over 50 films including 'Annie Hall', 'Manhattan', and 'Midnight in Paris'. Known for neurotic humor and existential themes in his work.",
      "Carl Jung": "Swiss psychiatrist (1875–1961) who founded analytical psychology. Introduced concepts of the collective unconscious, archetypes, introversion/extraversion, and synchronicity. Broke from Freud to forge his own path.",
      "Napoleon Hill": "American self-help author (1883–1970). His book 'Think and Grow Rich' (1937), based on interviews with 500 millionaires including Andrew Carnegie, became one of the best-selling books of all time.",
      "Dalai Lama": "Tenzin Gyatso (1935–), the 14th Dalai Lama, spiritual leader of Tibetan Buddhism. Nobel Peace Prize in 1989. In exile since 1959, he teaches compassion, nonviolence, and interfaith dialogue worldwide.",
      "Bruce Lee": "Martial artist, actor, and philosopher (1940–1973). Founded Jeet Kune Do. His philosophy of adaptability ('Be water, my friend') transcended martial arts to influence business, art, and personal development.",
      "Tony Robbins": "American motivational speaker and life coach (1960–). Known for his seminars, bestselling books 'Awaken the Giant Within' and 'Unlimited Power'. Coaches world leaders, athletes, and entrepreneurs.",
      "Benjamin Franklin": "American polymath, Founding Father (1706–1790). Scientist, inventor, diplomat, printer, and philosopher. Discovered electricity's nature, invented the lightning rod and bifocals. Author of 'Poor Richard's Almanack.'",
      "Oscar Wilde": "Irish poet, playwright, and wit (1854–1900). Author of 'The Picture of Dorian Gray' and 'The Importance of Being Earnest'. Imprisoned for homosexuality, wrote 'De Profundis' from his cell.",
      "Henry David Thoreau": "American naturalist and philosopher (1817–1862). Lived alone at Walden Pond for two years. His book 'Walden' and essay 'Civil Disobedience' inspired Gandhi, Martin Luther King Jr., and environmentalism.",
      "Mark Twain": "American writer and humorist (1835–1910), born Samuel Clemens. Author of 'Adventures of Huckleberry Finn' and 'Tom Sawyer'. Called 'the father of American literature' by William Faulkner.",
      "Maya Angelou": "American poet, memoirist, and civil rights activist (1928–2014). Her autobiography 'I Know Why the Caged Bird Sings' broke literary ground. Recited poetry at President Clinton's inauguration.",
      "Blaise Pascal": "French mathematician, physicist, and philosopher (1623–1662). Invented the first mechanical calculator and laid groundwork for probability theory. His 'Pensées' explored faith, reason, and the human condition.",
      "Johann Wolfgang von Goethe": "German writer and polymath (1749–1832). Author of 'Faust', the defining work of German literature. Also a scientist, statesman, and theater director. Influenced Romanticism across Europe.",
      "Eleanor Roosevelt": "American political figure and activist (1884–1962). As First Lady, she transformed the role into a platform for human rights. Chaired the UN committee that drafted the Universal Declaration of Human Rights.",
      "William Shakespeare": "English playwright and poet (1564–1616). Wrote 37 plays and 154 sonnets that defined the English language. 'Hamlet', 'Macbeth', 'Romeo and Juliet' — his works explore every dimension of human nature.",
      "Mother Teresa": "Albanian-Indian Catholic nun (1910–1997). Founded the Missionaries of Charity in Calcutta. Nobel Peace Prize in 1979 for her work with the poorest of the poor. Canonized as a saint in 2016.",
      "Napoleon": "French military leader and Emperor (1769–1821). Rose from Corsican obscurity to conquer most of Europe. His Napoleonic Code reformed legal systems worldwide. Exiled to St. Helena, where he died.",
      "Pablo Picasso": "Spanish painter and sculptor (1881–1973). Co-founded Cubism, created over 50,000 artworks including 'Guernica'. The most influential artist of the 20th century, constantly reinventing his style.",
      "Viktor Frankl": "Austrian psychiatrist and Holocaust survivor (1905–1997). His book 'Man's Search for Meaning' describes finding purpose in Auschwitz. Founded logotherapy — healing through meaning rather than pleasure.",
      "Mahatma Gandhi": "Indian independence leader (1869–1948). Developed nonviolent resistance (satyagraha) that freed India from British rule. His philosophy of peaceful protest inspired civil rights movements worldwide.",
      "Charles Dickens": "English novelist (1812–1870). His works — 'Oliver Twist', 'A Christmas Carol', 'Great Expectations' — exposed social injustice and created some of fiction's most memorable characters.",
      "John Lennon": "English musician and peace activist (1940–1980). Co-founded The Beatles. His song 'Imagine' became an anthem for peace. With Yoko Ono, staged Bed-Ins for Peace during the Vietnam War.",
      "Helen Keller": "American author and activist (1880–1968). Deaf and blind from 19 months old, she became the first deafblind person to earn a bachelor's degree. Her life proved that no obstacle is insurmountable.",
      "Epicurus": "Greek philosopher (341–270 BC) who founded Epicureanism. Taught that pleasure (especially friendship and intellectual contemplation) is the highest good, and that death is nothing to fear.",
      "Bertrand Russell": "British philosopher, logician, and Nobel laureate (1872–1970). Co-authored 'Principia Mathematica'. Campaigned for nuclear disarmament and civil liberties. One of the 20th century's greatest public intellectuals.",
      "Jean-Paul Sartre": "French existentialist philosopher (1905–1980). His maxim 'existence precedes essence' defined existentialism. Declined the Nobel Prize. Author of 'Being and Nothingness' and 'No Exit.'",
      "Rumi": "13th-century Persian poet and Sufi mystic (1207–1273). His poetry collection 'Masnavi' is called 'the Quran in Persian.' 800 years later, he remains one of the world's best-selling poets.",
      "Victor Hugo": "French novelist, poet, and political activist (1802–1885). Author of 'Les Misérables' and 'The Hunchback of Notre-Dame'. Fought for social justice, abolished the death penalty in literary imagination.",
      "Antoine de Saint-Exupéry": "French aviator and writer (1900–1944). Author of 'The Little Prince', one of the most translated books in history. Disappeared on a reconnaissance flight over the Mediterranean during WWII.",
      "Ernest Hemingway": "American novelist and journalist (1899–1961). Nobel Prize in Literature. His spare, direct prose in 'The Old Man and the Sea', 'A Farewell to Arms', and 'For Whom the Bell Tolls' redefined modern fiction.",
      "Immanuel Kant": "German philosopher (1724–1804). Never traveled more than 10 miles from his hometown, yet his 'Critique of Pure Reason' revolutionized philosophy. His categorical imperative remains central to modern ethics.",
      "William James": "American philosopher and psychologist (1842–1910). Father of American psychology. His works 'Pragmatism' and 'The Varieties of Religious Experience' bridged philosophy, science, and spirituality.",
      "Sophocles": "Greek tragedian (496–406 BC). Wrote over 120 plays; seven survive, including 'Oedipus Rex' and 'Antigone'. Introduced the third actor to Greek theater and expanded the chorus from 12 to 15 members.",
      "Thích Nhất Hạnh": "Vietnamese Buddhist monk and peace activist (1926–2022). Coined the term 'engaged Buddhism.' Martin Luther King Jr. nominated him for the Nobel Prize. His books on mindfulness sold millions worldwide.",
      "Leonardo da Vinci": "Italian polymath (1452–1519). Painter of the Mona Lisa and The Last Supper. Also an inventor, scientist, architect, and anatomist. His notebooks reveal a mind centuries ahead of its time.",
      "Voltaire": "French Enlightenment writer and philosopher (1694–1778). Champion of free speech, separation of church and state, and civil liberties. His satirical novel 'Candide' mocked religious and philosophical optimism.",
      "Heraclitus": "Greek philosopher (c. 535–475 BC) from Ephesus, known as 'The Obscure.' Famous for 'No man steps in the same river twice' — everything flows (panta rhei). Fire, he believed, was the fundamental element.",
      "René Descartes": "French philosopher and mathematician (1596–1650). 'I think, therefore I am' is philosophy's most famous sentence. Founded modern rationalism, invented the coordinate system, and changed how we understand the mind.",
      "Ludwig Wittgenstein": "Austrian-British philosopher (1889–1951). His early 'Tractatus' and later 'Philosophical Investigations' are among the most important works in 20th-century philosophy. Gave away his inheritance to focus on thought.",
      "Theodore Roosevelt": "26th U.S. President (1858–1919). Youngest president in history. Led the Rough Riders, built the Panama Canal, won the Nobel Peace Prize. Survived an assassination attempt and finished his speech with the bullet still lodged in his chest.",
      "Eckhart Tolle": "German-born spiritual teacher (1948–). His book 'The Power of Now' has sold millions and been translated into 52 languages. Teaches presence, consciousness, and transcending the ego.",
      "Soren Kierkegaard": "Danish philosopher (1813–1855), considered the father of existentialism. His works — 'Fear and Trembling', 'Either/Or' — explored anxiety, despair, and the leap of faith before existentialism had a name.",
      "Nelson Mandela": "South African anti-apartheid leader (1918–2013). Imprisoned for 27 years, emerged without bitterness to become South Africa's first Black president. Nobel Peace Prize in 1993. Symbol of reconciliation.",
      "Plutarch": "Greek biographer and essayist (c. 46–120 AD). His 'Parallel Lives' compared Greek and Roman heroes and influenced Shakespeare, the American Founding Fathers, and political thought for 2,000 years.",
      "Alan Watts": "British-American philosopher (1915–1973). Brought Eastern philosophy — Zen Buddhism, Taoism, Hinduism — to Western audiences through books and lectures. His 'The Way of Zen' remains a classic introduction.",
      "Sun Tzu": "Chinese military strategist (544–496 BC). Author of 'The Art of War', the oldest known treatise on military strategy. Its principles are now applied to business, sports, litigation, and personal development.",
      "Dale Carnegie": "American writer and lecturer (1888–1955). His book 'How to Win Friends and Influence People' (1936) has sold 30 million copies and remains the foundation of modern interpersonal communication skills.",
      "Coco Chanel": "French fashion designer (1883–1971). Founded the House of Chanel, revolutionized women's fashion by liberating them from corsets. Created the little black dress, Chanel No. 5, and the concept of casual elegance.",
      "Oprah Winfrey": "American media mogul and philanthropist (1954–). Rose from poverty in rural Mississippi to become the most influential woman in media. Her talk show reached 10 million viewers daily for 25 years.",
      "Vince Lombardi": "American football coach (1913–1970). Led the Green Bay Packers to five NFL championships. The Super Bowl trophy bears his name. His philosophy: 'Winning isn't everything; it's the only thing.'",
      "Peter Drucker": "Austrian-American management consultant (1909–2005). Called 'the father of modern management.' Invented management by objectives, predicted the rise of knowledge workers, and shaped how organizations function.",
      "Fyodor Dostoevsky": "Russian novelist (1821–1881). Sentenced to death, reprieved at the last moment. Wrote 'Crime and Punishment', 'The Brothers Karamazov', and 'Notes from Underground' — deep explorations of morality, faith, and the human psyche.",
      "Benjamin Disraeli": "British Prime Minister and novelist (1804–1881). The only British PM to have been a published novelist before entering politics. Championed social reform and expanded the British Empire.",
      "Og Mandino": "American author (1923–1996). Overcame alcoholism and poverty to write 'The Greatest Salesman in the World', which sold 50 million copies. His inspirational works focus on personal transformation.",
      "Franklin D. Roosevelt": "32nd U.S. President (1882–1945). Led America through the Great Depression and World War II. Only president elected four times. His New Deal transformed the role of American government.",
      "Thomas Carlyle": "Scottish philosopher and historian (1795–1881). His 'Great Man' theory of history argued that heroes shape the world. His works on the French Revolution and hero-worship influenced Victorian thought.",
      "John F. Kennedy": "35th U.S. President (1917–1963). Inspired a generation with 'Ask not what your country can do for you.' Managed the Cuban Missile Crisis, launched the space race, and was assassinated in Dallas.",
      "Albert Schweitzer": "French-German theologian, physician, and Nobel laureate (1875–1965). Gave up a music career to build a hospital in Africa. His philosophy of 'reverence for life' became an ethical framework.",
      "Douglas Adams": "English author and humorist (1952–2001). Created 'The Hitchhiker's Guide to the Galaxy', answering life's ultimate question with '42'. His absurdist wit mixed science fiction with philosophical depth.",
      "Oliver Wendell Holmes Jr.": "American jurist (1841–1935). Served 30 years on the Supreme Court. His opinions on free speech ('clear and present danger') and legal realism shaped American constitutional law.",
      "Anatole France": "French novelist and Nobel laureate (1844–1924). Known for his ironic, elegant prose. Won the Nobel Prize in Literature in 1921. Championed social justice and intellectual freedom.",
      "Seneca the Younger": "Same as Seneca — Roman Stoic philosopher (4 BC–65 AD). The 'Younger' distinguishes him from his father, Seneca the Elder, who was a rhetorician.",
    },
    es: {
      "Marco Aurelio": "Emperador romano (161–180 d.C.) y último de los Cinco Buenos Emperadores. Su diario privado 'Meditaciones', escrito durante campañas militares, se convirtió en uno de los mayores textos estoicos jamás escritos.",
      "Séneca": "Filósofo estoico romano, estadista y dramaturgo (4 a.C.–65 d.C.). Consejero del emperador Nerón. Sus 'Cartas a Lucilio' y 'Sobre la brevedad de la vida' siguen siendo lectura esencial sobre cómo vivir bien.",
      "Epicteto": "Nacido esclavo en Frigia (c. 50–135 d.C.), obtuvo su libertad y fundó una escuela filosófica. Sus 'Discursos' y 'Enquiridión' enseñan que la libertad viene de dominar nuestras reacciones.",
      "Platón": "Filósofo ateniense (428–348 a.C.), discípulo de Sócrates y maestro de Aristóteles. Fundó la Academia en Atenas. Sus diálogos — 'La República', 'El Banquete', 'Fedón' — moldearon el pensamiento occidental por 2,400 años.",
      "Aristóteles": "Filósofo y polímata griego (384–322 a.C.). Estudió con Platón, fue tutor de Alejandro Magno. Creó la lógica formal, escribió sobre ética, política, biología y poética. Llamado 'El Filósofo' en la Edad Media.",
      "Sócrates": "Filósofo ateniense (470–399 a.C.) que no escribió nada pero lo cambió todo. Su método de interrogación incesante exponía las contradicciones en las creencias de la gente. Condenado a muerte por 'corromper a la juventud.'",
      "Friedrich Nietzsche": "Filósofo alemán (1844–1900) que declaró 'Dios ha muerto' y desafió toda moralidad convencional. Sus conceptos del Übermensch, el eterno retorno y la voluntad de poder redefinieron la filosofía moderna.",
      "Albert Einstein": "Físico teórico (1879–1955) que revolucionó la física con la teoría de la relatividad y E=mc². Premio Nobel en 1921. Huyó de la Alemania nazi, se hizo ciudadano estadounidense y defensor de la paz.",
      "Confucio": "Filósofo y maestro chino (551–479 a.C.) cuyas ideas sobre ética, familia y gobierno se convirtieron en el fundamento de la civilización de Asia Oriental. Sus 'Analectas' han guiado miles de millones de vidas.",
      "Buda": "Siddhartha Gautama (c. 563–483 a.C.), nacido príncipe en Nepal, renunció a su riqueza para buscar la iluminación. Fundó el budismo. Sus Cuatro Nobles Verdades ofrecen una guía práctica para acabar con el sufrimiento.",
      "Lao Tse": "Filósofo chino semilegendario (siglo VI a.C.), tradicionalmente considerado autor del 'Tao Te Ching'. Su filosofía del wu wei (acción sin esfuerzo) y vivir en armonía con el Tao dio forma al taoísmo.",
      "Albert Camus": "Filósofo y novelista franco-argelino (1913–1960). Premio Nobel de Literatura a los 44 años. Sus obras 'El extranjero', 'La peste' y 'El mito de Sísifo' exploran el absurdo de la existencia y la rebeldía humana.",
      "Ralph Waldo Emerson": "Ensayista, poeta y líder del movimiento trascendentalista estadounidense (1803–1882). Sus ensayos 'Autoconfianza' y 'Naturaleza' defendieron el individualismo y la divinidad dentro de cada persona.",
      "Winston Churchill": "Primer Ministro británico (1874–1965) que lideró a Gran Bretaña durante la Segunda Guerra Mundial. Premio Nobel de Literatura. Conocido por sus discursos desafiantes: 'Nunca nos rendiremos.'",
      "Richard Bach": "Escritor estadounidense (1936–) conocido por 'Juan Salvador Gaviota' (1970), una fábula sobre una gaviota que busca la perfección en vuelo. Sus obras exploran el autodescubrimiento y la trascendencia.",
      "Abraham Lincoln": "16° Presidente de Estados Unidos (1809–1865). Lideró la nación durante la Guerra Civil y abolió la esclavitud. Autodidacta desde la pobreza fronteriza hasta convertirse en uno de los más grandes líderes de la historia.",
      "Wayne Dyer": "Autor y orador motivacional estadounidense (1940–2015). Conocido como 'el padre de la motivación.' Su libro 'Tus zonas erróneas' vendió 100 millones de copias. Sus obras posteriores exploraron la filosofía taoísta.",
      "Thomas Edison": "Inventor estadounidense (1847–1931) con 1,093 patentes. Creó el fonógrafo, la bombilla práctica y la cámara de cine. Su laboratorio en Menlo Park fue el primer laboratorio de investigación industrial.",
      "Woody Allen": "Cineasta, escritor y comediante estadounidense (1935–). Dirigió más de 50 películas incluyendo 'Annie Hall', 'Manhattan' y 'Medianoche en París'. Conocido por su humor neurótico y temas existenciales.",
      "Carl Jung": "Psiquiatra suizo (1875–1961) que fundó la psicología analítica. Introdujo los conceptos del inconsciente colectivo, los arquetipos, introversión/extraversión y la sincronicidad. Se separó de Freud para forjar su propio camino.",
      "Napoleon Hill": "Autor de autoayuda estadounidense (1883–1970). Su libro 'Piense y hágase rico' (1937), basado en entrevistas con 500 millonarios, se convirtió en uno de los libros más vendidos de todos los tiempos.",
      "Dalai Lama": "Tenzin Gyatso (1935–), el 14° Dalai Lama, líder espiritual del budismo tibetano. Premio Nobel de la Paz en 1989. En exilio desde 1959, enseña compasión, no violencia y diálogo interreligioso.",
      "Bruce Lee": "Artista marcial, actor y filósofo (1940–1973). Fundó el Jeet Kune Do. Su filosofía de adaptabilidad ('Sé agua, amigo mío') trascendió las artes marciales para influir en negocios, arte y desarrollo personal.",
      "Tony Robbins": "Orador motivacional y coach de vida estadounidense (1960–). Conocido por sus seminarios y bestsellers 'Despertando al gigante interior' y 'Poder sin límites'. Asesora a líderes mundiales y atletas.",
      "Benjamin Franklin": "Polímata estadounidense y Padre Fundador (1706–1790). Científico, inventor, diplomático e impresor. Descubrió la naturaleza de la electricidad, inventó el pararrayos y las lentes bifocales.",
      "Oscar Wilde": "Poeta, dramaturgo e ingenio irlandés (1854–1900). Autor de 'El retrato de Dorian Gray' y 'La importancia de llamarse Ernesto'. Encarcelado por homosexualidad, escribió 'De Profundis' desde su celda.",
      "Henry David Thoreau": "Naturalista y filósofo estadounidense (1817–1862). Vivió solo en Walden Pond durante dos años. Su libro 'Walden' y ensayo 'Desobediencia civil' inspiraron a Gandhi y Martin Luther King Jr.",
      "Mark Twain": "Escritor y humorista estadounidense (1835–1910), nacido Samuel Clemens. Autor de 'Las aventuras de Huckleberry Finn'. William Faulkner lo llamó 'el padre de la literatura estadounidense.'",
      "Maya Angelou": "Poetisa, memorialista y activista estadounidense (1928–2014). Su autobiografía 'Yo sé por qué canta el pájaro enjaulado' rompió barreras literarias. Recitó poesía en la investidura del presidente Clinton.",
      "Blaise Pascal": "Matemático, físico y filósofo francés (1623–1662). Inventó la primera calculadora mecánica y sentó las bases de la teoría de la probabilidad. Sus 'Pensamientos' exploraron la fe y la condición humana.",
      "Johann Wolfgang von Goethe": "Escritor y polímata alemán (1749–1832). Autor de 'Fausto', la obra definitiva de la literatura alemana. También científico, estadista y director de teatro. Influyó en el Romanticismo europeo.",
      "Eleanor Roosevelt": "Figura política y activista estadounidense (1884–1962). Transformó el rol de Primera Dama en plataforma para los derechos humanos. Presidió el comité de la ONU que redactó la Declaración Universal de Derechos Humanos.",
      "William Shakespeare": "Dramaturgo y poeta inglés (1564–1616). Escribió 37 obras y 154 sonetos que definieron el idioma inglés. 'Hamlet', 'Macbeth', 'Romeo y Julieta' — sus obras exploran cada dimensión de la naturaleza humana.",
      "Madre Teresa": "Monja católica albano-india (1910–1997). Fundó las Misioneras de la Caridad en Calcuta. Premio Nobel de la Paz en 1979. Canonizada como santa en 2016.",
      "Napoleón": "Líder militar francés y Emperador (1769–1821). Ascendió de la oscuridad corsa a conquistar la mayor parte de Europa. Su Código Napoleónico reformó sistemas legales en todo el mundo.",
      "Pablo Picasso": "Pintor y escultor español (1881–1973). Cofundó el Cubismo, creó más de 50,000 obras incluyendo 'Guernica'. El artista más influyente del siglo XX, reinventando constantemente su estilo.",
      "Viktor Frankl": "Psiquiatra austríaco y sobreviviente del Holocausto (1905–1997). Su libro 'El hombre en busca de sentido' describe cómo encontrar propósito en Auschwitz. Fundó la logoterapia — sanación a través del significado.",
      "Mahatma Gandhi": "Líder independentista indio (1869–1948). Desarrolló la resistencia no violenta (satyagraha) que liberó a India del dominio británico. Su filosofía inspiró movimientos de derechos civiles en todo el mundo.",
      "Charles Dickens": "Novelista inglés (1812–1870). Sus obras — 'Oliver Twist', 'Canción de Navidad', 'Grandes esperanzas' — denunciaron la injusticia social y crearon algunos de los personajes más memorables de la ficción.",
      "John Lennon": "Músico y activista por la paz (1940–1980). Cofundó The Beatles. Su canción 'Imagine' se convirtió en himno de la paz. Con Yoko Ono, realizó las 'Camas por la Paz' durante la Guerra de Vietnam.",
      "Helen Keller": "Autora y activista estadounidense (1880–1968). Sorda y ciega desde los 19 meses, fue la primera persona sordociega en obtener un título universitario. Su vida demostró que ningún obstáculo es insuperable.",
      "Epicuro": "Filósofo griego (341–270 a.C.) que fundó el epicureísmo. Enseñó que el placer (especialmente la amistad y la contemplación intelectual) es el bien supremo, y que la muerte no es nada que temer.",
      "Bertrand Russell": "Filósofo, lógico y Nobel británico (1872–1970). Coautor de 'Principia Mathematica'. Activista por el desarme nuclear y las libertades civiles. Uno de los mayores intelectuales públicos del siglo XX.",
      "Jean-Paul Sartre": "Filósofo existencialista francés (1905–1980). Su máxima 'la existencia precede a la esencia' definió el existencialismo. Rechazó el Nobel. Autor de 'El ser y la nada' y 'A puerta cerrada.'",
      "Rumi": "Poeta persa y místico sufí del siglo XIII (1207–1273). Su colección poética 'Masnavi' es llamada 'el Corán en persa.' 800 años después, sigue siendo uno de los poetas más vendidos del mundo.",
      "Víctor Hugo": "Novelista, poeta y activista político francés (1802–1885). Autor de 'Los Miserables' y 'Nuestra Señora de París'. Luchó por la justicia social y abolió la pena de muerte en la imaginación literaria.",
      "Antoine de Saint-Exupéry": "Aviador y escritor francés (1900–1944). Autor de 'El Principito', uno de los libros más traducidos de la historia. Desapareció en un vuelo de reconocimiento sobre el Mediterráneo durante la Segunda Guerra Mundial.",
      "Ernest Hemingway": "Novelista y periodista estadounidense (1899–1961). Premio Nobel de Literatura. Su prosa directa y sobria en 'El viejo y el mar' y 'Por quién doblan las campanas' redefinió la ficción moderna.",
      "Immanuel Kant": "Filósofo alemán (1724–1804). Nunca viajó más de 16 km de su ciudad natal, pero su 'Crítica de la razón pura' revolucionó la filosofía. Su imperativo categórico sigue siendo central en la ética moderna.",
      "William James": "Filósofo y psicólogo estadounidense (1842–1910). Padre de la psicología americana. Sus obras 'Pragmatismo' y 'Las variedades de la experiencia religiosa' unieron filosofía, ciencia y espiritualidad.",
      "Sófocles": "Dramaturgo griego (496–406 a.C.). Escribió más de 120 obras; sobreviven siete, incluyendo 'Edipo Rey' y 'Antígona'. Introdujo el tercer actor en el teatro griego.",
      "Thich Nhat Hanh": "Monje budista vietnamita y activista por la paz (1926–2022). Acuñó el término 'budismo comprometido.' Martin Luther King Jr. lo nominó al Nobel de la Paz. Sus libros sobre mindfulness vendieron millones.",
      "Leonardo da Vinci": "Polímata italiano (1452–1519). Pintor de la Mona Lisa y La Última Cena. También inventor, científico, arquitecto y anatomista. Sus cuadernos revelan una mente siglos adelantada a su tiempo.",
      "Voltaire": "Escritor y filósofo francés de la Ilustración (1694–1778). Defensor de la libertad de expresión y la separación de Iglesia y Estado. Su novela satírica 'Cándido' se burló del optimismo filosófico.",
      "Heráclito": "Filósofo griego (c. 535–475 a.C.) de Éfeso, conocido como 'El Oscuro.' Famoso por 'Nadie se baña dos veces en el mismo río' — todo fluye (panta rhei). Creía que el fuego era el elemento fundamental.",
      "René Descartes": "Filósofo y matemático francés (1596–1650). 'Pienso, luego existo' es la frase más famosa de la filosofía. Fundó el racionalismo moderno e inventó el sistema de coordenadas.",
      "Ludwig Wittgenstein": "Filósofo austro-británico (1889–1951). Su 'Tractatus' y sus 'Investigaciones filosóficas' están entre las obras más importantes del siglo XX. Renunció a su herencia para dedicarse al pensamiento.",
      "Theodore Roosevelt": "26° Presidente de EE.UU. (1858–1919). Presidente más joven de la historia. Lideró los Rough Riders, construyó el Canal de Panamá, ganó el Nobel de la Paz. Sobrevivió a un intento de asesinato y terminó su discurso con la bala aún en el pecho.",
      "Eckhart Tolle": "Maestro espiritual nacido en Alemania (1948–). Su libro 'El poder del ahora' vendió millones y fue traducido a 52 idiomas. Enseña presencia, conciencia y trascendencia del ego.",
      "Søren Kierkegaard": "Filósofo danés (1813–1855), considerado el padre del existencialismo. Sus obras — 'Temor y temblor', 'O lo uno o lo otro' — exploraron la angustia, la desesperación y el salto de fe.",
      "Nelson Mandela": "Líder antiapartheid sudafricano (1918–2013). Encarcelado 27 años, emergió sin amargura para convertirse en el primer presidente negro de Sudáfrica. Nobel de la Paz en 1993. Símbolo de reconciliación.",
      "Plutarco": "Biógrafo y ensayista griego (c. 46–120 d.C.). Sus 'Vidas paralelas' compararon héroes griegos y romanos e influenciaron a Shakespeare, los Padres Fundadores americanos y el pensamiento político.",
      "Alan Watts": "Filósofo británico-estadounidense (1915–1973). Llevó la filosofía oriental — budismo zen, taoísmo, hinduismo — a audiencias occidentales. Su obra 'El camino del Zen' sigue siendo una introducción clásica.",
      "Sun Tzu": "Estratega militar chino (544–496 a.C.). Autor de 'El arte de la guerra', el tratado de estrategia militar más antiguo conocido. Sus principios ahora se aplican a negocios, deportes y desarrollo personal.",
      "Dale Carnegie": "Escritor y conferenciante estadounidense (1888–1955). Su libro 'Cómo ganar amigos e influir sobre las personas' (1936) vendió 30 millones de copias y sigue siendo la base de la comunicación interpersonal.",
      "Coco Chanel": "Diseñadora de moda francesa (1883–1971). Fundó la Casa Chanel, revolucionó la moda femenina liberándola del corsé. Creó el vestidito negro, Chanel N° 5 y el concepto de elegancia casual.",
      "Oprah Winfrey": "Magnate de medios y filántropa estadounidense (1954–). Ascendió de la pobreza rural en Mississippi para convertirse en la mujer más influyente de los medios. Su programa alcanzó 10 millones de espectadores diarios.",
      "Vince Lombardi": "Entrenador de fútbol americano (1913–1970). Llevó a los Green Bay Packers a cinco campeonatos de la NFL. El trofeo del Super Bowl lleva su nombre. Su filosofía: 'Ganar no lo es todo; es lo único.'",
      "Peter Drucker": "Consultor de gestión austro-estadounidense (1909–2005). Llamado 'el padre de la gestión moderna.' Inventó la dirección por objetivos y predijo el auge de los trabajadores del conocimiento.",
      "Fiódor Dostoyevski": "Novelista ruso (1821–1881). Sentenciado a muerte, indultado en el último momento. Escribió 'Crimen y castigo', 'Los hermanos Karamázov' — profundas exploraciones de la moralidad, la fe y la psique humana.",
      "Benjamin Disraeli": "Primer Ministro británico y novelista (1804–1881). El único PM británico que fue novelista publicado antes de entrar en política. Defendió reformas sociales y expandió el Imperio Británico.",
      "Og Mandino": "Autor estadounidense (1923–1996). Superó el alcoholismo y la pobreza para escribir 'El vendedor más grande del mundo', que vendió 50 millones de copias. Sus obras se centran en la transformación personal.",
      "Franklin D. Roosevelt": "32° Presidente de EE.UU. (1882–1945). Lideró a América durante la Gran Depresión y la Segunda Guerra Mundial. Único presidente elegido cuatro veces. Su New Deal transformó el gobierno estadounidense.",
      "Thomas Carlyle": "Filósofo e historiador escocés (1795–1881). Su teoría del 'Gran Hombre' argumentaba que los héroes moldean el mundo. Sus obras sobre la Revolución Francesa influyeron en el pensamiento victoriano.",
      "John F. Kennedy": "35° Presidente de EE.UU. (1917–1963). Inspiró a una generación con 'No preguntes qué puede hacer tu país por ti.' Gestionó la Crisis de los Misiles de Cuba y lanzó la carrera espacial.",
      "Albert Schweitzer": "Teólogo, médico y Nobel franco-alemán (1875–1965). Renunció a una carrera musical para construir un hospital en África. Su filosofía de 'reverencia por la vida' se convirtió en un marco ético.",
      "Douglas Adams": "Autor y humorista inglés (1952–2001). Creó 'La guía del autoestopista galáctico', respondiendo a la pregunta definitiva con '42'. Su ingenio absurdista mezcló ciencia ficción con profundidad filosófica.",
      "Oliver Wendell Holmes Jr.": "Jurista estadounidense (1841–1935). Sirvió 30 años en la Corte Suprema. Sus opiniones sobre libertad de expresión y realismo legal moldearon el derecho constitucional estadounidense.",
      "Anatole France": "Novelista y Nobel francés (1844–1924). Conocido por su prosa irónica y elegante. Ganó el Nobel de Literatura en 1921. Defensor de la justicia social y la libertad intelectual.",
    },
  };

  const langBios = bios[lang] || bios["en"];
  return langBios[name] || (lang === "es"
    ? `Pensador y autor cuyas ideas han inspirado a generaciones.`
    : `Thinker and author whose ideas have inspired generations.`);
}
