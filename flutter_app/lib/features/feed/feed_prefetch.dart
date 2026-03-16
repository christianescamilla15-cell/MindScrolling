import '../../data/models/feed_item_model.dart';
import '../../data/repositories/feed_repository.dart';
import 'feed_queue.dart';

/// Mixin that adds background prefetch logic to a feed controller.
///
/// Mix this into any class that holds a [FeedRepository] and a [FeedQueue].
/// Call [maybePrefetch] after each swipe to keep the queue above its
/// [FeedQueue.prefetchThreshold].
///
/// Example:
/// ```dart
/// class FeedController extends StateNotifier<FeedState> with FeedPrefetch {
///   FeedController(this.repository, this.queue) : super(FeedState.initial());
///
///   @override
///   final FeedRepository repository;
///   @override
///   final FeedQueue queue;
///
///   Future<void> onSwiped() async {
///     queue.pop();
///     await maybePrefetch(lang: 'en');
///   }
/// }
/// ```
mixin FeedPrefetch {
  /// The repository used to fetch additional pages.
  FeedRepository get repository;

  /// The queue whose depth is monitored.
  FeedQueue get queue;

  bool _prefetchInFlight = false;

  /// Triggers a prefetch if the queue is below threshold and no request is
  /// already in flight. Passes [cursor] to the repository when provided.
  ///
  /// [onLoaded] is called synchronously after the state has been updated so
  /// that the enclosing controller can merge results into its own state.
  Future<void> maybePrefetch({
    required String lang,
    String? cursor,
    void Function(List<FeedItemModel> items)? onLoaded,
  }) async {
    if (!queue.needsPrefetch) return;
    if (_prefetchInFlight) return;

    _prefetchInFlight = true;
    try {
      final result = await repository.getFeed(lang: lang, cursor: cursor);
      result.when(
        success: (items) {
          if (items.isNotEmpty) {
            queue.add(items);
            onLoaded?.call(items);
          }
        },
        failure: (_, __) {
          // Non-fatal — the queue may still have items left to show.
        },
      );
    } catch (_) {
      // Suppress all errors from background prefetch work.
    } finally {
      _prefetchInFlight = false;
    }
  }

  /// Returns true when a background request is currently in flight.
  bool get isPrefetchInFlight => _prefetchInFlight;
}
