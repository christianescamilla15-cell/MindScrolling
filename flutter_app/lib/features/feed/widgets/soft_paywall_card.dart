import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

// ---------------------------------------------------------------------------
// SoftPaywallCard
//
// Injected into the Trial feed at ~swipe 100 (US-B07).
// Non-blocking: the user can swipe it away in any direction.
// It does NOT count as a quote swipe.
// ---------------------------------------------------------------------------

class SoftPaywallCard extends StatelessWidget {
  const SoftPaywallCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.stoicism.withOpacity(0.10),
            const Color(0xFF13131B),
          ],
        ),
        border: Border.all(
          color: AppColors.stoicism.withOpacity(0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.stoicism.withOpacity(0.12),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.stoicism.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.stoicism,
                size: 30,
              ),
            ),
            const SizedBox(height: 24),

            // Message
            Text(
              tr.trialSoftPaywall,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 20,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Value prop
            Text(
              tr.insideValueProp,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // CTA — navigate to premium screen
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () => context.push('/premium'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.stoicism,
                  foregroundColor: const Color(0xFF0D0D1A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  tr.premiumUnlock,
                  style: AppTypography.buttonLabel.copyWith(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Dismiss hint — MED-06: use localized string instead of hardcoded English.
            Text(
              tr.swipeToContinue,
              style: AppTypography.caption
                  .copyWith(color: AppColors.textMuted, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
