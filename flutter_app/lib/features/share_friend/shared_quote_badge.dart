import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';

/// Badge that shows "Recommended by [friend name]" on shared quotes.
class SharedQuoteBadge extends StatelessWidget {
  final String fromName;

  const SharedQuoteBadge({super.key, required this.fromName});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.stoicism.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.stoicism.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.people_outline, size: 14, color: AppColors.stoicism),
          const SizedBox(width: 4),
          Text(
            '${tr.recommendedBy} $fromName',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.stoicism,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
