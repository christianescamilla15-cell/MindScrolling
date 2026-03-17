import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../extensions/context_extensions.dart';

/// Shows a fullscreen milestone card for streak achievements (7 or 30 days).
///
/// Appears once per milestone. Dismisses with a single tap.
/// Inspired by Headspace — minimal, emotional, one message.
class StreakMilestoneDialog {
  StreakMilestoneDialog._();

  /// Check if a milestone should be shown for the given [streak].
  /// Shows once per milestone (stored in SharedPreferences).
  static Future<void> checkAndShow(BuildContext context, int streak) async {
    if (streak != 7 && streak != 30) return;

    final prefs = await SharedPreferences.getInstance();
    final key = 'mindscroll_milestone_$streak';
    final alreadyShown = prefs.getBool(key) ?? false;
    if (alreadyShown) return;

    await prefs.setBool(key, true);

    if (!context.mounted) return;

    final tr = context.tr;
    final title = streak == 7 ? tr.milestone7Title : tr.milestone30Title;
    final msg = streak == 7 ? tr.milestone7Msg : tr.milestone30Msg;

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black87,
      builder: (c) => _MilestoneView(
        title: title,
        message: msg,
        streak: streak,
        onClose: () => Navigator.pop(c),
      ),
    );
  }
}

class _MilestoneView extends StatelessWidget {
  final String title;
  final String message;
  final int streak;
  final VoidCallback onClose;

  const _MilestoneView({
    required this.title,
    required this.message,
    required this.streak,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Streak number
                Text(
                  '$streak',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 72,
                    fontWeight: FontWeight.w700,
                    color: AppColors.stoicism.withOpacity(0.8),
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),

                // Divider
                Container(width: 40, height: 1.5, color: AppColors.stoicism.withOpacity(0.4)),
                const SizedBox(height: 24),

                // Title
                Text(
                  title,
                  style: AppTypography.displayMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Message
                Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Close hint
                Text(
                  context.tr.milestoneClose,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
