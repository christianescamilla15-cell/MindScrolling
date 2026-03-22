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

/// Science mode quiz questions (10 questions, basic/intermediate).
const scienceQuizQuestions = <QuizQuestion>[
  QuizQuestion(
    questionEn: 'What force keeps planets in orbit around the Sun?',
    questionEs: '¿Qué fuerza mantiene a los planetas en órbita alrededor del Sol?',
    optionsEn: ['Magnetism', 'Gravity', 'Friction', 'Electricity'],
    optionsEs: ['Magnetismo', 'Gravedad', 'Fricción', 'Electricidad'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the chemical symbol for water?',
    questionEs: '¿Cuál es el símbolo químico del agua?',
    optionsEn: ['O2', 'CO2', 'H2O', 'NaCl'],
    optionsEs: ['O2', 'CO2', 'H2O', 'NaCl'],
    correctIndex: 2,
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
    questionEn: 'What is the smallest unit of matter?',
    questionEs: '¿Cuál es la unidad más pequeña de materia?',
    optionsEn: ['Molecule', 'Cell', 'Atom', 'Electron'],
    optionsEs: ['Molécula', 'Célula', 'Átomo', 'Electrón'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What does DNA stand for?',
    questionEs: '¿Qué significa ADN?',
    optionsEn: ['Deoxyribonucleic Acid', 'Dynamic Natural Acid', 'Digital Neuron Array', 'Double Nucleic Atom'],
    optionsEs: ['Ácido desoxirribonucleico', 'Ácido dinámico natural', 'Arreglo digital neuronal', 'Átomo nuclear doble'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'What planet is known as the Red Planet?',
    questionEs: '¿Qué planeta es conocido como el Planeta Rojo?',
    optionsEn: ['Venus', 'Jupiter', 'Mars', 'Saturn'],
    optionsEs: ['Venus', 'Júpiter', 'Marte', 'Saturno'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the powerhouse of the cell?',
    questionEs: '¿Cuál es la central de energía de la célula?',
    optionsEn: ['Nucleus', 'Ribosome', 'Mitochondria', 'Cytoplasm'],
    optionsEs: ['Núcleo', 'Ribosoma', 'Mitocondria', 'Citoplasma'],
    correctIndex: 2,
  ),
  QuizQuestion(
    questionEn: 'What is the Pythagorean theorem about?',
    questionEs: '¿De qué trata el teorema de Pitágoras?',
    optionsEn: ['Circles', 'Right triangles', 'Parallel lines', 'Probability'],
    optionsEs: ['Círculos', 'Triángulos rectángulos', 'Líneas paralelas', 'Probabilidad'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is the most abundant gas in Earth\'s atmosphere?',
    questionEs: '¿Cuál es el gas más abundante en la atmósfera de la Tierra?',
    optionsEn: ['Oxygen', 'Carbon dioxide', 'Nitrogen', 'Hydrogen'],
    optionsEs: ['Oxígeno', 'Dióxido de carbono', 'Nitrógeno', 'Hidrógeno'],
    correctIndex: 2,
  ),
];

/// Coding mode quiz questions (10 questions, basic/intermediate).
const codingQuizQuestions = <QuizQuestion>[
  QuizQuestion(
    questionEn: 'What does HTML stand for?',
    questionEs: '¿Qué significa HTML?',
    optionsEn: ['HyperText Markup Language', 'High Transfer Machine Language', 'Hyper Tool Multi Language', 'Home Text Markup Language'],
    optionsEs: ['Lenguaje de marcado de hipertexto', 'Lenguaje de máquina de alta transferencia', 'Lenguaje multiherramienta hiper', 'Lenguaje de marcado de texto local'],
    correctIndex: 0,
  ),
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
    questionEn: 'What symbol is used for single-line comments in JavaScript?',
    questionEs: '¿Qué símbolo se usa para comentarios de una línea en JavaScript?',
    optionsEn: ['/* */', '//', '#', '--'],
    optionsEs: ['/* */', '//', '#', '--'],
    correctIndex: 1,
  ),
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
    questionEn: 'What does SQL stand for?',
    questionEs: '¿Qué significa SQL?',
    optionsEn: ['Structured Query Language', 'Simple Query Logic', 'System Quality Level', 'Standard Question Language'],
    optionsEs: ['Lenguaje de consulta estructurado', 'Lógica de consulta simple', 'Nivel de calidad del sistema', 'Lenguaje estándar de preguntas'],
    correctIndex: 0,
  ),
  QuizQuestion(
    questionEn: 'What is the purpose of a loop in programming?',
    questionEs: '¿Cuál es el propósito de un bucle en programación?',
    optionsEn: ['To store data', 'To repeat code', 'To connect to internet', 'To display images'],
    optionsEs: ['Almacenar datos', 'Repetir código', 'Conectarse a internet', 'Mostrar imágenes'],
    correctIndex: 1,
  ),
  QuizQuestion(
    questionEn: 'What is Git primarily used for?',
    questionEs: '¿Para qué se usa Git principalmente?',
    optionsEn: ['Web design', 'Version control', 'Database management', 'Image editing'],
    optionsEs: ['Diseño web', 'Control de versiones', 'Gestión de bases de datos', 'Edición de imágenes'],
    correctIndex: 1,
  ),
];
