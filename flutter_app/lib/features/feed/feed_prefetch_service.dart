import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';

/// Handles background prefetching of feed pages.
///
/// Tracks a single in-flight request to avoid double-fetching.
/// Notifies the caller via [onPrefetchComplete] when data arrives.
class FeedPrefetchService {
  FeedPrefetchService({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;

  bool _inFlight = false;
  bool get isInFlight => _inFlight;

  // -------------------------------------------------------------------------
  // Prefetch
  // -------------------------------------------------------------------------

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

    try {
      final result = await _repository.getFeed(lang: lang, cursor: cursor);
      result.when(
        success: (items) {
          if (items.isNotEmpty) {
            onPrefetchComplete(items);
          }
        },
        failure: (_, __) {
          // Prefetch errors are non-fatal; the caller will retry when
          // shouldPrefetch is re-evaluated on the next swipe.
        },
      );
    } catch (_) {
      // Belt-and-suspenders: swallow all errors from background work.
    } finally {
      _inFlight = false;
    }
  }

  /// Resets the in-flight flag — used on dispose or feed reset.
  void cancel() {
    _inFlight = false;
  }
}
