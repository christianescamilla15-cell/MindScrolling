import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// 4 selectable goal cards.
///
/// Selected card shows an orange accent border.
class GoalSelector extends StatelessWidget {
  const GoalSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  static const List<({String value, String label, String emoji})> _options = [
    (value: 'calm_mind', label: 'Calm Mind', emoji: '🧘'),
    (value: 'discipline', label: 'Discipline', emoji: '⚡'),
    (value: 'meaning', label: 'Finding Meaning', emoji: '✨'),
    (value: 'emotional_clarity', label: 'Emotional Clarity', emoji: '💎'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your goal',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
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
          children: _options.map((opt) {
            final isSelected = selected == opt.value;
            return GestureDetector(
              onTap: () => onSelected(opt.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.discipline.withOpacity(0.08)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.discipline
                        : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      opt.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      opt.label,
                      style: AppTypography.bodySmall.copyWith(
                        color: isSelected
                            ? AppColors.discipline
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
          }).toList(),
        ),
      ],
    );
  }
}
