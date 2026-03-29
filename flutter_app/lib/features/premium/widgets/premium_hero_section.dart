import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

class PremiumHeroSection extends StatelessWidget {
  const PremiumHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.stoicism.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.stoicism,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          context.tr.unlockFullExperience,
          style: AppTypography.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          context.tr.premiumSubtitle,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
