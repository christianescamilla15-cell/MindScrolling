import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../settings/settings_controller.dart';

/// Lightweight practice console for coding mode.
///
/// Stage A implementation: guided exercises, multiple choice, code completion.
/// No real code execution — educational and pattern-matching based.
class PracticeConsole extends ConsumerStatefulWidget {
  const PracticeConsole({super.key});

  @override
  ConsumerState<PracticeConsole> createState() => _PracticeConsoleState();
}

class _PracticeConsoleState extends ConsumerState<PracticeConsole> {
  int _currentExercise = 0;
  String? _userAnswer;
  bool _showResult = false;
  int _correctCount = 0;
  int _totalAttempts = 0;

  late final List<_Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = _getExercises();
  }

  List<_Exercise> _getExercises() {
    final lang = ref.read(settingsStateProvider).lang;
    if (lang == 'es') return _exercisesEs;
    return _exercisesEn;
  }

  void _submitAnswer(String answer) {
    final exercise = _exercises[_currentExercise];
    final isCorrect = answer.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim();
    setState(() {
      _userAnswer = answer;
      _showResult = true;
      _totalAttempts++;
      if (isCorrect) _correctCount++;
    });
  }

  void _nextExercise() {
    setState(() {
      _currentExercise = (_currentExercise + 1) % _exercises.length;
      _userAnswer = null;
      _showResult = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(settingsStateProvider).lang;
    final exercise = _exercises[_currentExercise];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Score bar
          Row(
            children: [
              const Icon(Icons.terminal, color: Color(0xFF10B981), size: 18),
              const SizedBox(width: 8),
              Text(
                lang == 'es' ? 'Consola de Práctica' : 'Practice Console',
                style: AppTypography.labelSmall.copyWith(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (_totalAttempts > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$_correctCount / $_totalAttempts',
                    style: AppTypography.labelSmall.copyWith(
                      color: const Color(0xFF10B981),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Exercise type badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  exercise.type == _ExerciseType.multipleChoice
                      ? (lang == 'es' ? 'Opción múltiple' : 'Multiple choice')
                      : exercise.type == _ExerciseType.codeCompletion
                          ? (lang == 'es' ? 'Completar código' : 'Complete the code')
                          : (lang == 'es' ? 'Respuesta libre' : 'Free answer'),
                  style: AppTypography.labelSmall.copyWith(
                    color: const Color(0xFF3B82F6),
                    fontSize: 10,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${_currentExercise + 1} / ${_exercises.length}',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Question
          Text(
            exercise.question,
            style: AppTypography.bodyMedium.copyWith(height: 1.5),
          ),
          const SizedBox(height: 8),

          // Code block (if any)
          if (exercise.codeBlock != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D1A),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                exercise.codeBlock!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF10B981),
                  height: 1.6,
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Answer area
          if (exercise.type == _ExerciseType.multipleChoice)
            ...exercise.options!.asMap().entries.map((entry) {
              final isCorrect = entry.value.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim();
              final isSelected = _userAnswer == entry.value;
              Color bgColor = Colors.transparent;
              Color borderColor = AppColors.border;

              if (_showResult) {
                if (isCorrect) {
                  bgColor = const Color(0xFF22C55E).withValues(alpha: 0.15);
                  borderColor = const Color(0xFF22C55E);
                } else if (isSelected) {
                  bgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                  borderColor = const Color(0xFFEF4444);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: _showResult ? null : () => _submitAnswer(entry.value),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Text(
                      entry.value,
                      style: AppTypography.bodySmall,
                    ),
                  ),
                ),
              );
            }),

          if (exercise.type == _ExerciseType.codeCompletion ||
              exercise.type == _ExerciseType.freeAnswer) ...[
            _FreeAnswerField(
              onSubmit: _submitAnswer,
              enabled: !_showResult,
              hint: exercise.hint ?? (lang == 'es' ? 'Tu respuesta...' : 'Your answer...'),
            ),
          ],

          // Result feedback
          if (_showResult) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_userAnswer?.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim())
                    ? const Color(0xFF22C55E).withValues(alpha: 0.1)
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userAnswer?.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim()
                        ? (lang == 'es' ? '¡Correcto!' : 'Correct!')
                        : (lang == 'es' ? 'Respuesta: ${exercise.correctAnswer}' : 'Answer: ${exercise.correctAnswer}'),
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _userAnswer?.toLowerCase().trim() == exercise.correctAnswer.toLowerCase().trim()
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                    ),
                  ),
                  if (exercise.explanation != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      exercise.explanation!,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _nextExercise,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lang == 'es' ? 'Siguiente' : 'Next',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Free answer text field
// ---------------------------------------------------------------------------

class _FreeAnswerField extends StatefulWidget {
  const _FreeAnswerField({
    required this.onSubmit,
    required this.enabled,
    required this.hint,
  });

  final void Function(String) onSubmit;
  final bool enabled;
  final String hint;

  @override
  State<_FreeAnswerField> createState() => _FreeAnswerFieldState();
}

class _FreeAnswerFieldState extends State<_FreeAnswerField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D1A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: _controller,
        enabled: widget.enabled,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: Color(0xFF10B981),
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontFamily: 'monospace',
            fontSize: 14,
            color: AppColors.textMuted.withValues(alpha: 0.5),
          ),
          contentPadding: const EdgeInsets.all(12),
          border: InputBorder.none,
          suffixIcon: widget.enabled
              ? IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF10B981), size: 20),
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      widget.onSubmit(_controller.text);
                    }
                  },
                )
              : null,
        ),
        onSubmitted: widget.enabled ? widget.onSubmit : null,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise model & data
// ---------------------------------------------------------------------------

enum _ExerciseType { multipleChoice, codeCompletion, freeAnswer }

class _Exercise {
  final _ExerciseType type;
  final String question;
  final String? codeBlock;
  final List<String>? options;
  final String correctAnswer;
  final String? hint;
  final String? explanation;

  const _Exercise({
    required this.type,
    required this.question,
    this.codeBlock,
    this.options,
    required this.correctAnswer,
    this.hint,
    this.explanation,
  });
}

const _exercisesEn = <_Exercise>[
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Complete the function to return the sum of two numbers:',
    codeBlock: 'function add(a, b) {\n  return ___;\n}',
    correctAnswer: 'a + b',
    hint: 'What operation combines a and b?',
    explanation: 'The + operator adds two numbers together.',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: 'What does console.log() do in JavaScript?',
    options: ['Saves to a file', 'Prints to the console', 'Creates a variable', 'Sends an HTTP request'],
    correctAnswer: 'Prints to the console',
    explanation: 'console.log() outputs messages to the browser or terminal console.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Complete the for loop to iterate from 0 to 4:',
    codeBlock: 'for (let i = 0; i ___ 5; i++) {\n  console.log(i);\n}',
    correctAnswer: '<',
    hint: 'Which comparison operator?',
    explanation: 'i < 5 means the loop runs while i is less than 5 (0,1,2,3,4).',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: 'Which keyword declares a constant in JavaScript?',
    options: ['var', 'let', 'const', 'static'],
    correctAnswer: 'const',
    explanation: 'const declares a variable that cannot be reassigned.',
  ),
  _Exercise(
    type: _ExerciseType.freeAnswer,
    question: 'What is the output of: 2 + "2" in JavaScript?',
    correctAnswer: '22',
    hint: 'Think about type coercion...',
    explanation: 'JavaScript converts 2 to a string and concatenates: "2" + "2" = "22".',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: 'What does CSS stand for?',
    options: ['Computer Style Sheets', 'Cascading Style Sheets', 'Creative Style System', 'Coded Style Syntax'],
    correctAnswer: 'Cascading Style Sheets',
    explanation: 'CSS = Cascading Style Sheets, used to style HTML elements.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Complete the array method to add an element at the end:',
    codeBlock: 'const arr = [1, 2, 3];\narr.___(4);',
    correctAnswer: 'push',
    hint: 'Which method adds to the end of an array?',
    explanation: 'push() adds one or more elements to the end of an array.',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: 'In HTML, which tag creates a hyperlink?',
    options: ['<link>', '<a>', '<href>', '<url>'],
    correctAnswer: '<a>',
    explanation: 'The <a> (anchor) tag creates clickable hyperlinks.',
  ),
  _Exercise(
    type: _ExerciseType.freeAnswer,
    question: 'What HTTP method is used to retrieve data from a server?',
    correctAnswer: 'GET',
    hint: 'One of the basic HTTP verbs...',
    explanation: 'GET requests retrieve data without modifying server state.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Complete the conditional:',
    codeBlock: '___ (age >= 18) {\n  console.log("Adult");\n}',
    correctAnswer: 'if',
    hint: 'Which keyword starts a conditional?',
    explanation: 'if is the keyword that starts a conditional statement.',
  ),
];

const _exercisesEs = <_Exercise>[
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Completa la función para retornar la suma de dos números:',
    codeBlock: 'function sumar(a, b) {\n  return ___;\n}',
    correctAnswer: 'a + b',
    hint: '¿Qué operación combina a y b?',
    explanation: 'El operador + suma dos números.',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: '¿Qué hace console.log() en JavaScript?',
    options: ['Guarda en un archivo', 'Imprime en la consola', 'Crea una variable', 'Envía una petición HTTP'],
    correctAnswer: 'Imprime en la consola',
    explanation: 'console.log() muestra mensajes en la consola del navegador o terminal.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Completa el bucle for para iterar de 0 a 4:',
    codeBlock: 'for (let i = 0; i ___ 5; i++) {\n  console.log(i);\n}',
    correctAnswer: '<',
    hint: '¿Qué operador de comparación?',
    explanation: 'i < 5 significa que el bucle se ejecuta mientras i sea menor que 5.',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: '¿Qué palabra clave declara una constante en JavaScript?',
    options: ['var', 'let', 'const', 'static'],
    correctAnswer: 'const',
    explanation: 'const declara una variable que no puede ser reasignada.',
  ),
  _Exercise(
    type: _ExerciseType.freeAnswer,
    question: '¿Cuál es el resultado de: 2 + "2" en JavaScript?',
    correctAnswer: '22',
    hint: 'Piensa en la coerción de tipos...',
    explanation: 'JavaScript convierte 2 a string y concatena: "2" + "2" = "22".',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: '¿Qué significa CSS?',
    options: ['Computer Style Sheets', 'Cascading Style Sheets', 'Creative Style System', 'Coded Style Syntax'],
    correctAnswer: 'Cascading Style Sheets',
    explanation: 'CSS = Cascading Style Sheets, usado para dar estilo a elementos HTML.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Completa el método de array para agregar un elemento al final:',
    codeBlock: 'const arr = [1, 2, 3];\narr.___(4);',
    correctAnswer: 'push',
    hint: '¿Qué método agrega al final de un array?',
    explanation: 'push() agrega uno o más elementos al final de un array.',
  ),
  _Exercise(
    type: _ExerciseType.multipleChoice,
    question: 'En HTML, ¿qué etiqueta crea un hipervínculo?',
    options: ['<link>', '<a>', '<href>', '<url>'],
    correctAnswer: '<a>',
    explanation: 'La etiqueta <a> (anchor) crea hipervínculos clickeables.',
  ),
  _Exercise(
    type: _ExerciseType.freeAnswer,
    question: '¿Qué método HTTP se usa para obtener datos de un servidor?',
    correctAnswer: 'GET',
    hint: 'Uno de los verbos HTTP básicos...',
    explanation: 'GET obtiene datos sin modificar el estado del servidor.',
  ),
  _Exercise(
    type: _ExerciseType.codeCompletion,
    question: 'Completa el condicional:',
    codeBlock: '___ (edad >= 18) {\n  console.log("Adulto");\n}',
    correctAnswer: 'if',
    hint: '¿Qué palabra clave inicia un condicional?',
    explanation: 'if es la palabra clave que inicia una sentencia condicional.',
  ),
];
