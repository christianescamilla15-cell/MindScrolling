import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../core/constants/monetization_constants.dart';
import '../../../shared/extensions/context_extensions.dart';

class PremiumPriceLabel extends StatelessWidget {
  const PremiumPriceLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          MonetizationConstants.priceDisplay['USD'] ?? r'$4.99',
          style: AppTypography.displayLarge.copyWith(
            color: AppColors.stoicism,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          context.tr.oneTime,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class PremiumUnlockButton extends StatelessWidget {
  final bool isPurchasing;
  final VoidCallback? onTap;

  const PremiumUnlockButton({
    super.key,
    required this.isPurchasing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isPurchasing ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.stoicism,
          foregroundColor: const Color(0xFF0D0D1A),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: AppColors.stoicism.withOpacity(0.4),
          disabledForegroundColor: AppColors.textMuted,
        ),
        child: isPurchasing
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF0D0D1A),
                ),
              )
            : Text(context.tr.premiumUnlock, style: AppTypography.buttonLabel),
      ),
    );
  }
}

class PremiumStatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const PremiumStatusMessage({
    super.key,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? const Color(0xFFFF6B6B) : AppColors.stoicism;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: color,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodySmall.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
