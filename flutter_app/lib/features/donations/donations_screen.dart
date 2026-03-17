import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/monetization_constants.dart';
import '../../shared/extensions/context_extensions.dart';

/// Simple donation screen with a "Buy Me a Coffee" button that opens the
/// donation URL via url_launcher.
class DonationsScreen extends ConsumerWidget {
  const DonationsScreen({super.key});

  Future<void> _openDonationUrl(BuildContext context) async {
    final uri = Uri.parse(MonetizationConstants.donationUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: try platform default
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                context.tr.couldNotOpenDonation,
                style: AppTypography.bodySmall,
              ),
              backgroundColor: const Color(0xFF1A1A2E),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        centerTitle: false,
        title: Text(context.tr.supportMindScroll, style: AppTypography.displaySmall),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 48),

              // ── Icon ─────────────────────────────────────────────────
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.stoicism.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.stoicism,
                  size: 40,
                ),
              ),

              const SizedBox(height: 28),

              // ── Heading ───────────────────────────────────────────────
              Text(
                context.tr.supportMindScroll,
                style: AppTypography.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // ── Description ───────────────────────────────────────────
              Text(
                context.tr.donationDescription,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.65,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                context.tr.everyContribution,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.stoicism.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // ── Donation button ───────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _openDonationUrl(context),
                  icon: const Icon(Icons.coffee_rounded, size: 22),
                  label: Text(
                    context.tr.buyMeCoffee,
                    style: AppTypography.buttonLabel,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.stoicism,
                    foregroundColor: const Color(0xFF0D0D1A),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
