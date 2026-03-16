import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// Periodic mindfulness interstitial card.
///
/// Appears automatically after every 5 swipes. Simple, calm, non-intrusive.
class ReflectionCard extends StatelessWidget {
  const ReflectionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.reflection.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Subtle gradient accent top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.reflection.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '✦',
                  style: TextStyle(
                    fontSize: 32,
                    color: AppColors.reflection,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Take a breath.',
                  style: AppTypography.displayMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "You're doing well.",
                  style: AppTypography.displayMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.reflection,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Container(
                  height: 1,
                  width: 48,
                  color: AppColors.reflection.withOpacity(0.3),
                ),
                const SizedBox(height: 24),
                Text(
                  'Swipe to continue your journey.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
