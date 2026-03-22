import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'hidden_mode_controller.dart';

/// Banner suggesting the user unlock a hidden mode.
///
/// Shown when [HiddenModeDetector] detects science or coding intent
/// in the Insight input and the mode is not yet unlocked.
class UnlockSuggestion extends ConsumerWidget {
  const UnlockSuggestion({
    super.key,
    required this.mode,
    this.onDismiss,
  });

  /// 'science' or 'coding'
  final String mode;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenState = ref.watch(hiddenModeControllerProvider);
    final tr = context.tr;

    // Don't show if already unlocked
    if (hiddenState.isModeUnlocked(mode)) return const SizedBox.shrink();

    final isScience = mode == 'science';
    final color = isScience ? const Color(0xFF3B82F6) : const Color(0xFF10B981);
    final icon = isScience ? Icons.science_outlined : Icons.code;
    final title = isScience ? tr.hiddenScienceTitle : tr.hiddenCodingTitle;
    final subtitle = isScience ? tr.hiddenScienceSubtitle : tr.hiddenCodingSubtitle;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              GestureDetector(
                onTap: () => context.push('/quiz/$mode'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tr.hiddenUnlockCta,
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onDismiss,
                child: Text(
                  tr.hiddenDismiss,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
