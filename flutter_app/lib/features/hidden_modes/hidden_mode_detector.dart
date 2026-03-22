/// Detects user intent for hidden modes (science, coding) from free-text input.
///
/// Called from the Insight panel after emotional matching. If a hidden mode
/// intent is detected, the UI can suggest unlocking it.
class HiddenModeDetector {
  HiddenModeDetector._();

  static const _scienceKeywords = {
    // English
    'science', 'physics', 'math', 'mathematics', 'chemistry', 'biology',
    'technology', 'quantum', 'relativity', 'atoms', 'molecules', 'gravity',
    'space', 'universe', 'cosmos', 'astronomy', 'geology', 'evolution',
    'experiment', 'theory', 'hypothesis', 'scientific', 'research',
    'black hole', 'einstein', 'newton', 'darwin',
    // Spanish
    'ciencia', 'fisica', 'matematicas', 'quimica', 'biologia',
    'tecnologia', 'cuantica', 'relatividad', 'atomos', 'moleculas',
    'gravedad', 'espacio', 'universo', 'astronomia',
    'experimento', 'teoria', 'hipotesis', 'cientifico', 'investigacion',
    'agujero negro',
  };

  static const _codingKeywords = {
    // English
    'code', 'coding', 'programming', 'developer', 'software', 'algorithm',
    'frontend', 'backend', 'javascript', 'python', 'java', 'flutter',
    'dart', 'react', 'api', 'database', 'sql', 'html', 'css', 'git',
    'devops', 'debug', 'function', 'variable', 'loop', 'array',
    'object', 'class', 'typescript', 'rust', 'go', 'kotlin', 'swift',
    // Spanish
    'codigo', 'programacion', 'programar', 'desarrollador', 'algoritmo',
    'base de datos', 'funcion', 'bucle', 'arreglo',
  };

  /// Detects hidden mode intent from user text.
  ///
  /// Returns 'science', 'coding', or null.
  static String? detectIntent(String text) {
    final lower = text.toLowerCase();
    final words = lower.split(RegExp(r'\s+'));

    int scienceScore = 0;
    int codingScore = 0;

    for (final word in words) {
      if (_scienceKeywords.contains(word)) scienceScore++;
      if (_codingKeywords.contains(word)) codingScore++;
    }

    // Also check for multi-word phrases
    for (final phrase in _scienceKeywords.where((k) => k.contains(' '))) {
      if (lower.contains(phrase)) scienceScore += 2;
    }
    for (final phrase in _codingKeywords.where((k) => k.contains(' '))) {
      if (lower.contains(phrase)) codingScore += 2;
    }

    if (scienceScore > 0 && scienceScore >= codingScore) return 'science';
    if (codingScore > 0) return 'coding';
    return null;
  }
}
