import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// 7 selectable goal cards (pick up to 2).
///
/// Selected card shows an orange accent border.
class GoalSelector extends StatelessWidget {
  const GoalSelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.maxSelections = 2,
  });

  final Set<String> selected;
  final ValueChanged<String> onSelected;
  final int maxSelections;

  // Values and emojis are locale-independent; labels are resolved at build time.
  static const List<({String value, String emoji})> _optionBases = [
    (value: 'calm_mind', emoji: '🧘'),
    (value: 'discipline', emoji: '⚡'),
    (value: 'meaning', emoji: '✨'),
    (value: 'emotional_clarity', emoji: '💎'),
    (value: 'curiosity', emoji: '💡'),
    (value: 'creativity', emoji: '🎨'),
    (value: 'humor', emoji: '😄'),
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final labels = [
      tr.optCalmMind,
      tr.optDiscipline,
      tr.optFindingMeaning,
      tr.optEmotionalClarity,
      tr.optCuriosity,
      tr.optCreativity,
      tr.optHumor,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr.yourGoal,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${selected.length}/$maxSelections ${tr.selected}',
          style: AppTypography.labelSmall.copyWith(
            color: selected.length >= maxSelections
                ? AppColors.discipline
                : AppColors.textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.7,
          children: List.generate(_optionBases.length, (i) {
            final base = _optionBases[i];
            final isSelected = selected.contains(base.value);
            final isDisabled = !isSelected && selected.length >= maxSelections;
            return GestureDetector(
              onTap: isDisabled ? null : () => onSelected(base.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.discipline.withOpacity(0.08)
                      : isDisabled
                          ? AppColors.surfaceVariant.withOpacity(0.5)
                          : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.discipline
                        : isDisabled
                            ? AppColors.border.withOpacity(0.3)
                            : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      base.emoji,
                      style: TextStyle(
                        fontSize: 22,
                        color: isDisabled ? Colors.grey : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      labels[i],
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.discipline
                            : isDisabled
                                ? AppColors.textSecondary.withOpacity(0.4)
                                : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
