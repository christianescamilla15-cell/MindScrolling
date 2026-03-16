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

  static const List<({String value, String label, IconData icon})> _options = [
    (value: 'philosophy', label: 'Philosophy', icon: Icons.auto_stories_outlined),
    (value: 'stoicism', label: 'Stoicism', icon: Icons.park_outlined),
    (value: 'personal_growth', label: 'Personal Growth', icon: Icons.trending_up_outlined),
    (value: 'mindfulness', label: 'Mindfulness', icon: Icons.spa_outlined),
    (value: 'curiosity', label: 'Curiosity', icon: Icons.lightbulb_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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

  final ({String value, String label, IconData icon}) option;
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
          border: Border(
            left: BorderSide(
              color: isSelected ? AppColors.stoicism : Colors.transparent,
              width: 3,
            ),
            top: BorderSide(
              color: isSelected
                  ? AppColors.stoicism.withOpacity(0.2)
                  : AppColors.border,
            ),
            right: BorderSide(
              color: isSelected
                  ? AppColors.stoicism.withOpacity(0.2)
                  : AppColors.border,
            ),
            bottom: BorderSide(
              color: isSelected
                  ? AppColors.stoicism.withOpacity(0.2)
                  : AppColors.border,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 20,
              color: isSelected ? AppColors.stoicism : AppColors.textSecondary,
            ),
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
              Icon(
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
