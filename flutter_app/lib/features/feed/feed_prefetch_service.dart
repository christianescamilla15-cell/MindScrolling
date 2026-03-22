import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

/// Handles background prefetching of feed pages.
///
/// Tracks a single in-flight request to avoid double-fetching.
/// Uses a generation counter to invalidate stale callbacks after cancel().
class FeedPrefetchService {
  FeedPrefetchService({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  bool _inFlight = false;
  bool get isInFlight => _inFlight;

  /// Generation counter — incremented on every cancel().
  /// Callbacks from a previous generation are silently discarded.
  int _generation = 0;

  /// Fetches the next page of feed items.
  ///
  /// [cursor] is the pagination cursor from the previous response.
  /// [lang] is the two-letter language code.
  /// [onPrefetchComplete] is called with the resulting items on success.
  /// Errors are silently swallowed so background failures never surface.
  Future<void> prefetch({
    required String lang,
    String? cursor,
    required void Function(List<FeedItemModel> items) onPrefetchComplete,
  }) async {
    if (_inFlight) return;
    _inFlight = true;

    final myGeneration = _generation;

    try {
      final result = await _repository.getFeed(lang: lang, cursor: cursor);

      // R3: Check generation — if cancel() was called while we were in-flight,
      // discard the result to prevent language bleed or stale data injection.
      if (_generation != myGeneration) return;

      result.when(
        success: (items) {
          if (items.isNotEmpty && _generation == myGeneration) {
            onPrefetchComplete(items);
          }
        },
        failure: (_, __) {},
      );
    } catch (_) {
      // Swallow all errors from background work.
    } finally {
      _inFlight = false;
    }
  }

  /// Cancels any in-flight prefetch by incrementing the generation counter.
  /// The in-flight request continues but its callback will be discarded.
  void cancel() {
    _generation++;
    _inFlight = false;
  }
}
