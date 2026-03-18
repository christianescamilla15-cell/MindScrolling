import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import 'dart:io';

import '../../app/theme/colors.dart' show AppColors;
import '../../core/providers/core_providers.dart';
import '../../core/utils/haptics_service.dart';
import '../../data/models/quote_model.dart';
import '../../shared/extensions/context_extensions.dart';
import '../premium/premium_controller.dart';
import '../premium/premium_purchase_service.dart';
import '../settings/settings_controller.dart';
import 'pack_purchase_service.dart';
import 'widgets/paywall_card.dart';

// ---------------------------------------------------------------------------
// PackPreviewScreen
//
// Calls GET /packs/:id/preview?lang=<lang> and handles all API response cases:
//   1. redirect_to_feed: true  → navigate immediately to PackFeedScreen
//   2. quotes present, is_preview_complete: false → show swipeable cards
//   3. quotes present, is_preview_complete: true  → show cards + PaywallCard at end
//   4. 503 PREVIEW_UNAVAILABLE → show empty state
// ---------------------------------------------------------------------------

class PackPreviewScreen extends ConsumerStatefulWidget {
  final String packId;
  final String packName;
  final String packColor;

  const PackPreviewScreen({
    super.key,
    required this.packId,
    required this.packName,
    required this.packColor,
  });

  @override
  ConsumerState<PackPreviewScreen> createState() => _PackPreviewScreenState();
}

class _PackPreviewScreenState extends ConsumerState<PackPreviewScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  bool _loading = true;
  bool _buying = false;
  String? _error;
  bool _previewUnavailable = false;

  List<QuoteModel> _quotes = [];
  bool _isPreviewComplete = false;
  Map<String, dynamic>? _paywallData;
  int _quoteCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPreview();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadPreview() async {
    try {
      final api = ref.read(apiClientProvider);
      final lang = ref.read(settingsStateProvider).lang;
      final response =
          await api.get('/packs/${widget.packId}/preview?lang=$lang');

      // Case 1: entitled user → redirect to full feed
      if (response['redirect_to_feed'] == true) {
        if (mounted) {
          context.pushReplacement(
            '/packs/${Uri.encodeComponent(widget.packId)}/feed',
            extra: {
              'packName': widget.packName,
              'packColor': widget.packColor,
            },
          );
        }
        return;
      }

      // Parse quotes
      final rawQuotes = (response['quotes'] as List?)
              ?.map((q) => QuoteModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [];

      final isComplete = response['is_preview_complete'] == true;
      final paywall = response['paywall'] as Map<String, dynamic>?;
      final pack = response['pack'] as Map<String, dynamic>?;
      final qCount = (pack?['quote_count'] as num?)?.toInt() ?? 500;

      if (mounted) {
        setState(() {
          _quotes = rawQuotes;
          _isPreviewComplete = isComplete;
          _paywallData = paywall;
          _quoteCount = qCount;
          _loading = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) {
        setState(() {
          _loading = false;
          // 503 PREVIEW_UNAVAILABLE
          if (msg.contains('PREVIEW_UNAVAILABLE')) {
            _previewUnavailable = true;
          } else {
            _error = msg;
          }
        });
      }
    }
  }

  Future<void> _onBuyPack() async {
    if (_buying) return;
    setState(() => _buying = true);

    // Resolve product ID from paywall data (iOS vs Android) or derive from packId.
    final productId = Platform.isIOS
        ? (_paywallData?['product_id_ios'] as String?)
        : (_paywallData?['product_id_android'] as String?);

    final service = ref.read(packPurchaseServiceProvider);
    final result = await service.purchase(
      packId: widget.packId,
      productIdOverride: productId,
    );

    if (!mounted) return;
    setState(() => _buying = false);

    switch (result.outcome) {
      case PurchaseOutcome.success:
      case PurchaseOutcome.restored:
        HapticsService.heavyImpact();
        // Refresh owned_packs in premium state.
        await ref.read(premiumControllerProvider.notifier).checkStatus();
        if (!mounted) return;
        context.pushReplacement(
          '/packs/${Uri.encodeComponent(widget.packId)}/feed',
          extra: {'packName': widget.packName, 'packColor': widget.packColor},
        );
      case PurchaseOutcome.cancelled:
        break;
      case PurchaseOutcome.failed:
      case PurchaseOutcome.pending:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.errorMessage ?? context.tr.purchaseFailed,
              style: AppTypography.caption.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE05C5C).withOpacity(0.9),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep the purchase service alive for the duration of the purchase flow.
    ref.watch(packPurchaseServiceProvider);

    final tr = context.tr;
    final packColor = _parseColor(widget.packColor);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/packs'),
        ),
        title: Text(widget.packName, style: AppTypography.displaySmall),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: packColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tr.packPreview,
              style: AppTypography.caption.copyWith(
                color: packColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(tr),
    );
  }

  Widget _buildBody(dynamic tr) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(
            color: AppColors.stoicism, strokeWidth: 2),
      );
    }

    if (_previewUnavailable) {
      return _EmptyState(message: tr.packPreviewUnavailable);
    }

    if (_error != null) {
      return _EmptyState(
        message: _error!,
        isError: true,
        onRetry: () {
          setState(() {
            _loading = true;
            _error = null;
          });
          _loadPreview();
        },
      );
    }

    if (_quotes.isEmpty && _isPreviewComplete) {
      // Zero quotes but paywall needed (EC-04 edge case)
      final priceUsd =
          (_paywallData?['pack_price_usd'] as num?)?.toDouble() ?? 2.99;
      return SingleChildScrollView(
        child: PaywallCard(
          packId: widget.packId,
          packName: widget.packName,
          quoteCount: _quoteCount,
          packColor: widget.packColor,
          onBuyPack: _onBuyPack,
          packPriceUsd: priceUsd,
        ),
      );
    }

    if (_quotes.isEmpty) {
      return _EmptyState(message: tr.noQuotesAvailable);
    }

    // Build card list: quote cards + optional paywall card at end
    final totalCards =
        _isPreviewComplete ? _quotes.length + 1 : _quotes.length;

    return CardSwiper(
      controller: _swiperController,
      cardsCount: totalCards,
      allowedSwipeDirection: const AllowedSwipeDirection.only(up: true),
      numberOfCardsDisplayed: 1,
      backCardOffset: const Offset(0, 0),
      scale: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cardBuilder: (context, index, _, __) {
        if (index >= totalCards) return const SizedBox.shrink();

        // Last card is the paywall (when preview is complete)
        if (_isPreviewComplete && index == _quotes.length) {
          final priceUsd =
              (_paywallData?['pack_price_usd'] as num?)?.toDouble() ?? 2.99;
          return SingleChildScrollView(
            child: PaywallCard(
              packId: widget.packId,
              packName: widget.packName,
              quoteCount: _quoteCount,
              packColor: widget.packColor,
              onBuyPack: _onBuyPack,
              packPriceUsd: priceUsd,
            ),
          );
        }

        final quote = _quotes[index];
        return _PreviewQuoteCard(
          quote: quote,
          packColor: widget.packColor,
          currentIndex: index,
          totalQuotes: _quotes.length,
        );
      },
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ---------------------------------------------------------------------------
// Preview quote card — uses the same visual language as QuoteCard but
// without like/save/share actions (preview is read-only).
// ---------------------------------------------------------------------------

class _PreviewQuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final String packColor;
  final int currentIndex;
  final int totalQuotes;

  const _PreviewQuoteCard({
    required this.quote,
    required this.packColor,
    required this.currentIndex,
    required this.totalQuotes,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);
    final packAccent = _parseColor(packColor);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C28), Color(0xFF13131B)],
        ),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.10),
            blurRadius: 40,
            spreadRadius: -8,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // Left accent bar
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      packAccent.withOpacity(0.8),
                      packAccent.withOpacity(0.2),
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Progress indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        quote.category.toUpperCase(),
                        style: AppTypography.caption.copyWith(
                          color: accentColor,
                          letterSpacing: 1.5,
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        '${currentIndex + 1} / $totalQuotes',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(flex: 1),

                  // Author
                  Text(
                    quote.author,
                    style: AppTypography.labelSmall.copyWith(
                      color: accentColor,
                      letterSpacing: 1.2,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quote text
                  Text(
                    '\u201C${quote.text}\u201D',
                    style: AppTypography.quoteText.copyWith(
                      fontSize: _adaptiveFontSize(quote.text.length),
                      height: 1.55,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 1),

                  // Swipe hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.keyboard_arrow_up_rounded,
                          color: AppColors.textMuted, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        'Swipe up',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _adaptiveFontSize(int charCount) {
    if (charCount < 60) return 28;
    if (charCount < 120) return 24;
    if (charCount < 200) return 21;
    if (charCount < 300) return 18;
    return 16;
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ---------------------------------------------------------------------------
// Empty / error state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const _EmptyState({
    required this.message,
    this.isError = false,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isError ? Icons.cloud_off_outlined : Icons.lock_outline_rounded,
              color: AppColors.textMuted,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              TextButton(
                onPressed: onRetry,
                child: Text(context.tr.retry,
                    style: const TextStyle(color: AppColors.stoicism)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
