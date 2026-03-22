import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'exercise_model.dart';
import 'practice_controller.dart';

// ---------------------------------------------------------------------------
// Language chip metadata
// ---------------------------------------------------------------------------

const _kLanguages = [
  _LangMeta('all', 'All', Color(0xFF94A3B8)),
  _LangMeta('python', 'Python', Color(0xFF3776AB)),
  _LangMeta('javascript', 'JavaScript', Color(0xFFF7DF1E)),
  _LangMeta('java', 'Java', Color(0xFFED8B00)),
  _LangMeta('c++', 'C++', Color(0xFF00599C)),
  _LangMeta('go', 'Go', Color(0xFF00ADD8)),
  _LangMeta('rust', 'Rust', Color(0xFFCE422B)),
  _LangMeta('sql', 'SQL', Color(0xFF336791)),
  _LangMeta('typescript', 'TypeScript', Color(0xFF3178C6)),
  _LangMeta('swift', 'Swift', Color(0xFFFA7343)),
  _LangMeta('kotlin', 'Kotlin', Color(0xFF7F52FF)),
  _LangMeta('php', 'PHP', Color(0xFF777BB4)),
  _LangMeta('ruby', 'Ruby', Color(0xFFCC342D)),
  _LangMeta('c#', 'C#', Color(0xFF239120)),
];

class _LangMeta {
  const _LangMeta(this.key, this.label, this.color);
  final String key;
  final String label;
  final Color color;
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class PracticeConsoleScreen extends ConsumerStatefulWidget {
  const PracticeConsoleScreen({super.key});

  @override
  ConsumerState<PracticeConsoleScreen> createState() =>
      _PracticeConsoleScreenState();
}

class _PracticeConsoleScreenState
    extends ConsumerState<PracticeConsoleScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(practiceControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      ref.read(practiceControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _refresh() {
    return ref.read(practiceControllerProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final state = ref.watch(practiceControllerProvider);

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
            const Icon(Icons.terminal, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Text(tr.practiceConsole, style: AppTypography.displaySmall),
          ],
        ),
        centerTitle: true,
        actions: [
          if (state.totalCompleted > 0 || state.totalPoints > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _StatsChip(
                completed: state.totalCompleted,
                points: state.totalPoints,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Language selector
          _LanguageSelector(
            selectedLanguage: state.selectedLanguage,
            onSelected: (lang) =>
                ref.read(practiceControllerProvider.notifier).setLanguage(lang),
          ),
          // Difficulty filter
          _DifficultyFilter(
            selected: state.selectedDifficulty,
            onSelected: (d) =>
                ref.read(practiceControllerProvider.notifier).setDifficulty(d),
            tr: tr,
          ),
          const Divider(color: AppColors.border, height: 1),
          // Exercise list
          Expanded(
            child: _ExerciseList(
              state: state,
              scrollController: _scrollController,
              onRefresh: _refresh,
              tr: tr,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Language selector
// ---------------------------------------------------------------------------

class _LanguageSelector extends StatelessWidget {
  const _LanguageSelector({
    required this.selectedLanguage,
    required this.onSelected,
  });

  final String selectedLanguage;
  final void Function(String) onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _kLanguages.length,
        itemBuilder: (context, i) {
          final meta = _kLanguages[i];
          final isSelected = selectedLanguage == meta.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelected(meta.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? meta.color.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? meta.color
                        : AppColors.border,
                  ),
                ),
                child: Text(
                  meta.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? meta.color : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Difficulty filter
// ---------------------------------------------------------------------------

class _DifficultyFilter extends StatelessWidget {
  const _DifficultyFilter({
    required this.selected,
    required this.onSelected,
    required this.tr,
  });

  final int selected;
  final void Function(int) onSelected;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Row(
        children: [
          Text(
            context.tr.selectDifficulty,
            style: AppTypography.caption,
          ),
          const SizedBox(width: 12),
          // 0 = all, 1-5 = specific
          _DiffChip(value: 0, selected: selected, label: context.tr.allLanguages, onTap: onSelected),
          const SizedBox(width: 6),
          for (int d = 1; d <= 5; d++) ...[
            _DiffChip(value: d, selected: selected, label: '$d', onTap: onSelected, isStarMode: true),
            if (d < 5) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _DiffChip extends StatelessWidget {
  const _DiffChip({
    required this.value,
    required this.selected,
    required this.label,
    required this.onTap,
    this.isStarMode = false,
  });

  final int value;
  final int selected;
  final String label;
  final void Function(int) onTap;
  final bool isStarMode;

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == value;
    final color = isStarMode
        ? const Color(0xFFF59E0B)
        : const Color(0xFF10B981);

    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: isStarMode ? 30 : null,
        height: 26,
        padding: isStarMode
            ? EdgeInsets.zero
            : const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Center(
          child: isStarMode
              ? Icon(
                  isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 15,
                  color: isSelected ? color : AppColors.textMuted,
                )
              : Text(
                  label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? color : AppColors.textMuted,
                    letterSpacing: 0,
                  ),
                ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise list
// ---------------------------------------------------------------------------

class _ExerciseList extends StatelessWidget {
  const _ExerciseList({
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.tr,
  });

  final PracticeState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF10B981),
          strokeWidth: 2,
        ),
      );
    }

    if (state.error != null && state.exercises.isEmpty) {
      return _ErrorState(message: state.error!, onRetry: onRefresh);
    }

    if (state.exercises.isEmpty) {
      return _EmptyState(tr: tr);
    }

    return RefreshIndicator(
      color: const Color(0xFF10B981),
      backgroundColor: AppColors.surface,
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
        itemCount: state.exercises.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == state.exercises.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          return _ExerciseCard(exercise: state.exercises[i]);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Exercise card
// ---------------------------------------------------------------------------

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    final langColor = _languageColor(exercise.language);
    final (statusColor, statusIcon) = _statusMeta(exercise.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push(
          '/exercise/${exercise.id}',
          extra: exercise,
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: title + status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      exercise.title,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(statusIcon, size: 18, color: statusColor),
                ],
              ),
              const SizedBox(height: 8),
              // Bottom row: language badge, stars, time, points
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: langColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: langColor.withValues(alpha: 0.35)),
                    ),
                    child: Text(
                      exercise.language.toUpperCase(),
                      style: AppTypography.labelSmall.copyWith(
                        color: langColor,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MiniStars(difficulty: exercise.difficulty),
                  const SizedBox(width: 8),
                  const Icon(Icons.timer_outlined,
                      size: 12, color: AppColors.textMuted),
                  const SizedBox(width: 3),
                  Text(
                    '${exercise.estimatedTime}m',
                    style: AppTypography.caption,
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '+${exercise.points}',
                      style: AppTypography.labelSmall.copyWith(
                        color: const Color(0xFFF59E0B),
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniStars extends StatelessWidget {
  const _MiniStars({required this.difficulty});

  final int difficulty;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < difficulty ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 11,
          color: i < difficulty
              ? const Color(0xFFF59E0B)
              : AppColors.textMuted,
        );
      }),
    );
  }
}

// ---------------------------------------------------------------------------
// Stats chip in AppBar
// ---------------------------------------------------------------------------

class _StatsChip extends StatelessWidget {
  const _StatsChip({required this.completed, required this.points});

  final int completed;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF10B981).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline_rounded,
              size: 13, color: Color(0xFF10B981)),
          const SizedBox(width: 4),
          Text(
            '$completed',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFF10B981),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.bolt_rounded,
              size: 13, color: Color(0xFFF59E0B)),
          Text(
            '$points',
            style: AppTypography.labelSmall.copyWith(
              color: const Color(0xFFF59E0B),
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty / error states
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.tr});

  final dynamic tr;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.code_off_rounded,
              size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            context.tr.noExercises,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF10B981)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  context.tr.retry,
                  style: AppTypography.bodySmall.copyWith(
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ],
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
    case 'python':       return const Color(0xFF3776AB);
    case 'javascript':
    case 'js':           return const Color(0xFFF7DF1E);
    case 'java':         return const Color(0xFFED8B00);
    case 'c++':
    case 'cpp':          return const Color(0xFF00599C);
    case 'go':
    case 'golang':       return const Color(0xFF00ADD8);
    case 'rust':         return const Color(0xFFCE422B);
    case 'sql':          return const Color(0xFF336791);
    case 'typescript':
    case 'ts':           return const Color(0xFF3178C6);
    case 'swift':        return const Color(0xFFFA7343);
    case 'kotlin':       return const Color(0xFF7F52FF);
    case 'php':          return const Color(0xFF777BB4);
    case 'ruby':         return const Color(0xFFCC342D);
    case 'c#':
    case 'csharp':       return const Color(0xFF239120);
    default:             return AppColors.textMuted;
  }
}

(Color, IconData) _statusMeta(String status) {
  return switch (status) {
    'completed'   => (const Color(0xFF22C55E), Icons.check_circle_rounded),
    'in_progress' => (const Color(0xFFF59E0B), Icons.radio_button_checked_rounded),
    'skipped'     => (AppColors.textMuted, Icons.skip_next_rounded),
    _             => (AppColors.textMuted, Icons.radio_button_unchecked_rounded),
  };
}
