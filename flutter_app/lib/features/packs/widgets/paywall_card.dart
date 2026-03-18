import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../premium/premium_controller.dart';

// ---------------------------------------------------------------------------
// PaywallCard — shown inline after the last preview quote.
//
// Always shows both options:
//   1. Buy the individual pack at $2.99 (primary CTA)
//   2. Go to Inside at $4.99 (secondary CTA)
//
// Inside value prop copy adapts based on how many packs the user already owns,
// computed from the owned_packs list in /premium/status (US-B08).
// ---------------------------------------------------------------------------

class PaywallCard extends ConsumerWidget {
  /// The pack being previewed.
  final String packId;
  final String packName;

  /// Total quote count for this pack (used in primary CTA copy).
  final int quoteCount;

  /// Pack accent color (hex string like "#14B8A6").
  final String packColor;

  /// Called when the primary "buy pack" CTA is tapped.
  final VoidCallback onBuyPack;

  /// Price from the backend (paywall.pack_price_usd). Defaults to 2.99 if absent.
  final double packPriceUsd;

  const PaywallCard({
    super.key,
    required this.packId,
    required this.packName,
    required this.quoteCount,
    required this.packColor,
    required this.onBuyPack,
    this.packPriceUsd = 2.99,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = context.tr;
    final color = _parseColor(packColor);

    // Compute owned-pack-aware Inside value prop (US-B08)
    final premiumState = ref.watch(premiumStateProvider);
    final ownedPacks = premiumState.premiumState.ownedPacks;
    final ownedCount = ownedPacks.length;

    // Don't count the current pack if owned (edge case: user tapping preview
    // after owning it — shouldn't happen but defensive)
    final ownedOthers = ownedPacks.where((p) => p != packId).length;

    final String insideCopy;
    if (ownedOthers == 1) {
      insideCopy = tr.insideValuePropOwn1;
    } else if (ownedOthers >= 2) {
      insideCopy = tr.insideValuePropOwn2;
    } else {
      insideCopy = tr.insideValueProp;
    }

    // Determine primary CTA copy.
    // HIGH-05: use packPriceUsd from the backend; format to 2 decimal places.
    final priceFormatted = '\$${packPriceUsd.toStringAsFixed(2)}';

    // For Trial users: "N more quotes — $X.XX" (quotesCount - 15 = remaining)
    // For Free users: "unlock N quotes — $X.XX"
    final isTrial = premiumState.isTrial;
    final remainingCount = isTrial ? (quoteCount - 15) : quoteCount;

    // Build price-aware CTA strings by replacing the hardcoded price with
    // the backend value. We keep the i18n keys for the text structure and
    // substitute the price portion. The rendered i18n strings contain "$2.99"
    // as a literal dollar-sign + digits, so we match that pattern.
    final basePrimaryCopy = isTrial
        ? tr.packTrialPaywallPrimary(remainingCount)
        : tr.packUnlockCta(quoteCount);
    // Replace the first occurrence of a price like "$2.99" in the rendered string.
    final primaryCopy =
        basePrimaryCopy.replaceFirst(RegExp(r'\$\d+\.\d+'), priceFormatted);

    // secondaryCopy for the button: always the Inside CTA regardless of tier.
    final secondaryCopy = isTrial
        ? tr.packTrialPaywallSecondary
        : tr.packInsideCta;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.12),
            const Color(0xFF13131B),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: color.withOpacity(0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lock icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.lock_outline_rounded, color: color, size: 30),
            ),
            const SizedBox(height: 20),

            // Pack name
            Text(
              packName,
              style: AppTypography.displaySmall.copyWith(
                color: color,
                fontSize: 20,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Subline — for Trial users, show the Inside value prop (not the
            // button copy). This avoids HIGH-03 where both subline and button
            // showed the same packTrialPaywallSecondary string.
            Text(
              insideCopy,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Primary CTA — buy this pack
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onBuyPack,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: const Color(0xFF0D0D1A),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  primaryCopy,
                  style: AppTypography.buttonLabel.copyWith(fontSize: 15),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Divider with "or"
            Row(
              children: [
                Expanded(
                    child: Divider(color: AppColors.border, thickness: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    'or',
                    style: AppTypography.caption
                        .copyWith(color: AppColors.textMuted),
                  ),
                ),
                Expanded(
                    child: Divider(color: AppColors.border, thickness: 1)),
              ],
            ),
            const SizedBox(height: 12),

            // Secondary CTA — go to Inside (with "Best value" badge)
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.push('/premium'),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: AppColors.stoicism.withOpacity(0.06),
                      side: BorderSide(
                          color: AppColors.stoicism.withOpacity(0.6), width: 1.5),
                      foregroundColor: AppColors.stoicism,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          secondaryCopy,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.stoicism,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (!isTrial) ...[
                          const SizedBox(height: 2),
                          Text(
                            insideCopy,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.stoicism.withOpacity(0.65),
                              fontSize: 10,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                // "Best value" badge pinned to top-right corner
                Positioned(
                  top: -10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.stoicism,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isTrial ? '3 PACKS' : 'BEST VALUE',
                      style: AppTypography.caption.copyWith(
                        color: const Color(0xFF0D0D1A),
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
