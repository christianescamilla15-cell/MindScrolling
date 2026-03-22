import 'dart:math';

/// Quiz question model for hidden mode access gating.
class QuizQuestion {
  final String questionEn;
  final String questionEs;
  final List<String> optionsEn;
  final List<String> optionsEs;
  final int correctIndex;

  const QuizQuestion({
    required this.questionEn,
    required this.questionEs,
    required this.optionsEn,
    required this.optionsEs,
    required this.correctIndex,
  });

  String question(String lang) => lang == 'es' ? questionEs : questionEn;
  List<String> options(String lang) => lang == 'es' ? optionsEs : optionsEn;
}

/// Returns [count] random questions from the given pool, shuffled.
List<QuizQuestion> pickRandomQuestions(List<QuizQuestion> pool, {int count = 10}) {
  final shuffled = List<QuizQuestion>.from(pool)..shuffle(Random());
  return shuffled.take(count).toList();
}

// =============================================================================
// SCIENCE — 50 questions
// Physics (10) · Chemistry (10) · Biology (10) · Mathematics (10) · Tech (10)
// =============================================================================

/// Science mode quiz questions (50 questions, basic difficulty).
const scienceQuizQuestions = <QuizQuestion>[

  // ---------- Physics (10) ----------

  QuizQuestion(
    questionEn: 'What force keeps planets in orbit around the Sun?',
    questionEs: '¿Qué fuerza mantiene a los planetas en órbita alrededor del Sol?',
    optionsEn: ['Magnetism', 'Gravity', 'Friction', 'Electricity'],
    optionsEs: ['Magnetismo', 'Gravedad', 'Fricción', 'Electricidad'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the speed of light approximately?',
    questionEs: '¿Cuál es la velocidad de la luz aproximadamente?',
    optionsEn: ['300,000 km/s', '150,000 km/s', '1,000,000 km/s', '30,000 km/s'],
    optionsEs: ['300,000 km/s', '150,000 km/s', '1,000,000 km/s', '30,000 km/s'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'Who proposed the theory of general relativity?',
    questionEs: '¿Quién propuso la teoría de la relatividad general?',
    optionsEn: ['Isaac Newton', 'Albert Einstein', 'Niels Bohr', 'Max Planck'],
    optionsEs: ['Isaac Newton', 'Albert Einstein', 'Niels Bohr', 'Max Planck'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which of Newton\'s laws states that every action has an equal and opposite reaction?',
    questionEs: '¿Cuál de las leyes de Newton establece que toda acción tiene una reacción igual y opuesta?',
    optionsEn: ['First law', 'Second law', 'Third law', 'Law of gravitation'],
    optionsEs: ['Primera ley', 'Segunda ley', 'Tercera ley', 'Ley de gravitación'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What type of energy does a moving object have?',
    questionEs: '¿Qué tipo de energía tiene un objeto en movimiento?',
    optionsEn: ['Potential energy', 'Chemical energy', 'Kinetic energy', 'Nuclear energy'],
    optionsEs: ['Energía potencial', 'Energía química', 'Energía cinética', 'Energía nuclear'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the unit of electrical resistance?',
    questionEs: '¿Cuál es la unidad de resistencia eléctrica?',
    optionsEn: ['Volt', 'Ampere', 'Watt', 'Ohm'],
    optionsEs: ['Voltio', 'Amperio', 'Vatio', 'Ohmio'],
    correctIndex: 3,
  ),
  QuizQuestion(
    questionEn: 'Sound travels fastest through which medium?',
    questionEs: '¿A través de qué medio viaja más rápido el sonido?',
    optionsEn: ['Air', 'Vacuum', 'Water', 'Steel'],
    optionsEs: ['Aire', 'Vacío', 'Agua', 'Acero'],
    correctIndex: 3,
  ),
  QuizQuestion(
    questionEn: 'What is the SI unit of force?',
    questionEs: '¿Cuál es la unidad SI de fuerza?',
    optionsEn: ['Joule', 'Newton', 'Pascal', 'Watt'],
    optionsEs: ['Julio', 'Newton', 'Pascal', 'Vatio'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which particle in an atom has no electric charge?',
    questionEs: '¿Qué partícula del átomo no tiene carga eléctrica?',
    optionsEn: ['Proton', 'Electron', 'Neutron', 'Photon'],
    optionsEs: ['Protón', 'Electrón', 'Neutrón', 'Fotón'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What phenomenon causes a rainbow to form?',
    questionEs: '¿Qué fenómeno causa la formación de un arcoíris?',
    optionsEn: ['Reflection only', 'Refraction and dispersion of light', 'Absorption of light', 'Diffraction'],
    optionsEs: ['Solo reflexión', 'Refracción y dispersión de la luz', 'Absorción de luz', 'Difracción'],
    correctIndex: 1,
  ),

  // ---------- Chemistry (10) ----------

  QuizQuestion(
    questionEn: 'What is the chemical symbol for water?',
    questionEs: '¿Cuál es el símbolo químico del agua?',
    optionsEn: ['O2', 'CO2', 'H2O', 'NaCl'],
    optionsEs: ['O2', 'CO2', 'H2O', 'NaCl'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the most abundant element in the universe?',
    questionEs: '¿Cuál es el elemento más abundante en el universo?',
    optionsEn: ['Oxygen', 'Carbon', 'Helium', 'Hydrogen'],
    optionsEs: ['Oxígeno', 'Carbono', 'Helio', 'Hidrógeno'],
    correctIndex: 3,
  ),
  QuizQuestion(
    questionEn: 'What is the chemical symbol for gold?',
    questionEs: '¿Cuál es el símbolo químico del oro?',
    optionsEn: ['Go', 'Gd', 'Au', 'Ag'],
    optionsEs: ['Go', 'Gd', 'Au', 'Ag'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'How many elements are on the periodic table (as of 2024)?',
    questionEs: '¿Cuántos elementos hay en la tabla periódica (hasta 2024)?',
    optionsEn: ['108', '118', '128', '98'],
    optionsEs: ['108', '118', '128', '98'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What type of bond involves the sharing of electrons between atoms?',
    questionEs: '¿Qué tipo de enlace implica compartir electrones entre átomos?',
    optionsEn: ['Ionic bond', 'Hydrogen bond', 'Covalent bond', 'Metallic bond'],
    optionsEs: ['Enlace iónico', 'Enlace de hidrógeno', 'Enlace covalente', 'Enlace metálico'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the pH of a neutral solution?',
    questionEs: '¿Cuál es el pH de una solución neutra?',
    optionsEn: ['0', '5', '7', '14'],
    optionsEs: ['0', '5', '7', '14'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'Which gas makes up most of Earth\'s atmosphere?',
    questionEs: '¿Qué gas compone la mayor parte de la atmósfera terrestre?',
    optionsEn: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Argon'],
    optionsEs: ['Oxígeno', 'Dióxido de carbono', 'Nitrógeno', 'Argón'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the process called when a solid turns directly into a gas?',
    questionEs: '¿Cómo se llama el proceso por el que un sólido se convierte directamente en gas?',
    optionsEn: ['Evaporation', 'Condensation', 'Sublimation', 'Melting'],
    optionsEs: ['Evaporación', 'Condensación', 'Sublimación', 'Fusión'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the chemical formula for table salt?',
    questionEs: '¿Cuál es la fórmula química de la sal de mesa?',
    optionsEn: ['KCl', 'NaOH', 'NaCl', 'CaCO3'],
    optionsEs: ['KCl', 'NaOH', 'NaCl', 'CaCO3'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is an atom that has gained or lost electrons called?',
    questionEs: '¿Cómo se llama un átomo que ha ganado o perdido electrones?',
    optionsEn: ['Isotope', 'Ion', 'Molecule', 'Compound'],
    optionsEs: ['Isótopo', 'Ion', 'Molécula', 'Compuesto'],
    correctIndex: 1,
  ),

  // ---------- Biology (10) ----------

  QuizQuestion(
    questionEn: 'What does DNA stand for?',
    questionEs: '¿Qué significa ADN?',
    optionsEn: ['Deoxyribonucleic Acid', 'Dynamic Natural Acid', 'Digital Neuron Array', 'Double Nucleic Atom'],
    optionsEs: ['Ácido desoxirribonucleico', 'Ácido dinámico natural', 'Arreglo digital neuronal', 'Átomo nuclear doble'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'What is the powerhouse of the cell?',
    questionEs: '¿Cuál es la central de energía de la célula?',
    optionsEn: ['Nucleus', 'Ribosome', 'Mitochondria', 'Cytoplasm'],
    optionsEs: ['Núcleo', 'Ribosoma', 'Mitocondria', 'Citoplasma'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the most abundant gas in Earth\'s atmosphere?',
    questionEs: '¿Cuál es el gas más abundante en la atmósfera de la Tierra?',
    optionsEn: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    optionsEs: ['Oxígeno', 'Dióxido de carbono', 'Nitrógeno', 'Hidrógeno'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the process by which plants make their own food using sunlight?',
    questionEs: '¿Cómo se llama el proceso por el que las plantas fabrican su propio alimento usando luz solar?',
    optionsEn: ['Respiration', 'Fermentation', 'Photosynthesis', 'Digestion'],
    optionsEs: ['Respiración', 'Fermentación', 'Fotosíntesis', 'Digestión'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'How many chambers does the human heart have?',
    questionEs: '¿Cuántas cámaras tiene el corazón humano?',
    optionsEn: ['2', '3', '4', '6'],
    optionsEs: ['2', '3', '4', '6'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the basic unit of life?',
    questionEs: '¿Cuál es la unidad básica de la vida?',
    optionsEn: ['Tissue', 'Organ', 'Cell', 'Atom'],
    optionsEs: ['Tejido', 'Órgano', 'Célula', 'Átomo'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'Which scientist developed the theory of evolution by natural selection?',
    questionEs: '¿Qué científico desarrolló la teoría de la evolución por selección natural?',
    optionsEn: ['Gregor Mendel', 'Louis Pasteur', 'Charles Darwin', 'Marie Curie'],
    optionsEs: ['Gregor Mendel', 'Louis Pasteur', 'Charles Darwin', 'Marie Curie'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What organ filters waste from the blood?',
    questionEs: '¿Qué órgano filtra los desechos de la sangre?',
    optionsEn: ['Liver', 'Lungs', 'Kidneys', 'Stomach'],
    optionsEs: ['Hígado', 'Pulmones', 'Riñones', 'Estómago'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What type of organism is a mushroom?',
    questionEs: '¿Qué tipo de organismo es un hongo?',
    optionsEn: ['Plant', 'Animal', 'Fungi', 'Bacteria'],
    optionsEs: ['Planta', 'Animal', 'Hongo', 'Bacteria'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the liquid part of blood called?',
    questionEs: '¿Cómo se llama la parte líquida de la sangre?',
    optionsEn: ['Hemoglobin', 'Plasma', 'Serum albumin', 'White blood cells'],
    optionsEs: ['Hemoglobina', 'Plasma', 'Albúmina sérica', 'Glóbulos blancos'],
    correctIndex: 1,
  ),

  // ---------- Mathematics (10) ----------

  QuizQuestion(
    questionEn: 'What is the Pythagorean theorem about?',
    questionEs: '¿De qué trata el teorema de Pitágoras?',
    optionsEn: ['Circles', 'Right triangles', 'Parallel lines', 'Probability'],
    optionsEs: ['Círculos', 'Triángulos rectángulos', 'Líneas paralelas', 'Probabilidad'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the value of pi (π) to two decimal places?',
    questionEs: '¿Cuál es el valor de pi (π) con dos decimales?',
    optionsEn: ['3.12', '3.14', '3.16', '3.18'],
    optionsEs: ['3.12', '3.14', '3.16', '3.18'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the result of 2 to the power of 10?',
    questionEs: '¿Cuál es el resultado de 2 elevado a la potencia de 10?',
    optionsEn: ['512', '1024', '2048', '256'],
    optionsEs: ['512', '1024', '2048', '256'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is a prime number?',
    questionEs: '¿Qué es un número primo?',
    optionsEn: ['A number divisible by 2', 'A number with exactly two factors: 1 and itself', 'A number greater than 100', 'A negative integer'],
    optionsEs: ['Un número divisible entre 2', 'Un número con exactamente dos factores: 1 y él mismo', 'Un número mayor que 100', 'Un entero negativo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the area of a circle with radius r?',
    questionEs: '¿Cuál es el área de un círculo de radio r?',
    optionsEn: ['2πr', 'πr²', '2πr²', 'πr/2'],
    optionsEs: ['2πr', 'πr²', '2πr²', 'πr/2'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the square root of 144?',
    questionEs: '¿Cuál es la raíz cuadrada de 144?',
    optionsEn: ['11', '12', '13', '14'],
    optionsEs: ['11', '12', '13', '14'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'In a right triangle with legs of 3 and 4, what is the hypotenuse?',
    questionEs: 'En un triángulo rectángulo con catetos de 3 y 4, ¿cuánto mide la hipotenusa?',
    optionsEn: ['6', '7', '5', '8'],
    optionsEs: ['6', '7', '5', '8'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does the symbol "%" represent?',
    questionEs: '¿Qué representa el símbolo "%"?',
    optionsEn: ['Per thousand', 'Per hundred (percent)', 'Per million', 'Division'],
    optionsEs: ['Por mil', 'Por cien (porcentaje)', 'Por millón', 'División'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'How many degrees are in a full circle?',
    questionEs: '¿Cuántos grados tiene un círculo completo?',
    optionsEn: ['90', '180', '270', '360'],
    optionsEs: ['90', '180', '270', '360'],
    correctIndex: 3,
  ),
  QuizQuestion(
    questionEn: 'What is 15% of 200?',
    questionEs: '¿Cuánto es el 15% de 200?',
    optionsEn: ['20', '25', '30', '35'],
    optionsEs: ['20', '25', '30', '35'],
    correctIndex: 2,
  ),

  // ---------- Technology / General Science (10) ----------

  QuizQuestion(
    questionEn: 'What planet is known as the Red Planet?',
    questionEs: '¿Qué planeta es conocido como el Planeta Rojo?',
    optionsEn: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
    optionsEs: ['Venus', 'Júpiter', 'Marte', 'Saturno'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the smallest unit of matter?',
    questionEs: '¿Cuál es la unidad más pequeña de materia?',
    optionsEn: ['Molecule', 'Cell', 'Atom', 'Electron'],
    optionsEs: ['Molécula', 'Célula', 'Átomo', 'Electrón'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does a seismograph measure?',
    questionEs: '¿Qué mide un sismógrafo?',
    optionsEn: ['Wind speed', 'Earthquakes', 'Rainfall', 'Temperature'],
    optionsEs: ['Velocidad del viento', 'Terremotos', 'Lluvia', 'Temperatura'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the name of the layer of gases surrounding Earth?',
    questionEs: '¿Cómo se llama la capa de gases que rodea la Tierra?',
    optionsEn: ['Hydrosphere', 'Lithosphere', 'Atmosphere', 'Biosphere'],
    optionsEs: ['Hidrósfera', 'Litosfera', 'Atmósfera', 'Biósfera'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'In which direction does current flow in a conventional circuit?',
    questionEs: '¿En qué dirección fluye la corriente en un circuito convencional?',
    optionsEn: ['From negative to positive', 'From positive to negative', 'In both directions simultaneously', 'It does not flow'],
    optionsEs: ['Del negativo al positivo', 'Del positivo al negativo', 'En ambas direcciones simultáneamente', 'No fluye'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the term for the bending of light as it passes from one medium to another?',
    questionEs: '¿Cómo se llama el fenómeno de doblado de la luz al pasar de un medio a otro?',
    optionsEn: ['Reflection', 'Diffraction', 'Refraction', 'Absorption'],
    optionsEs: ['Reflexión', 'Difracción', 'Refracción', 'Absorción'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the name of the force that resists motion between surfaces in contact?',
    questionEs: '¿Cómo se llama la fuerza que resiste el movimiento entre superficies en contacto?',
    optionsEn: ['Gravity', 'Tension', 'Friction', 'Magnetism'],
    optionsEs: ['Gravedad', 'Tensión', 'Fricción', 'Magnetismo'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'How many planets are in our solar system?',
    questionEs: '¿Cuántos planetas hay en nuestro sistema solar?',
    optionsEn: ['7', '8', '9', '10'],
    optionsEs: ['7', '8', '9', '10'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does a thermometer measure?',
    questionEs: '¿Qué mide un termómetro?',
    optionsEn: ['Pressure', 'Humidity', 'Temperature', 'Volume'],
    optionsEs: ['Presión', 'Humedad', 'Temperatura', 'Volumen'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the closest star to Earth (other than the Sun)?',
    questionEs: '¿Cuál es la estrella más cercana a la Tierra (además del Sol)?',
    optionsEn: ['Sirius', 'Proxima Centauri', 'Betelgeuse', 'Vega'],
    optionsEs: ['Sirio', 'Próxima Centauri', 'Betelgeuse', 'Vega'],
    correctIndex: 1,
  ),
];

// =============================================================================
// CODING — 50 questions
// Fundamentals (10) · Web (10) · Databases & SQL (10) · Algorithms (10) · Tools/DevOps (10)
// =============================================================================

/// Coding mode quiz questions (50 questions, basic difficulty).
const codingQuizQuestions = <QuizQuestion>[

  // ---------- Programming Fundamentals (10) ----------

  QuizQuestion(
    questionEn: 'What does API stand for?',
    questionEs: '¿Qué significa API?',
    optionsEn: ['Application Programming Interface', 'Advanced Program Integration', 'Automated Protocol Index', 'Application Process Internet'],
    optionsEs: ['Interfaz de programación de aplicaciones', 'Integración avanzada de programas', 'Índice de protocolo automatizado', 'Proceso de aplicación de internet'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'Which of these is NOT a programming language?',
    questionEs: '¿Cuál de estos NO es un lenguaje de programación?',
    optionsEn: ['Python', 'Java', 'Linux', 'Rust'],
    optionsEs: ['Python', 'Java', 'Linux', 'Rust'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is a variable in programming?',
    questionEs: '¿Qué es una variable en programación?',
    optionsEn: ['A function', 'A named storage for data', 'A loop type', 'An error'],
    optionsEs: ['Una función', 'Un almacenamiento de datos con nombre', 'Un tipo de bucle', 'Un error'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the purpose of a loop in programming?',
    questionEs: '¿Cuál es el propósito de un bucle en programación?',
    optionsEn: ['To store data', 'To repeat code', 'To connect to the internet', 'To display images'],
    optionsEs: ['Almacenar datos', 'Repetir código', 'Conectarse a internet', 'Mostrar imágenes'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What keyword is commonly used to define a function in Python?',
    questionEs: '¿Qué palabra clave se usa comúnmente para definir una función en Python?',
    optionsEn: ['func', 'function', 'def', 'define'],
    optionsEs: ['func', 'function', 'def', 'define'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is an "if" statement used for?',
    questionEs: '¿Para qué se usa una sentencia "if"?',
    optionsEn: ['Repeating code a fixed number of times', 'Making decisions based on a condition', 'Storing a list of values', 'Declaring a variable'],
    optionsEs: ['Repetir código un número fijo de veces', 'Tomar decisiones basadas en una condición', 'Almacenar una lista de valores', 'Declarar una variable'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does "boolean" data type represent?',
    questionEs: '¿Qué representa el tipo de dato "booleano"?',
    optionsEn: ['A whole number', 'A piece of text', 'True or False', 'A decimal number'],
    optionsEs: ['Un número entero', 'Un texto', 'Verdadero o Falso', 'Un número decimal'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'In object-oriented programming, what is a class?',
    questionEs: 'En programación orientada a objetos, ¿qué es una clase?',
    optionsEn: ['A type of loop', 'A blueprint for creating objects', 'A database table', 'A network protocol'],
    optionsEs: ['Un tipo de bucle', 'Un plano para crear objetos', 'Una tabla de base de datos', 'Un protocolo de red'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does it mean to "compile" code?',
    questionEs: '¿Qué significa "compilar" código?',
    optionsEn: ['Run code line by line', 'Translate source code into machine code', 'Delete unused variables', 'Upload code to a server'],
    optionsEs: ['Ejecutar código línea por línea', 'Traducir código fuente a código máquina', 'Eliminar variables no utilizadas', 'Subir código a un servidor'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is a "null" value in programming?',
    questionEs: '¿Qué es un valor "null" en programación?',
    optionsEn: ['The number zero', 'An empty string', 'The absence of a value', 'A negative number'],
    optionsEs: ['El número cero', 'Una cadena vacía', 'La ausencia de un valor', 'Un número negativo'],
    correctIndex: 2,
  ),

  // ---------- Web Technologies (10) ----------

  QuizQuestion(
    questionEn: 'What does HTML stand for?',
    questionEs: '¿Qué significa HTML?',
    optionsEn: ['HyperText Markup Language', 'High Transfer Machine Language', 'Hyper Tool Multi Language', 'Home Text Markup Language'],
    optionsEs: ['Lenguaje de marcado de hipertexto', 'Lenguaje de máquina de alta transferencia', 'Lenguaje multiherramienta hiper', 'Lenguaje de marcado de texto local'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'What symbol is used for single-line comments in JavaScript?',
    questionEs: '¿Qué símbolo se usa para comentarios de una línea en JavaScript?',
    optionsEn: ['/* */', '//', '#', '--'],
    optionsEs: ['/* */', '//', '#', '--'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the role of CSS in web development?',
    questionEs: '¿Cuál es el papel de CSS en el desarrollo web?',
    optionsEn: ['Store data', 'Handle server logic', 'Style and visually format web pages', 'Manage databases'],
    optionsEs: ['Almacenar datos', 'Manejar lógica del servidor', 'Estilizar y dar formato visual a páginas web', 'Gestionar bases de datos'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What HTTP status code means "Not Found"?',
    questionEs: '¿Qué código de estado HTTP significa "No encontrado"?',
    optionsEn: ['200', '301', '404', '500'],
    optionsEs: ['200', '301', '404', '500'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does the DOM stand for in web development?',
    questionEs: '¿Qué significa DOM en el desarrollo web?',
    optionsEn: ['Document Object Model', 'Data Ordering Method', 'Dynamic Output Module', 'Design Object Map'],
    optionsEs: ['Modelo de objetos del documento', 'Método de ordenación de datos', 'Módulo de salida dinámica', 'Mapa de objetos de diseño'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'Which HTML tag is used to create a hyperlink?',
    questionEs: '¿Qué etiqueta HTML se usa para crear un hipervínculo?',
    optionsEn: ['<link>', '<href>', '<a>', '<url>'],
    optionsEs: ['<link>', '<href>', '<a>', '<url>'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does HTTPS stand for?',
    questionEs: '¿Qué significa HTTPS?',
    optionsEn: ['HyperText Transfer Protocol Secure', 'High Transfer Text Protocol System', 'Hyper Terminal Transfer Protocol Service', 'Home Text Transfer Protocol Standard'],
    optionsEs: ['Protocolo de transferencia de hipertexto seguro', 'Sistema de protocolo de transferencia de texto alto', 'Servicio de protocolo de transferencia de terminal hiper', 'Estándar de protocolo de transferencia de texto local'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'In web development, what is JSON primarily used for?',
    questionEs: 'En desarrollo web, ¿para qué se usa principalmente JSON?',
    optionsEn: ['Styling pages', 'Exchanging data between a server and a client', 'Compiling code', 'Managing databases'],
    optionsEs: ['Estilizar páginas', 'Intercambiar datos entre servidor y cliente', 'Compilar código', 'Gestionar bases de datos'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is a REST API?',
    questionEs: '¿Qué es una API REST?',
    optionsEn: ['A type of database', 'A web service architecture that uses HTTP methods', 'A CSS framework', 'A version control system'],
    optionsEs: ['Un tipo de base de datos', 'Una arquitectura de servicio web que usa métodos HTTP', 'Un framework de CSS', 'Un sistema de control de versiones'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which HTTP method is typically used to retrieve data from a server?',
    questionEs: '¿Qué método HTTP se usa normalmente para obtener datos de un servidor?',
    optionsEn: ['POST', 'PUT', 'DELETE', 'GET'],
    optionsEs: ['POST', 'PUT', 'DELETE', 'GET'],
    correctIndex: 3,
  ),

  // ---------- Databases & SQL (10) ----------

  QuizQuestion(
    questionEn: 'What does SQL stand for?',
    questionEs: '¿Qué significa SQL?',
    optionsEn: ['Structured Query Language', 'Simple Query Logic', 'System Quality Level', 'Standard Question Language'],
    optionsEs: ['Lenguaje de consulta estructurado', 'Lógica de consulta simple', 'Nivel de calidad del sistema', 'Lenguaje estándar de preguntas'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'Which SQL command is used to retrieve data from a table?',
    questionEs: '¿Qué comando SQL se usa para recuperar datos de una tabla?',
    optionsEn: ['INSERT', 'UPDATE', 'SELECT', 'DELETE'],
    optionsEs: ['INSERT', 'UPDATE', 'SELECT', 'DELETE'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is a primary key in a database?',
    questionEs: '¿Qué es una clave primaria en una base de datos?',
    optionsEn: ['The first column of any table', 'A unique identifier for each row in a table', 'The most important data in a table', 'A password to access the database'],
    optionsEs: ['La primera columna de cualquier tabla', 'Un identificador único para cada fila de una tabla', 'El dato más importante de una tabla', 'Una contraseña para acceder a la base de datos'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the difference between SQL and NoSQL databases?',
    questionEs: '¿Cuál es la diferencia entre bases de datos SQL y NoSQL?',
    optionsEn: ['SQL is faster', 'SQL uses structured tables; NoSQL uses flexible formats like documents', 'NoSQL uses tables too', 'There is no real difference'],
    optionsEs: ['SQL es más rápido', 'SQL usa tablas estructuradas; NoSQL usa formatos flexibles como documentos', 'NoSQL también usa tablas', 'No hay diferencia real'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which SQL keyword is used to filter results in a query?',
    questionEs: '¿Qué palabra clave SQL se usa para filtrar resultados en una consulta?',
    optionsEn: ['FROM', 'ORDER BY', 'WHERE', 'JOIN'],
    optionsEs: ['FROM', 'ORDER BY', 'WHERE', 'JOIN'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does a JOIN do in SQL?',
    questionEs: '¿Qué hace un JOIN en SQL?',
    optionsEn: ['Deletes duplicate rows', 'Combines rows from two or more tables based on a related column', 'Creates a new table', 'Exports data to a file'],
    optionsEs: ['Elimina filas duplicadas', 'Combina filas de dos o más tablas basándose en una columna relacionada', 'Crea una nueva tabla', 'Exporta datos a un archivo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is an index in a database used for?',
    questionEs: '¿Para qué sirve un índice en una base de datos?',
    optionsEn: ['To encrypt data', 'To speed up data retrieval', 'To set user permissions', 'To back up the database'],
    optionsEs: ['Para cifrar datos', 'Para acelerar la recuperación de datos', 'Para establecer permisos de usuario', 'Para respaldar la base de datos'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which SQL command removes all rows from a table without deleting the table itself?',
    questionEs: '¿Qué comando SQL elimina todas las filas de una tabla sin borrar la tabla?',
    optionsEn: ['DROP', 'DELETE', 'TRUNCATE', 'REMOVE'],
    optionsEs: ['DROP', 'DELETE', 'TRUNCATE', 'REMOVE'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is a foreign key in a relational database?',
    questionEs: '¿Qué es una clave foránea en una base de datos relacional?',
    optionsEn: ['A key from another application', 'A column that references the primary key of another table', 'An encrypted primary key', 'A key used for sorting'],
    optionsEs: ['Una clave de otra aplicación', 'Una columna que hace referencia a la clave primaria de otra tabla', 'Una clave primaria cifrada', 'Una clave usada para ordenar'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which of these is a popular NoSQL database?',
    questionEs: '¿Cuál de estas es una base de datos NoSQL popular?',
    optionsEn: ['MySQL', 'PostgreSQL', 'MongoDB', 'SQLite'],
    optionsEs: ['MySQL', 'PostgreSQL', 'MongoDB', 'SQLite'],
    correctIndex: 2,
  ),

  // ---------- Algorithms & Data Structures (10) ----------

  QuizQuestion(
    questionEn: 'Which data structure uses FIFO (First In, First Out)?',
    questionEs: '¿Qué estructura de datos usa FIFO (Primero en entrar, primero en salir)?',
    optionsEn: ['Stack', 'Queue', 'Tree', 'Graph'],
    optionsEs: ['Pila', 'Cola', 'Árbol', 'Grafo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the time complexity of binary search?',
    questionEs: '¿Cuál es la complejidad temporal de la búsqueda binaria?',
    optionsEn: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    optionsEs: ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which data structure operates like a stack of plates (Last In, First Out)?',
    questionEs: '¿Qué estructura de datos funciona como una pila de platos (último en entrar, primero en salir)?',
    optionsEn: ['Queue', 'Linked list', 'Stack', 'Hash table'],
    optionsEs: ['Cola', 'Lista enlazada', 'Pila', 'Tabla hash'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is a linked list?',
    questionEs: '¿Qué es una lista enlazada?',
    optionsEn: ['A table of sorted values', 'A sequence of nodes where each node points to the next', 'A tree with two branches', 'A fixed-size array'],
    optionsEs: ['Una tabla de valores ordenados', 'Una secuencia de nodos donde cada nodo apunta al siguiente', 'Un árbol con dos ramas', 'Un arreglo de tamaño fijo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does O(1) time complexity mean?',
    questionEs: '¿Qué significa una complejidad temporal O(1)?',
    optionsEn: ['The algorithm runs once per element', 'The algorithm always takes the same amount of time regardless of input size', 'The algorithm is very slow', 'The algorithm has no loops'],
    optionsEs: ['El algoritmo se ejecuta una vez por elemento', 'El algoritmo siempre tarda lo mismo independientemente del tamaño de entrada', 'El algoritmo es muy lento', 'El algoritmo no tiene bucles'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is a binary tree?',
    questionEs: '¿Qué es un árbol binario?',
    optionsEn: ['A tree where each node has at most two children', 'A tree with exactly two levels', 'A sorted array', 'A graph with no cycles'],
    optionsEs: ['Un árbol donde cada nodo tiene como máximo dos hijos', 'Un árbol con exactamente dos niveles', 'Un arreglo ordenado', 'Un grafo sin ciclos'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'What sorting algorithm works by repeatedly swapping adjacent elements that are out of order?',
    questionEs: '¿Qué algoritmo de ordenamiento funciona intercambiando repetidamente elementos adyacentes que están fuera de orden?',
    optionsEn: ['Merge sort', 'Quick sort', 'Bubble sort', 'Insertion sort'],
    optionsEs: ['Ordenamiento por mezcla', 'Ordenamiento rápido', 'Ordenamiento burbuja', 'Ordenamiento por inserción'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is a hash table used for?',
    questionEs: '¿Para qué se usa una tabla hash?',
    optionsEn: ['Sorting data in order', 'Fast key-value lookup using a hash function', 'Storing images', 'Managing network connections'],
    optionsEs: ['Ordenar datos', 'Búsqueda rápida de clave-valor usando una función hash', 'Almacenar imágenes', 'Gestionar conexiones de red'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is recursion in programming?',
    questionEs: '¿Qué es la recursión en programación?',
    optionsEn: ['Running multiple threads at once', 'A function that calls itself', 'A loop that runs indefinitely', 'A way to compress data'],
    optionsEs: ['Ejecutar varios hilos a la vez', 'Una función que se llama a sí misma', 'Un bucle que corre indefinidamente', 'Una manera de comprimir datos'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which data structure would you use to check if parentheses in code are balanced?',
    questionEs: '¿Qué estructura de datos usarías para comprobar si los paréntesis de un código están balanceados?',
    optionsEn: ['Queue', 'Graph', 'Stack', 'Heap'],
    optionsEs: ['Cola', 'Grafo', 'Pila', 'Montículo'],
    correctIndex: 2,
  ),

  // ---------- Tools & DevOps (10) ----------

  QuizQuestion(
    questionEn: 'What is Git primarily used for?',
    questionEs: '¿Para qué se usa Git principalmente?',
    optionsEn: ['Web design', 'Version control', 'Database management', 'Image editing'],
    optionsEs: ['Diseño web', 'Control de versiones', 'Gestión de bases de datos', 'Edición de imágenes'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does CI/CD stand for in software development?',
    questionEs: '¿Qué significa CI/CD en el desarrollo de software?',
    optionsEn: ['Code Integration / Code Delivery', 'Continuous Integration / Continuous Delivery', 'Central Index / Central Database', 'Component Interface / Component Design'],
    optionsEs: ['Integración de código / Entrega de código', 'Integración continua / Entrega continua', 'Índice central / Base de datos central', 'Interfaz de componentes / Diseño de componentes'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is Docker primarily used for?',
    questionEs: '¿Para qué se usa principalmente Docker?',
    optionsEn: ['Writing code faster', 'Packaging and running applications in containers', 'Designing user interfaces', 'Managing SQL databases'],
    optionsEs: ['Escribir código más rápido', 'Empaquetar y ejecutar aplicaciones en contenedores', 'Diseñar interfaces de usuario', 'Gestionar bases de datos SQL'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'Which Git command is used to save changes to the local repository?',
    questionEs: '¿Qué comando de Git se usa para guardar cambios en el repositorio local?',
    optionsEn: ['git push', 'git pull', 'git commit', 'git merge'],
    optionsEs: ['git push', 'git pull', 'git commit', 'git merge'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the main purpose of a package manager like npm or pip?',
    questionEs: '¿Cuál es el propósito principal de un gestor de paquetes como npm o pip?',
    optionsEn: ['Compile source code', 'Install and manage software libraries and dependencies', 'Monitor server performance', 'Write automated tests'],
    optionsEs: ['Compilar código fuente', 'Instalar y gestionar librerías y dependencias de software', 'Monitorear el rendimiento del servidor', 'Escribir pruebas automatizadas'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does "open source" software mean?',
    questionEs: '¿Qué significa software de "código abierto"?',
    optionsEn: ['Software that is free of bugs', 'Software whose source code is publicly available and can be modified', 'Software that only runs on Linux', 'Software that requires no installation'],
    optionsEs: ['Software sin errores', 'Software cuyo código fuente es público y puede modificarse', 'Software que solo corre en Linux', 'Software que no requiere instalación'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the purpose of a ".gitignore" file?',
    questionEs: '¿Cuál es el propósito de un archivo ".gitignore"?',
    optionsEn: ['To list all contributors to a project', 'To specify files and folders that Git should not track', 'To set up CI/CD pipelines', 'To document the project'],
    optionsEs: ['Listar todos los colaboradores del proyecto', 'Especificar archivos y carpetas que Git no debe rastrear', 'Configurar pipelines de CI/CD', 'Documentar el proyecto'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is a "branch" in Git?',
    questionEs: '¿Qué es una "rama" en Git?',
    optionsEn: ['A copy of the whole project stored on a remote server', 'An independent line of development that diverges from the main codebase', 'A type of merge conflict', 'A release tag'],
    optionsEs: ['Una copia del proyecto completo almacenada en un servidor remoto', 'Una línea de desarrollo independiente que diverge del código principal', 'Un tipo de conflicto de fusión', 'Una etiqueta de versión'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What does the terminal command "ls" do on Unix/Linux?',
    questionEs: '¿Qué hace el comando de terminal "ls" en Unix/Linux?',
    optionsEn: ['Launches a script', 'Lists the files and directories in the current folder', 'Logs into a server', 'Deletes a file'],
    optionsEs: ['Lanza un script', 'Lista los archivos y directorios de la carpeta actual', 'Inicia sesión en un servidor', 'Elimina un archivo'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the purpose of unit testing?',
    questionEs: '¿Cuál es el propósito de las pruebas unitarias?',
    optionsEn: ['To test the entire application at once', 'To verify that individual pieces of code work correctly in isolation', 'To check the user interface design', 'To measure server response time'],
    optionsEs: ['Probar toda la aplicación a la vez', 'Verificar que piezas individuales de código funcionan correctamente de forma aislada', 'Comprobar el diseño de la interfaz de usuario', 'Medir el tiempo de respuesta del servidor'],
    correctIndex: 1,
  ),
];
