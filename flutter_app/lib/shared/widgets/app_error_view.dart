import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import 'app_button.dart';

/// A full-area error state widget that displays a message and an optional
/// retry button.
///
/// Usage:
/// ```dart
/// AppErrorView(
///   message: 'Could not load quotes.',
///   onRetry: () => ref.invalidate(feedProvider),
/// )
/// ```
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
  });

  /// Human-readable description of the error.
  final String message;

  /// Called when the user taps the retry button.
  /// If `null`, no retry button is shown.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to `'Retry'`.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Error icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.textMuted,
                size: 28,
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                label: retryLabel,
                onPressed: onRetry,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
