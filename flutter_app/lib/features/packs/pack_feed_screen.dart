import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/feed_constants.dart';
import '../../core/analytics/event_logger.dart';
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
// PackFeedScreen
//
// Full paginated feed of a pack's quotes for entitled users.
// Calls GET /packs/:id/feed?lang=<lang>&limit=20&cursor=<cursor>
// Sends swipes to POST /swipes with source:"pack", source_pack_id:<id>
//
// If the API returns 403 PACK_NOT_ENTITLED, shows PaywallCard inline.
// ---------------------------------------------------------------------------

class PackFeedScreen extends ConsumerStatefulWidget {
  final String packId;
  final String packName;
  final String packColor;

  const PackFeedScreen({
    super.key,
    required this.packId,
    required this.packName,
    required this.packColor,
  });

  @override
  ConsumerState<PackFeedScreen> createState() => _PackFeedScreenState();
}

class _PackFeedScreenState extends ConsumerState<PackFeedScreen> {
  final CardSwiperController _swiperController = CardSwiperController();

  List<QuoteModel> _quotes = [];
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  bool _notEntitled = false;
  bool _hasMore = true;
  String? _nextCursor;
  int _quoteCount = 0;
  bool _buying = false;
  final Set<String> _likedIds = {};

  // MED-05: track when the current card became visible so we can compute dwell_time_ms.
  DateTime _cardShownAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadPage(cursor: null);
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  Future<void> _loadPage({required String? cursor}) async {
    if (cursor != null && _loadingMore) return;

    if (cursor == null) {
      setState(() {
        _loading = true;
        _error = null;
        _notEntitled = false;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    try {
      final api = ref.read(apiClientProvider);
      final lang = ref.read(settingsStateProvider).lang;

      final response = await api.get(
        '/packs/${widget.packId}/feed',
        queryParams: {
          'lang': lang,
          'limit': '20',
          if (cursor != null) 'cursor': cursor,
        },
      );

      final rawQuotes = (response['data'] as List?)
              ?.map((q) => QuoteModel.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [];

      final hasMore = response['has_more'] == true;
      final nextCursor = response['next_cursor'] as String?;
      final pack = response['pack'] as Map<String, dynamic>?;
      final qCount = (pack?['quote_count'] as num?)?.toInt() ?? _quoteCount;

      if (mounted) {
        setState(() {
          if (cursor == null) {
            _quotes = rawQuotes;
            _cardShownAt = DateTime.now(); // reset dwell timer after first page loads
          } else {
            _quotes = [..._quotes, ...rawQuotes];
          }
          _hasMore = hasMore;
          _nextCursor = nextCursor;
          _quoteCount = qCount > 0 ? qCount : rawQuotes.length;
          _loading = false;
          _loadingMore = false;
        });
      }
    } catch (e) {
      final msg = e.toString();
      if (mounted) {
        setState(() {
          _loading = false;
          _loadingMore = false;
          if (msg.contains('403') || msg.contains('PACK_NOT_ENTITLED')) {
            _notEntitled = true;
          } else {
            _error = msg;
          }
        });
      }
    }
  }

  Future<void> _recordSwipe(
      String quoteId, String direction, int dwellTimeMs) async {
    final category =
        FeedConstants.directionToCategory[direction] ?? 'stoicism';

    try {
      final api = ref.read(apiClientProvider);
      await api.post('/swipes', body: {
        'quote_id': quoteId,
        'direction': direction,
        'category': category,
        'source': 'pack',
        'source_pack_id': widget.packId,
        // MED-05: send dwell_time_ms for preference-signal quality.
        'dwell_time_ms': dwellTimeMs,
      });
    } catch (_) {
      // Swipe recording failures are silent — they don't interrupt UX.
    }
  }

  Future<void> _onDoubleTap(QuoteModel quote) async {
    final wasLiked = _likedIds.contains(quote.id);
    setState(() {
      if (wasLiked) {
        _likedIds.remove(quote.id);
      } else {
        _likedIds.add(quote.id);
      }
    });
    HapticsService.lightImpact();
    if (!wasLiked) EventLogger.logLike(quote.id);
    try {
      final api = ref.read(apiClientProvider);
      await api.post('/quotes/${quote.id}/like');
    } catch (_) {}
  }

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    // MED-05: compute dwell time before resetting the timer.
    final dwellTimeMs =
        DateTime.now().difference(_cardShownAt).inMilliseconds;
    // Reset for the next card.
    _cardShownAt = DateTime.now();

    final dirStr = switch (direction) {
      CardSwiperDirection.left => 'left',
      CardSwiperDirection.right => 'right',
      CardSwiperDirection.top => 'up',
      CardSwiperDirection.bottom => 'down',
      _ => 'left',
    };

    if (previousIndex < _quotes.length) {
      final quote = _quotes[previousIndex];
      _recordSwipe(quote.id, dirStr, dwellTimeMs);
    }

    // Load next page when approaching the end
    final remaining = _quotes.length - (previousIndex + 1);
    if (remaining <= 3 && _hasMore && !_loadingMore && _nextCursor != null) {
      _loadPage(cursor: _nextCursor);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(packPurchaseServiceProvider);

    final tr = context.tr;
    final packAccent = _parseColor(widget.packColor);

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
              color: packAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tr.packUnlocked,
              style: AppTypography.caption.copyWith(
                color: packAccent,
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

    if (_notEntitled) {
      return SingleChildScrollView(
        child: PaywallCard(
          packId: widget.packId,
          packName: widget.packName,
          quoteCount: _quoteCount > 0 ? _quoteCount : 500,
          packColor: widget.packColor,
          onBuyPack: _onBuyPack,
        ),
      );
    }

    if (_error != null) {
      return _ErrorState(
        message: _error!,
        onRetry: () => _loadPage(cursor: null),
      );
    }

    if (_quotes.isEmpty) {
      return Center(
        child: Text(tr.noQuotesAvailable,
            style: AppTypography.bodyMedium
                .copyWith(color: AppColors.textMuted)),
      );
    }

    // Add a loading card at the end when fetching more
    final displayCount = _loadingMore ? _quotes.length + 1 : _quotes.length;

    return CardSwiper(
      controller: _swiperController,
      cardsCount: displayCount,
      onSwipe: _onSwipe,
      allowedSwipeDirection: const AllowedSwipeDirection.all(),
      numberOfCardsDisplayed: 1,
      backCardOffset: const Offset(0, 0),
      scale: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cardBuilder: (context, index, _, __) {
        if (index >= displayCount) return const SizedBox.shrink();

        // Loading placeholder at the end
        if (_loadingMore && index == _quotes.length) {
          return const _LoadingCard();
        }

        if (index >= _quotes.length) return const SizedBox.shrink();

        final quote = _quotes[index];
        return _PackQuoteCard(
          quote: quote,
          packColor: widget.packColor,
          currentIndex: index,
          totalQuotes: _quoteCount,
          isLiked: _likedIds.contains(quote.id),
          onDoubleTap: () => _onDoubleTap(quote),
        );
      },
    );
  }

  Future<void> _onBuyPack() async {
    if (_buying) return;
    setState(() => _buying = true);

    final service = ref.read(packPurchaseServiceProvider);
    final result = await service.purchase(packId: widget.packId);

    if (!mounted) return;
    setState(() => _buying = false);

    switch (result.outcome) {
      case PurchaseOutcome.success:
      case PurchaseOutcome.restored:
        HapticsService.heavyImpact();
        await ref.read(premiumControllerProvider.notifier).checkStatus();
        if (!mounted) return;
        // Reload the feed — user is now entitled.
        _loadPage(cursor: null);
      case PurchaseOutcome.cancelled:
      case PurchaseOutcome.pending:
        break;
      case PurchaseOutcome.failed:
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

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}

// ---------------------------------------------------------------------------
// Pack quote card — full-featured card with swipe support.
// Shows pack accent color instead of category color on the left bar,
// but retains category accent for the glow.
// ---------------------------------------------------------------------------

class _PackQuoteCard extends StatelessWidget {
  final QuoteModel quote;
  final String packColor;
  final int currentIndex;
  final int totalQuotes;
  final bool isLiked;
  final VoidCallback onDoubleTap;

  const _PackQuoteCard({
    required this.quote,
    required this.packColor,
    required this.currentIndex,
    required this.totalQuotes,
    required this.isLiked,
    required this.onDoubleTap,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);
    final packAccent = _parseColor(packColor);

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      child: Container(
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
              // Pack-color left accent bar
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
              // Glow
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withOpacity(0.06),
                        Colors.transparent,
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
                    // Category + progress
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
                    GestureDetector(
                      onTap: () => context.push(
                          '/author/${Uri.encodeComponent(quote.author)}'),
                      child: Text(
                        quote.author,
                        style: AppTypography.labelSmall.copyWith(
                          color: accentColor,
                          letterSpacing: 1.2,
                          fontSize: 11,
                        ),
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

                    // Subtle divider
                    Container(
                      width: 40,
                      height: 1,
                      color: packAccent.withOpacity(0.2),
                    ),
                    const SizedBox(height: 16),

                    // Swipe hint row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_vert_rounded,
                            size: 14, color: AppColors.textMuted),
                        const SizedBox(width: 6),
                        Text(
                          context.tr.swipeToExplore,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isLiked
                              ? const Color(0xFFF97316)
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
// Loading card placeholder
// ---------------------------------------------------------------------------

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: CircularProgressIndicator(
            color: AppColors.stoicism, strokeWidth: 2),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
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
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(context.tr.retry,
                  style: const TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}
