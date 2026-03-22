import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../data/models/quote_model.dart';
import '../../shared/extensions/context_extensions.dart';
import '../settings/settings_controller.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final _similarQuotesProvider = FutureProvider.family<List<QuoteModel>, String>(
  (ref, quoteId) async {
    final api = ref.read(apiClientProvider);
    final lang = ref.read(settingsStateProvider).lang;
    final response = await api.get(
      '/quotes/$quoteId/similar',
      queryParams: {'lang': lang, 'limit': '8'},
    );
    final rawList = response['data'] as List? ?? [];
    return rawList
        .whereType<Map<String, dynamic>>()
        .map(QuoteModel.fromJson)
        .toList();
  },
);

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

class SimilarQuotesScreen extends ConsumerWidget {
  const SimilarQuotesScreen({super.key, required this.quoteId});

  final String quoteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_similarQuotesProvider(quoteId));
    final tr = context.tr;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          tr.similarQuotesTitle,
          style: AppTypography.displaySmall.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: state.when(
        loading: () => _buildShimmer(),
        error: (e, _) => _buildError(context, e.toString(), ref),
        data: (quotes) {
          if (quotes.isEmpty) {
            return Center(
              child: Text(
                tr.similarQuotesEmpty,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: quotes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) =>
                _SimilarQuoteCard(quote: quotes[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, _) => Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceVariant,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => ref.invalidate(_similarQuotesProvider(quoteId)),
              child: Text(context.tr.tryAgain,
                  style: const TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual similar-quote card (simplified — text + author only)
// ---------------------------------------------------------------------------

class _SimilarQuoteCard extends StatelessWidget {
  const _SimilarQuoteCard({required this.quote});

  final QuoteModel quote;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left accent bar
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 3,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      accentColor.withValues(alpha: 0.9),
                      accentColor.withValues(alpha: 0.2),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  '\u201C${quote.text}\u201D',
                  style: AppTypography.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '\u2014 ${quote.author}',
              style: AppTypography.labelSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
