import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
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

  // -------------------------------------------------------------------------
  // Initialisation
  // -------------------------------------------------------------------------

  Future<void> loadInitialFeed(String lang) async {
    _lang = lang;
    _cursor = null;
    state = FeedState.initial();

    final result = await _repository.getFeed(lang: _lang, cursor: null);
    result.when(
      success: (items) {
        _queueManager.enqueue(items);
        final loaded = _drainQueue();
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
        final extended = List<FeedItemModel>.from(state.items)
          ..addAll(_drainQueue());
        state = state.copyWith(items: extended);
      },
    );
  }

  // -------------------------------------------------------------------------
  // Swipe
  // -------------------------------------------------------------------------

  void onSwipe(String direction) {
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
    final triggerStreak =
        newReflections % AppConstants.streakThreshold == 0;
    final newStreak = triggerStreak ? state.streak + 1 : state.streak;

    final newIndex = state.currentIndex + 1;

    state = state.copyWith(
      currentIndex: newIndex,
      swipeCounts: updated,
      reflections: newReflections,
      streak: newStreak,
      streakPulse: triggerStreak,
      toastMessage: triggerStreak ? 'Streak extended! 🔥' : null,
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
    final wasLiked = state.likedIds.contains(quoteId);
    final updated = Set<String>.from(state.likedIds);
    if (wasLiked) {
      updated.remove(quoteId);
    } else {
      updated.add(quoteId);
    }
    state = state.copyWith(
      likedIds: updated,
      toastMessage: wasLiked ? 'Removed like' : 'Liked ✦',
      toastColor: wasLiked ? null : '#F97316',
    );
    _repository.likeQuote(quoteId, !wasLiked).ignore();
  }

  // -------------------------------------------------------------------------
  // Vault
  // -------------------------------------------------------------------------

  void onVaultSave(QuoteModel quote) {
    final alreadySaved = state.vault.any((q) => q.id == quote.id);
    if (alreadySaved) {
      state = state.copyWith(
        toastMessage: 'Already in vault',
        toastColor: null,
      );
      return;
    }
    final updated = List<QuoteModel>.from(state.vault)..add(quote);
    state = state.copyWith(
      vault: updated,
      toastMessage: 'Saved to vault ✦',
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
