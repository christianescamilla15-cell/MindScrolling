import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

class PremiumComparisonTable extends StatelessWidget {
  const PremiumComparisonTable({super.key});

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
