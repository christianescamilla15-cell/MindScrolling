import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'premium_controller.dart';
import 'widgets/premium_action_widgets.dart';
import 'widgets/premium_badges.dart';
import 'widgets/premium_comparison_table.dart';
import 'widgets/premium_hero_section.dart';

/// Premium upgrade screen.
///
/// Shows a free vs. premium comparison table, the one-time price, and an
/// "Unlock Premium" button wired to [PremiumController.unlock].
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(premiumControllerProvider.notifier).checkStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(premiumStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(context.tr.premium, style: AppTypography.displaySmall),
      ),
      body: ps.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.stoicism,
                strokeWidth: 2,
              ),
            )
          : _PremiumBody(ps: ps),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _PremiumBody extends ConsumerWidget {
  final PremiumUiState ps;

  const _PremiumBody({required this.ps});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // Badge / Trial / Hero
          if (ps.premiumState.isPremium) ...[
            const PremiumBadge(),
            const SizedBox(height: 28),
          ] else if (ps.isTrial) ...[
            TrialBanner(daysLeft: ps.trialDaysLeft),
            const SizedBox(height: 28),
          ] else ...[
            const PremiumHeroSection(),
            const SizedBox(height: 32),
          ],

          // Comparison table
          const PremiumComparisonTable(),

          const SizedBox(height: 32),

          // Success message
          if (ps.successMessage != null)
            PremiumStatusMessage(
              message: _resolveMessage(context, ps.successMessage!),
              isError: false,
            ),

          // Error message
          if (ps.error != null)
            PremiumStatusMessage(
              message: _resolveMessage(context, ps.error!),
              isError: true,
            ),

          // Action button (show for trial users + free users)
          if (!ps.premiumState.isPremium) ...[
            const SizedBox(height: 8),
            const PremiumPriceLabel(),
            const SizedBox(height: 12),
            PremiumUnlockButton(
              isPurchasing: ps.isPurchasing,
              onTap: () =>
                  ref.read(premiumControllerProvider.notifier).purchasePremium(),
            ),
            const SizedBox(height: 10),
            Text(
              context.tr.oneTimePurchase,
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Restore purchases button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: ps.isRestoring
                    ? null
                    : () => ref
                        .read(premiumControllerProvider.notifier)
                        .restorePurchases(),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
                child: ps.isRestoring
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : Text(
                        context.tr.restorePurchases,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            // Have activation code?
            TextButton(
              onPressed: () => context.push('/redeem'),
              child: Text(
                context.tr.haveActivationCode,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.stoicism.withOpacity(0.7),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Key -> localized string resolver
// ---------------------------------------------------------------------------

String _resolveMessage(BuildContext context, String key) {
  final tr = context.tr;
  switch (key) {
    case 'purchaseSuccess':  return tr.purchaseSuccess;
    case 'purchaseFailed':   return tr.purchaseFailed;
    case 'restoreSuccess':   return tr.restoreSuccess;
    case 'restoreFailed':    return tr.restoreFailed;
    case 'noPurchasesFound': return tr.noPurchasesFound;
    default:                 return key;
  }
}
