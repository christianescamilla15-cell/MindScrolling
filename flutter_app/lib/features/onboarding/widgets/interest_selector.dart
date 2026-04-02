import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Vertical list of 7 selectable interest tiles.
/// Multi-select: user can pick 1-3 interests.
class InterestSelector extends StatelessWidget {
  const InterestSelector({
    super.key,
    required this.selected,
    required this.onToggle,
    this.maxSelections = 3,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final int maxSelections;

  static const List<({String value, String emoji})> _optionBases = [
    (value: 'philosophy', emoji: '📚'),
    (value: 'stoicism', emoji: '🌿'),
    (value: 'personal_growth', emoji: '📈'),
    (value: 'mindfulness', emoji: '🧘'),
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final labels = [
      tr.optPhilosophy,
      tr.optStoicism,
      tr.optPersonalGrowth,
      tr.optMindfulness,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          tr.primaryInterest,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${selected.length}/$maxSelections ${tr.selected}',
          style: AppTypography.labelSmall.copyWith(
            color: selected.length >= maxSelections
                ? AppColors.stoicism
                : AppColors.textSecondary.withOpacity(0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...List.generate(_optionBases.length, (i) {
          final base = _optionBases[i];
          final isSelected = selected.contains(base.value);
          final isDisabled = !isSelected && selected.length >= maxSelections;

          return _InterestTile(
            value: base.value,
            label: labels[i],
            emoji: base.emoji,
            isSelected: isSelected,
            isDisabled: isDisabled,
            onTap: () {
              if (isDisabled) return;
              onToggle(base.value);
            },
          );
        }),
      ],
    );
  }
}

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.value,
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  final String value;
  final String label;
  final String emoji;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.stoicism.withOpacity(0.08)
              : isDisabled
                  ? AppColors.surfaceVariant.withOpacity(0.5)
                  : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppColors.stoicism
                : isDisabled
                    ? AppColors.border.withOpacity(0.3)
                    : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: TextStyle(
              fontSize: 20,
              color: isDisabled ? Colors.grey : null,
            )),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.stoicism
                    : isDisabled
                        ? AppColors.textSecondary.withOpacity(0.4)
                        : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, size: 16, color: AppColors.stoicism),
          ],
        ),
      ),
    );
  }
}
