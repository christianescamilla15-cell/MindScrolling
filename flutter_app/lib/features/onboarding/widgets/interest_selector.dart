import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

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

  static const List<({String value, String label, String emoji})> _options = [
    (value: 'philosophy', label: 'Philosophy', emoji: '📚'),
    (value: 'stoicism', label: 'Stoicism', emoji: '🌿'),
    (value: 'personal_growth', label: 'Personal Growth', emoji: '📈'),
    (value: 'mindfulness', label: 'Mindfulness', emoji: '🧘'),
    (value: 'curiosity', label: 'Curiosity', emoji: '💡'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Primary interest',
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        ...(_options.map((opt) => _InterestTile(
              option: opt,
              isSelected: selected == opt.value,
              onTap: () => onSelected(opt.value),
            ))),
      ],
    );
  }
}

class _InterestTile extends StatelessWidget {
  const _InterestTile({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final ({String value, String label, String emoji}) option;
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
            Text(option.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Text(
              option.label,
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
