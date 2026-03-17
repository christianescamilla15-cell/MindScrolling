import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/monetization_constants.dart';
import '../../shared/extensions/context_extensions.dart';
import 'premium_controller.dart';

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
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
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

          // ── Badge / Trial / Hero ────────────────────────────────────────
          if (ps.premiumState.isPremium) ...[
            _PremiumBadge(),
            const SizedBox(height: 28),
          ] else if (ps.isTrial) ...[
            _TrialBanner(daysLeft: ps.trialDaysLeft),
            const SizedBox(height: 28),
          ] else ...[
            _HeroSection(),
            const SizedBox(height: 32),
          ],

          // ── Comparison table ────────────────────────────────────────────
          _ComparisonTable(),

          const SizedBox(height: 32),

          // ── Success message ─────────────────────────────────────────────
          if (ps.successMessage != null)
            _StatusMessage(
              message: ps.successMessage!,
              isError: false,
            ),

          // ── Error message ───────────────────────────────────────────────
          if (ps.error != null)
            _StatusMessage(
              message: ps.error!,
              isError: true,
            ),

          // ── Action button (show for trial users + free users) ────────────
          if (!ps.premiumState.isPremium) ...[
            const SizedBox(height: 8),
            _PriceLabel(),
            const SizedBox(height: 12),
            _UnlockButton(
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
            // ── Have activation code? ──────────────────────────────────────
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
// Hero section (free users only)
// ---------------------------------------------------------------------------

class _HeroSection extends StatelessWidget {
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

// ---------------------------------------------------------------------------
// Already-premium badge
// ---------------------------------------------------------------------------

class _PremiumBadge extends StatelessWidget {
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

// ---------------------------------------------------------------------------
// Trial banner
// ---------------------------------------------------------------------------

class _TrialBanner extends StatelessWidget {
  final int daysLeft;
  const _TrialBanner({required this.daysLeft});

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

// ---------------------------------------------------------------------------
// Free vs Premium comparison table
// ---------------------------------------------------------------------------

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    final rows = [
      _ComparisonRow(
        feature: tr.dailyFeed,
        free: tr.limitedQuotes,
        premium: tr.unlimited,
      ),
      _ComparisonRow(
        feature: tr.ads,
        free: tr.occasional,
        premium: tr.none,
      ),
      _ComparisonRow(
        feature: tr.vaultSize,
        free: tr.savedQuotes20,
        premium: tr.unlimited,
      ),
      _ComparisonRow(
        feature: tr.dailyChallenges,
        free: tr.viewOnly,
        premium: tr.fullAccess,
      ),
      _ComparisonRow(
        feature: tr.philosophyMap,
        free: tr.basic,
        premium: tr.fullPlusHistory,
      ),
      _ComparisonRow(
        feature: tr.aiWeeklyInsight,
        free: tr.notIncluded,
        premium: tr.included,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: [
          // Header row
          Container(
            color: AppColors.stoicism.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    tr.featureColumn,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    tr.freeColumn,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    tr.premiumColumn,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.stoicism,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          ...List.generate(
            rows.length,
            (index) => Column(
              children: [
                _TableRow(row: rows[index]),
                if (index < rows.length - 1)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonRow {
  final String feature;
  final String free;
  final String premium;

  const _ComparisonRow({
    required this.feature,
    required this.free,
    required this.premium,
  });
}

class _TableRow extends StatelessWidget {
  final _ComparisonRow row;

  const _TableRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(row.feature, style: AppTypography.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(
              row.free,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.stoicism, size: 14),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    row.premium,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.stoicism,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Price label
// ---------------------------------------------------------------------------

class _PriceLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          MonetizationConstants.priceDisplay['USD'] ?? r'$2.99',
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

// ---------------------------------------------------------------------------
// Unlock button
// ---------------------------------------------------------------------------

class _UnlockButton extends StatelessWidget {
  final bool isPurchasing;
  final VoidCallback? onTap;

  const _UnlockButton({required this.isPurchasing, required this.onTap});

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

// ---------------------------------------------------------------------------
// Status message (success / error)
// ---------------------------------------------------------------------------

class _StatusMessage extends StatelessWidget {
  final String message;
  final bool isError;

  const _StatusMessage({required this.message, required this.isError});

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
