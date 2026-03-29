import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.stoicism.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stoicism.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.verified_rounded,
              color: AppColors.stoicism, size: 24),
          const SizedBox(width: 10),
          Text(
            context.tr.alreadyPremium,
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.stoicism,
            ),
          ),
        ],
      ),
    );
  }
}

class TrialBanner extends StatelessWidget {
  final int daysLeft;
  const TrialBanner({super.key, required this.daysLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B6B3A).withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B6B3A).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer_outlined,
                  color: Color(0xFF4ADE80), size: 22),
              const SizedBox(width: 10),
              Text(
                context.tr.trialActive,
                style: AppTypography.displaySmall.copyWith(
                  color: const Color(0xFF4ADE80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            context.tr.trialDaysLeft(daysLeft),
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF4ADE80).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
