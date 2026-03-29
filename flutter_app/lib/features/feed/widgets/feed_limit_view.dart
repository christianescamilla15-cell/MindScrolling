import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

class FeedLimitView extends StatelessWidget {
  const FeedLimitView({super.key, required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.stoicism, size: 48),
            const SizedBox(height: 16),
            Text(
              context.tr.feedLimitReached,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onUpgrade,
              child: Text(
                context.tr.premiumUnlock,
                style: const TextStyle(color: AppColors.stoicism),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
