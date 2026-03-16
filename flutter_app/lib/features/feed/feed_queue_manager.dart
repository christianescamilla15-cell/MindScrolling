import 'dart:collection';

import '../../data/models/feed_item_model.dart';
import '../../core/constants/app_constants.dart';

/// Manages the in-memory buffer of upcoming feed items.
///
/// The queue is separate from [FeedState.items] so that prefetched pages
/// can be merged without directly mutating the Riverpod state on every tick.
class FeedQueueManager {
  final Queue<FeedItemModel> _queue = Queue();

  // -------------------------------------------------------------------------
  // Queue operations
  // -------------------------------------------------------------------------

  /// Appends [items] to the end of the queue.
  void enqueue(List<FeedItemModel> items) {
    for (final item in items) {
      _queue.addLast(item);
    }
  }

  /// Removes and returns the next item, or null when the queue is empty.
  FeedItemModel? dequeue() => _queue.isNotEmpty ? _queue.removeFirst() : null;

  /// Peeks at the next item without removing it.
  FeedItemModel? peek() => _queue.isNotEmpty ? _queue.first : null;

  /// Injects [card] two positions ahead of the current front.
  /// If the queue has fewer than 2 items, [card] is simply added to the front.
  void injectSpecialCard(FeedItemModel card) {
    if (_queue.length < 2) {
      _queue.addFirst(card);
      return;
    }
    final items = _queue.toList();
    items.insert(2, card);
    _queue.clear();
    for (final item in items) {
      _queue.addLast(item);
    }
  }

  // -------------------------------------------------------------------------
  // State queries
  // -------------------------------------------------------------------------

  /// Returns true when a background prefetch should be initiated.
  bool get shouldPrefetch => _queue.length < AppConstants.feedPageSize ~/ 4;

  int get length => _queue.length;

  bool get isEmpty => _queue.isEmpty;

  /// Drains all items into a list without clearing the queue.
  List<FeedItemModel> toList() => _queue.toList();

  /// Clears the queue — used when the feed is reset (e.g. language change).
  void clear() => _queue.clear();
}
