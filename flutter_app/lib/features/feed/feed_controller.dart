import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/haptics_service.dart';
import '../../core/providers/core_providers.dart';
import '../../core/storage/cache_storage.dart';
import '../../data/datasources/local/feed_local_ds.dart';
import '../../data/datasources/remote/feed_remote_ds.dart';
import '../../data/datasources/remote/profile_remote_ds.dart';
import '../../data/datasources/remote/vault_remote_ds.dart';
import '../../data/models/feed_item_model.dart';
import '../../data/models/quote_model.dart';
import '../../data/models/swipe_event_model.dart';
import '../../data/repositories/feed_repository.dart';
import 'feed_prefetch_service.dart';
import 'feed_queue_manager.dart';
import 'feed_state.dart';

/// StateNotifier that drives the main feed screen.
class FeedController extends StateNotifier<FeedState> {
  FeedController({
    required FeedRepository repository,
  })  : _repository = repository,
        _queueManager = FeedQueueManager(),
        _prefetchService = FeedPrefetchService(repository: repository),
        super(FeedState.initial());

  final FeedRepository _repository;
  final FeedQueueManager _queueManager;
  final FeedPrefetchService _prefetchService;

  String _lang = AppConstants.defaultLang;
  String? _cursor;
  DateTime? _swipeStartTime;

  static const _kSwipeCountKey = 'mindscroll_swipe_count';
  static const _kSwipeDateKey = 'mindscroll_swipe_date';

  /// Load daily swipe count — tries backend first (survives reinstall),
  /// falls back to local SharedPreferences.
  Future<void> loadPersistedSwipeCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    // Try backend first (source of truth — survives reinstall)
    try {
      final stats = await _repository.getStats();
      stats.when(
        success: (data) {
          final todaySwipes = (data['today_swipes'] as num?)?.toInt() ?? 0;
          // Backend knows exact count for today — use it
          state = state.copyWith(reflections: todaySwipes);
          prefs.setString(_kSwipeDateKey, today);
          prefs.setInt(_kSwipeCountKey, todaySwipes);
        },
        failure: (_, __) {
          _loadLocalSwipeCount(prefs, today);
        },
      );
    } catch (_) {
      _loadLocalSwipeCount(prefs, today);
    }
  }

  void _loadLocalSwipeCount(SharedPreferences prefs, String today) {
    final savedDate = prefs.getString(_kSwipeDateKey);
    if (savedDate == today) {
      final count = prefs.getInt(_kSwipeCountKey) ?? 0;
      state = state.copyWith(reflections: count);
    } else {
      prefs.setString(_kSwipeDateKey, today);
      prefs.setInt(_kSwipeCountKey, 0);
    }
  }

  /// Save swipe count after each swipe.
  Future<void> _persistSwipeCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await prefs.setString(_kSwipeDateKey, today);
    await prefs.setInt(_kSwipeCountKey, count);
  }

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  Future<void> loadInitialFeed(String lang) async {
    _lang = lang;
    _cursor = null;
    // Preserve swipe count when reloading feed (language change, app resume)
    final currentReflections = state.reflections;
    state = FeedState.initial().copyWith(reflections: currentReflections);

    final result = await _repository.getFeed(lang: _lang, cursor: null);
    result.when(
      success: (items) {
        _queueManager.enqueue(items);
        final loaded = _drainQueue();
        // Update cursor to last quote ID for pagination
        if (loaded.isNotEmpty) {
          final lastQuote = loaded.reversed.firstWhere(
            (i) => i.isQuote && i.quote != null,
            orElse: () => loaded.last,
          );
          _cursor = lastQuote.quote?.id;
        }
        state = state.copyWith(
          items: loaded,
          currentIndex: 0,
          isLoading: false,
          hasError: false,
          errorMessage: null,
        );
        _swipeStartTime = DateTime.now();
      },
      failure: (msg, _) {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: msg,
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Prefetch / load more
  // -------------------------------------------------------------------------

  Future<void> loadMore() async {
    if (!_queueManager.shouldPrefetch) return;
    await _prefetchService.prefetch(
      lang: _lang,
      cursor: _cursor,
      onPrefetchComplete: (newItems) {
        _queueManager.enqueue(newItems);
        final drained = _drainQueue();
        // Update cursor for next page
        if (drained.isNotEmpty) {
          final lastQuote = drained.reversed.firstWhere(
            (i) => i.isQuote && i.quote != null,
            orElse: () => drained.last,
          );
          _cursor = lastQuote.quote?.id;
        }
        final extended = List<FeedItemModel>.from(state.items)
          ..addAll(drained);
        state = state.copyWith(items: extended);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Swipe
  // -------------------------------------------------------------------------

  void onSwipe(String direction) {
    HapticsService.lightImpact();
    final current = state.currentItem;
    if (current == null) return;

    // Record dwell time.
    final dwellMs = _swipeStartTime != null
        ? DateTime.now().difference(_swipeStartTime!).inMilliseconds
        : 0;

    // Analytics — fire-and-forget.
    if (current.isQuote && current.quote != null) {
      final event = SwipeEventModel(
        quoteId: current.quote!.id,
        direction: direction,
        category: current.quote!.category,
        dwellTimeMs: dwellMs,
      );
      _repository.recordSwipe(event).ignore();
    }

    // Update swipeCounts.
    final category = current.quote?.category ?? direction;
    final updated = Map<String, int>.from(state.swipeCounts);
    updated[category] = (updated[category] ?? 0) + 1;

    final newReflections = state.reflections + 1;
    _persistSwipeCount(newReflections).ignore();
    final triggerStreak =
        newReflections % AppConstants.streakThreshold == 0;
    final newStreak = triggerStreak ? state.streak + 1 : state.streak;

    final newIndex = state.currentIndex + 1;

    // ── Reorder upcoming items to match swipe direction ──────────────────
    // The user swiped in [direction]. The NEXT card should be of the
    // category that corresponds to that direction.
    // We match by swipeDir field (up/down/left/right) directly.
    var items = List<FeedItemModel>.from(state.items);

    if (newIndex < items.length) {
      // Skip non-quote items (reflection/challenge cards) — don't displace them
      final nextItem = items[newIndex];
      if (nextItem.isQuote) {
        final alreadyMatches = nextItem.quote?.swipeDir == direction;

        if (!alreadyMatches) {
          // Find the closest matching QUOTE (skip non-quote items)
          for (int i = newIndex + 1; i < items.length; i++) {
            if (items[i].isQuote &&
                items[i].quote?.swipeDir == direction) {
              final temp = items[newIndex];
              items[newIndex] = items[i];
              items[i] = temp;
              break;
          }
        }
        }
      }
    }

    state = state.copyWith(
      currentIndex: newIndex,
      items: items,
      swipeCounts: updated,
      reflections: newReflections,
      streak: newStreak,
      streakPulse: triggerStreak,
      toastMessage: triggerStreak ? 'streakExtended' : null,
      toastColor: triggerStreak ? '#F59E0B' : null,
    );

    _swipeStartTime = DateTime.now();

    // Trigger prefetch when approaching end of buffer.
    if (newIndex >= state.items.length - AppConstants.feedPageSize ~/ 4) {
      loadMore().ignore();
    }
  }

  // -------------------------------------------------------------------------
  // Streak pulse reset
  // -------------------------------------------------------------------------

  void clearStreakPulse() {
    if (state.streakPulse) {
      state = state.copyWith(streakPulse: false);
    }
  }

  void clearToast() {
    state = state.copyWith(toastMessage: null, toastColor: null);
  }

  // -------------------------------------------------------------------------
  // Like
  // -------------------------------------------------------------------------

  void onLike(String quoteId) {
    HapticsService.lightImpact();
    final wasLiked = state.likedIds.contains(quoteId);
    final updated = Set<String>.from(state.likedIds);
    if (wasLiked) {
      updated.remove(quoteId);
    } else {
      updated.add(quoteId);
    }
    state = state.copyWith(
      likedIds: updated,
      toastMessage: wasLiked ? 'removedLike' : 'liked',
      toastColor: wasLiked ? null : '#F97316',
    );
    _repository.likeQuote(quoteId, !wasLiked).ignore();
  }

  // -------------------------------------------------------------------------
  // Vault
  // -------------------------------------------------------------------------

  void onVaultSave(QuoteModel quote, {bool isPremium = false}) {
    if (!isPremium && state.vault.length >= 20) {
      HapticsService.warningFeedback();
      state = state.copyWith(
        toastMessage: 'vaultLimitReached',
        toastColor: null,
      );
      return;
    }
    final alreadySaved = state.vault.any((q) => q.id == quote.id);
    if (alreadySaved) {
      state = state.copyWith(
        toastMessage: 'alreadyVault',
        toastColor: null,
      );
      return;
    }
    HapticsService.mediumImpact();
    final updated = List<QuoteModel>.from(state.vault)..add(quote);
    state = state.copyWith(
      vault: updated,
      toastMessage: 'savedVault',
      toastColor: '#14B8A6',
    );
    _repository.saveToVault(quote.id).ignore();
  }

  void onVaultRemove(String quoteId) {
    final updated = state.vault.where((q) => q.id != quoteId).toList();
    state = state.copyWith(vault: updated);
    _repository.removeFromVault(quoteId).ignore();
  }

  void toggleVault() {
    state = state.copyWith(showVault: !state.showVault);
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  List<FeedItemModel> _drainQueue() {
    final items = <FeedItemModel>[];
    FeedItemModel? item;
    while ((item = _queueManager.dequeue()) != null) {
      items.add(item!);
    }
    return items;
  }

  @override
  void dispose() {
    _prefetchService.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [FeedController].
final feedControllerProvider =
    StateNotifierProvider<FeedController, FeedState>((ref) {
  final api = ref.watch(apiClientProvider);
  return FeedController(
    repository: FeedRepository(
      remote: FeedRemoteDataSource(api),
      local: FeedLocalDataSource(CacheStorage()),
      profile: ProfileRemoteDataSource(api),
      vault: VaultRemoteDataSource(api),
    ),
  );
});
