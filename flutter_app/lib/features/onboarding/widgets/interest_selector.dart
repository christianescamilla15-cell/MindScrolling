import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Vertical list of 5 selectable interest tiles.
///
/// Selected tile shows a teal left accent border.
class InterestSelector extends StatelessWidget {
  const InterestSelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String? selected;
  final ValueChanged<String> onSelected;

  // Values and emojis are locale-independent; labels are resolved at build time.
  static const List<({String value, String emoji})> _optionBases = [
    (value: 'philosophy', emoji: '📚'),
    (value: 'stoicism', emoji: '🌿'),
    (value: 'personal_growth', emoji: '📈'),
    (value: 'mindfulness', emoji: '🧘'),
    (value: 'curiosity', emoji: '💡'),
  ];

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final labels = [
      tr.optPhilosophy,
      tr.optStoicism,
      tr.optPersonalGrowth,
      tr.optMindfulness,
      tr.optCuriosity,
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
        const SizedBox(height: 10),
        ...List.generate(_optionBases.length, (i) {
          final base = _optionBases[i];
          return _InterestTile(
            value: base.value,
            label: labels[i],
            emoji: base.emoji,
            isSelected: selected == base.value,
            onTap: () => onSelected(base.value),
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
    required this.onTap,
  });

  final String value;
  final String label;
  final String emoji;
  final bool isSelected;
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
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.stoicism : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                color: isSelected ? AppColors.stoicism : AppColors.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                size: 16,
                color: AppColors.stoicism,
              ),
          ],
        ),
      ),
    );
  }
}
