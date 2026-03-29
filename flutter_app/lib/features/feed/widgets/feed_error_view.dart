import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

class FeedErrorView extends StatelessWidget {
  const FeedErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onRetry,
              child: Text(context.tr.tryAgain, style: const TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}
