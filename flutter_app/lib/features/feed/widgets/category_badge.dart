import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Small pill badge showing the category label with its accent color.
///
/// Translates category slugs (stoicism, philosophy, etc.) to localized labels.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.categoryColor(category);
    final label = _localizedLabel(category, context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35), width: 1),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: color,
          letterSpacing: 1.4,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _localizedLabel(String cat, BuildContext context) {
    final tr = context.tr;
    return switch (cat.toLowerCase()) {
      'stoicism'   => tr.stoicism,
      'philosophy' => tr.philosophy,
      'discipline' => tr.discipline,
      'reflection' => tr.reflection,
      _            => cat,
    };
  }
}
