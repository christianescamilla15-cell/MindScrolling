import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/network/api_client.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/extensions/context_extensions.dart';
import '../settings/settings_controller.dart';
import 'exercise_model.dart';
import 'practice_controller.dart';

// ---------------------------------------------------------------------------
// Per-exercise state for hints and submission result
// ---------------------------------------------------------------------------

class _ExerciseDetailState {
  const _ExerciseDetailState({
    this.hints = const {},
    this.isLoadingHint = false,
    this.submitResult,
    this.isSubmitting = false,
    this.isSkipping = false,
    this.exercise,
  });

  /// Map of hint_number (1,2,3) to revealed hint text.
  final Map<int, String> hints;
  final bool isLoadingHint;

  /// null = not yet submitted, true = correct, false = incorrect.
  final bool? submitResult;
  final bool isSubmitting;
  final bool isSkipping;
  final ExerciseModel? exercise;

  _ExerciseDetailState copyWith({
    Map<int, String>? hints,
    bool? isLoadingHint,
    bool? submitResult,
    bool? isSubmitting,
    bool? isSkipping,
    ExerciseModel? exercise,
  }) {
    return _ExerciseDetailState(
      hints: hints ?? this.hints,
      isLoadingHint: isLoadingHint ?? this.isLoadingHint,
      submitResult: submitResult,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSkipping: isSkipping ?? this.isSkipping,
      exercise: exercise ?? this.exercise,
    );
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class ExerciseDetailScreen extends ConsumerStatefulWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  final ExerciseModel exercise;

  @override
  ConsumerState<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState
    extends ConsumerState<ExerciseDetailScreen> {
  late _ExerciseDetailState _state;
  late final TextEditingController _codeController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _state = _ExerciseDetailState(exercise: widget.exercise);
    _codeController = TextEditingController(
      text: widget.exercise.starterCode ?? '',
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // API actions
  // -------------------------------------------------------------------------

  Future<void> _fetchHint(int hintNumber) async {
    if (_state.hints.containsKey(hintNumber)) return;
    if (_state.isLoadingHint) return;

    setState(() {
      _state = _state.copyWith(isLoadingHint: true);
    });

    final api = ref.read(apiClientProvider);
    final lang = ref.read(settingsStateProvider).lang;
    final exerciseId = _state.exercise!.id;

    try {
      final result = await api.post(
        '/exercises/$exerciseId/hint',
        body: {'hint_number': hintNumber, 'lang': lang},
      );
      final hintText = (result['hint'] as String?) ?? '';
      if (!mounted) return;
      final updatedHints = Map<int, String>.from(_state.hints)
        ..[hintNumber] = hintText;
      setState(() {
        _state = _state.copyWith(
          hints: updatedHints,
          isLoadingHint: false,
        );
      });
      // Also update hintsUsed in the exercise
      final updatedExercise = _state.exercise!.copyWith(
        hintsUsed: updatedHints.length,
        status: _state.exercise!.status == 'not_started'
            ? 'in_progress'
            : _state.exercise!.status,
      );
      setState(() {
        _state = _state.copyWith(exercise: updatedExercise);
      });
      ref.read(practiceControllerProvider.notifier).updateExercise(updatedExercise);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isLoadingHint: false);
      });
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isLoadingHint: false);
      });
    }
  }

  Future<void> _submit() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _state.isSubmitting) return;

    setState(() {
      _state = _state.copyWith(isSubmitting: true, submitResult: null);
    });

    final api = ref.read(apiClientProvider);
    final lang = ref.read(settingsStateProvider).lang;
    final exerciseId = _state.exercise!.id;

    try {
      final result = await api.post(
        '/exercises/$exerciseId/submit',
        body: {'code': code, 'lang': lang},
      );
      if (!mounted) return;

      final correct = (result['correct'] as bool?) ?? false;
      final newAttempts = _state.exercise!.attempts + 1;
      final newStatus = correct ? 'completed' : 'in_progress';
      final updatedExercise = _state.exercise!.copyWith(
        status: newStatus,
        attempts: newAttempts,
      );

      setState(() {
        _state = _state.copyWith(
          submitResult: correct,
          isSubmitting: false,
          exercise: updatedExercise,
        );
      });

      if (correct) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }

      ref.read(practiceControllerProvider.notifier).updateExercise(updatedExercise);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isSubmitting: false);
      });
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isSubmitting: false);
      });
    }
  }

  Future<void> _skip() async {
    if (_state.isSkipping) return;
    setState(() {
      _state = _state.copyWith(isSkipping: true);
    });

    final api = ref.read(apiClientProvider);
    final lang = ref.read(settingsStateProvider).lang;
    final exerciseId = _state.exercise!.id;

    try {
      await api.post(
        '/exercises/$exerciseId/skip',
        body: {'lang': lang},
      );
      if (!mounted) return;
      final updatedExercise = _state.exercise!.copyWith(status: 'skipped');
      ref.read(practiceControllerProvider.notifier).updateExercise(updatedExercise);
      if (mounted) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isSkipping: false);
      });
      _showError(e.message);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _state = _state.copyWith(isSkipping: false);
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.bodySmall),
        backgroundColor: const Color(0xFFEF4444),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final exercise = _state.exercise!;
    final langColor = _languageColor(exercise.language);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: langColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: langColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                exercise.language.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(color: langColor),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                exercise.title,
                style: AppTypography.displaySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_state.exercise!.status != 'completed')
            TextButton(
              onPressed: _state.isSkipping ? null : _skip,
              child: Text(
                tr.skipExercise,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _MetaRow(exercise: exercise),
            const SizedBox(height: 16),
            if (_state.exercise!.status == 'completed')
              _CompletedBanner(points: exercise.points, tr: tr),
            const SizedBox(height: 16),
            _DescriptionCard(description: exercise.description),
            const SizedBox(height: 16),
            if (exercise.starterCode != null &&
                exercise.starterCode!.isNotEmpty) ...[
              _StarterCodeBox(code: exercise.starterCode!),
              const SizedBox(height: 16),
            ],
            _CodeInputArea(
              controller: _codeController,
              enabled: _state.exercise!.status != 'completed' &&
                  !_state.isSubmitting,
              tr: tr,
            ),
            const SizedBox(height: 16),
            _HintsSection(
              exercise: exercise,
              hints: _state.hints,
              isLoadingHint: _state.isLoadingHint,
              onFetchHint: _fetchHint,
              tr: tr,
            ),
            if (_state.submitResult != null) ...[
              const SizedBox(height: 16),
              _SubmitResultBanner(
                correct: _state.submitResult!,
                points: exercise.points,
                tr: tr,
              ),
            ],
            const SizedBox(height: 24),
            if (_state.exercise!.status != 'completed')
              _SubmitButton(
                isSubmitting: _state.isSubmitting,
                onSubmit: _submit,
                tr: tr,
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return Row(
      children: [
        _DifficultyStars(difficulty: exercise.difficulty),
        const SizedBox(width: 12),
        Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          '${exercise.estimatedTime} min',
          style: AppTypography.caption,
        ),
        const SizedBox(width: 12),
        _PointsBadge(points: exercise.points, tr: tr),
        const Spacer(),
        _StatusBadge(status: exercise.status, tr: tr),
      ],
    );
  }
}

class _DifficultyStars extends StatelessWidget {
  const _DifficultyStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < difficulty
              ? const Color(0xFFF59E0B)
              : AppColors.textMuted,
        );
      }),
    );
  }
}

class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points, required this.tr});

  final int points;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '+$points pts',
        style: AppTypography.labelSmall.copyWith(
          color: const Color(0xFFF59E0B),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.tr});

  final String status;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final (color, label) = switch (status) {
      'completed'   => (const Color(0xFF22C55E), tr.correct),
      'in_progress' => (const Color(0xFFF59E0B), tr.inProgressLabel),
      'skipped'     => (AppColors.textMuted,     tr.skippedLabel),
      _             => (AppColors.textMuted,     tr.notStartedLabel),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _CompletedBanner extends StatelessWidget {
  const _CompletedBanner({required this.points, required this.tr});

  final int points;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF22C55E).withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: Color(0xFF22C55E),
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            context.tr.correct,
            style: AppTypography.bodyMedium.copyWith(
              color: const Color(0xFF22C55E),
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '+$points pts',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF22C55E),
            ),
          ),
        ],
      ),
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        description,
        style: AppTypography.bodyMedium.copyWith(height: 1.6),
      ),
    );
  }
}

class _StarterCodeBox extends StatelessWidget {
  const _StarterCodeBox({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.starterCodeLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            code,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Color(0xFF10B981),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

class _CodeInputArea extends StatelessWidget {
  const _CodeInputArea({
    required this.controller,
    required this.enabled,
    required this.tr,
  });

  final TextEditingController controller;
  final bool enabled;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.yourCodeLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0D0D1A),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            maxLines: 10,
            keyboardType: TextInputType.multiline,
            autocorrect: false,
            enableSuggestions: false,
            textCapitalization: TextCapitalization.none,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              color: Color(0xFFF5F0E8),
              height: 1.6,
            ),
            decoration: InputDecoration(
              hintText: context.tr.submitCode,
              hintStyle: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: Color(0x40F5F0E8),
              ),
              contentPadding: const EdgeInsets.all(14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _HintsSection extends StatelessWidget {
  const _HintsSection({
    required this.exercise,
    required this.hints,
    required this.isLoadingHint,
    required this.onFetchHint,
    required this.tr,
  });

  final ExerciseModel exercise;
  final Map<int, String> hints;
  final bool isLoadingHint;
  final void Function(int) onFetchHint;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.hintsLabel,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        for (int i = 1; i <= 3; i++) ...[
          _HintTile(
            hintNumber: i,
            revealedText: hints[i],
            isLoading: isLoadingHint && !hints.containsKey(i),
            alreadyUsed: hints.containsKey(i),
            revealEnabled: i == 1 || hints.containsKey(i - 1),
            onReveal: () => onFetchHint(i),
            tr: tr,
          ),
          if (i < 3) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _HintTile extends StatelessWidget {
  const _HintTile({
    required this.hintNumber,
    required this.revealedText,
    required this.isLoading,
    required this.alreadyUsed,
    required this.revealEnabled,
    required this.onReveal,
    required this.tr,
  });

  final int hintNumber;
  final String? revealedText;
  final bool isLoading;
  final bool alreadyUsed;
  final bool revealEnabled;
  final VoidCallback onReveal;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      alignment: Alignment.topCenter,
      child: Container(
        decoration: BoxDecoration(
          color: alreadyUsed
              ? const Color(0xFF7B9FE0).withValues(alpha: 0.07)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: alreadyUsed
                ? const Color(0xFF7B9FE0).withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Column(
          children: [
            ListTile(
              dense: true,
              leading: Icon(
                alreadyUsed
                    ? Icons.lightbulb_rounded
                    : Icons.lightbulb_outline_rounded,
                size: 18,
                color: alreadyUsed
                    ? const Color(0xFF7B9FE0)
                    : AppColors.textMuted,
              ),
              title: Text(
                '${context.tr.exerciseHint} $hintNumber',
                style: AppTypography.bodySmall.copyWith(
                  color: alreadyUsed
                      ? const Color(0xFF7B9FE0)
                      : AppColors.textSecondary,
                  fontWeight:
                      alreadyUsed ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              trailing: alreadyUsed
                  ? null
                  : isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF7B9FE0),
                          ),
                        )
                      : TextButton(
                          onPressed: revealEnabled ? onReveal : null,
                          child: Text(
                            context.tr.reveal,
                            style: AppTypography.labelSmall.copyWith(
                              color: revealEnabled
                                  ? const Color(0xFF7B9FE0)
                                  : AppColors.textMuted,
                            ),
                          ),
                        ),
            ),
            if (revealedText != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Text(
                  revealedText!,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SubmitResultBanner extends StatelessWidget {
  const _SubmitResultBanner({
    required this.correct,
    required this.points,
    required this.tr,
  });

  final bool correct;
  final int points;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    final color =
        correct ? const Color(0xFF22C55E) : const Color(0xFFEF4444);
    final icon =
        correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final label = correct ? context.tr.correct : context.tr.incorrect;
    final sub = correct
        ? '+$points ${context.tr.ptsEarned}'
        : context.tr.tryAgain;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        boxShadow: correct
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ]
            : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                sub,
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.isSubmitting,
    required this.onSubmit,
    required this.tr,
  });

  final bool isSubmitting;
  final VoidCallback onSubmit;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isSubmitting ? null : onSubmit,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSubmitting
              ? const Color(0xFF10B981).withValues(alpha: 0.5)
              : const Color(0xFF10B981),
          borderRadius: BorderRadius.circular(14),
        ),
        child: isSubmitting
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              )
            : Text(
                context.tr.submitCode,
                style: AppTypography.buttonLabel.copyWith(
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Color _languageColor(String language) {
  switch (language.toLowerCase()) {
    case 'python':
      return const Color(0xFF3776AB);
    case 'javascript':
    case 'js':
      return const Color(0xFFF7DF1E);
    case 'java':
      return const Color(0xFFED8B00);
    case 'c++':
    case 'cpp':
      return const Color(0xFF00599C);
    case 'go':
    case 'golang':
      return const Color(0xFF00ADD8);
    case 'rust':
      return const Color(0xFFCE422B);
    case 'sql':
      return const Color(0xFF336791);
    case 'typescript':
    case 'ts':
      return const Color(0xFF3178C6);
    case 'swift':
      return const Color(0xFFFA7343);
    case 'kotlin':
      return const Color(0xFF7F52FF);
    case 'php':
      return const Color(0xFF777BB4);
    case 'ruby':
      return const Color(0xFFCC342D);
    case 'c#':
    case 'csharp':
      return const Color(0xFF239120);
    default:
      return AppColors.textMuted;
  }
}
