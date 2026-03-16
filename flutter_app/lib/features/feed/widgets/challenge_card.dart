import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// Special feed card showing today's philosophical challenge.
class ChallengeCard extends StatelessWidget {
  const ChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.progressRatio,
    required this.onTrack,
  });

  /// Challenge title text.
  final String title;

  /// Challenge description / instructions.
  final String description;

  /// Progress [0, 1].
  final double progressRatio;

  /// Callback when the user taps "Track this".
  final VoidCallback onTrack;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C1A10),
            Color(0xFF161408),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.philosophy.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.philosophy.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'DAILY CHALLENGE',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.philosophy,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title
            Text(
              title,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            // Description
            Text(
              description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // Progress bar
            _ProgressBar(ratio: progressRatio),
            const SizedBox(height: 8),
            Text(
              '${(progressRatio * 100).round()}% complete',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 24),
            // Track button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.philosophy,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: onTrack,
                child: Text(
                  'Track this',
                  style: AppTypography.buttonLabel.copyWith(
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.ratio});
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Stack(
          children: [
            Container(
              height: 4,
              width: width,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 4,
              width: width * ratio.clamp(0.0, 1.0),
              decoration: BoxDecoration(
                color: AppColors.philosophy,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );
      },
    );
  }
}
