import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../features/premium/premium_controller.dart';
import '../extensions/context_extensions.dart';

/// Wraps [child] and replaces it with a premium upsell gate when the user
/// is not yet premium.
class PremiumGate extends ConsumerWidget {
  const PremiumGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ps = ref.watch(premiumStateProvider);
    if (ps.isPremium) return child;
    return _PremiumGateView();
  }
}

class _PremiumGateView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.stoicism.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.stoicism,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'MindScrolling Inside',
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.stoicism,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              context.tr.premiumRequired,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
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
                  context.tr.premiumUnlock,
                  style: AppTypography.buttonLabel,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
