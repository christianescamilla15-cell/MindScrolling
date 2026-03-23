import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/content_constants.dart';
import '../../core/utils/haptics_service.dart';
import '../../shared/extensions/context_extensions.dart';
import '../settings/settings_controller.dart';
import 'hidden_mode_controller.dart';
import 'quiz_data.dart';

/// Quiz screen for hidden mode access gating.
///
/// Shows 10 multiple-choice questions. Requires >=8 correct to unlock.
class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.mode});

  /// 'science' or 'coding'
  final String mode;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  late final List<QuizQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedOption;
  bool _answered = false;
  bool _quizComplete = false;

  @override
  void initState() {
    super.initState();
    _questions = pickRandomQuestions(
      widget.mode == 'science' ? scienceQuizQuestions : codingQuizQuestions,
      count: ContentConstants.quizQuestionCount,
    );
  }

  void _selectOption(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == _questions[_currentIndex].correctIndex) {
        _score++;
        HapticsService.lightImpact();
      } else {
        HapticsService.mediumImpact();
      }
    });

    // Auto-advance after brief delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedOption = null;
          _answered = false;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  void _finishQuiz() {
    final passed = _score >= ContentConstants.quizPassThreshold;
    if (passed) {
      ref.read(hiddenModeControllerProvider.notifier)
          .unlockMode(widget.mode, _score);
      HapticsService.heavyImpact();
    } else {
      ref.read(hiddenModeControllerProvider.notifier)
          .recordQuizAttempt(widget.mode, _score);
    }
    setState(() => _quizComplete = true);
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final lang = ref.watch(settingsStateProvider).lang;
    final isScience = widget.mode == 'science';
    final color = isScience ? const Color(0xFF3B82F6) : const Color(0xFF10B981);

    if (_quizComplete) {
      return _buildResultScreen(tr, color);
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          tr.quizTitle,
          style: AppTypography.displaySmall,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress bar
              Row(
                children: [
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: AppTypography.labelSmall.copyWith(color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentIndex + 1) / _questions.length,
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    tr.quizScore(_score, _currentIndex + (_answered ? 1 : 0)),
                    style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Question
              Text(
                question.question(lang),
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 20,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),

              // Options
              ...List.generate(question.options(lang).length, (i) {
                final isCorrect = i == question.correctIndex;
                final isSelected = _selectedOption == i;
                Color optionColor;
                Color borderColor;

                if (_answered) {
                  if (isCorrect) {
                    optionColor = const Color(0xFF22C55E).withValues(alpha: 0.15);
                    borderColor = const Color(0xFF22C55E);
                  } else if (isSelected) {
                    optionColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
                    borderColor = const Color(0xFFEF4444);
                  } else {
                    optionColor = Colors.transparent;
                    borderColor = AppColors.border;
                  }
                } else {
                  optionColor = isSelected ? color.withValues(alpha: 0.1) : Colors.transparent;
                  borderColor = isSelected ? color : AppColors.border;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => _selectOption(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: optionColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _answered && isCorrect
                                  ? const Color(0xFF22C55E)
                                  : _answered && isSelected
                                      ? const Color(0xFFEF4444)
                                      : Colors.transparent,
                              border: Border.all(
                                color: _answered && isCorrect
                                    ? const Color(0xFF22C55E)
                                    : _answered && isSelected
                                        ? const Color(0xFFEF4444)
                                        : AppColors.textMuted,
                              ),
                            ),
                            child: Center(
                              child: _answered && isCorrect
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : _answered && isSelected
                                      ? const Icon(Icons.close, size: 16, color: Colors.white)
                                      : Text(
                                          String.fromCharCode(65 + i), // A, B, C, D
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.textMuted,
                                          ),
                                        ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.options(lang)[i],
                              style: AppTypography.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen(dynamic tr, Color color) {
    final passed = _score >= ContentConstants.quizPassThreshold;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (passed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B))
                      .withValues(alpha: 0.15),
                ),
                child: Icon(
                  passed ? Icons.emoji_events : Icons.timer_outlined,
                  size: 40,
                  color: passed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                passed ? tr.quizPassedTitle : tr.quizFailedTitle,
                style: AppTypography.displaySmall.copyWith(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Score
              Text(
                tr.quizScore(_score, _questions.length),
                style: AppTypography.displaySmall.copyWith(
                  fontSize: 36,
                  color: passed ? const Color(0xFF22C55E) : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(height: 16),

              // Body
              Text(
                passed ? tr.quizPassedBody : tr.quizFailedBody,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Action button
              GestureDetector(
                onTap: () {
                  if (passed) {
                    // Navigate to the unlocked mode
                    context.go('/hidden/${widget.mode}');
                  } else {
                    context.pop();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  decoration: BoxDecoration(
                    color: passed ? color : Colors.transparent,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: passed ? color : AppColors.border),
                  ),
                  child: Text(
                    passed ? (widget.mode == 'science' ? tr.quizEnterScience : tr.quizEnterCoding) : tr.quizRetry,
                    style: AppTypography.bodyMedium.copyWith(
                      color: passed ? Colors.white : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
