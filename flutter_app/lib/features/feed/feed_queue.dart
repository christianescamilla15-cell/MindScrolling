import '../../data/models/feed_item_model.dart';

/// A bounded queue of [FeedItemModel] items that drives the swipe stack.
///
/// When [length] falls below [prefetchThreshold], callers should trigger a
/// background page fetch to keep the queue full. Use [pop] to consume items
/// as the user swipes, [peek] to inspect the next item without consuming it,
/// and [add] to append a newly loaded page.
class FeedQueue {
  FeedQueue({this.prefetchThreshold = 5});

  /// Number of remaining items at which a prefetch should be requested.
  final int prefetchThreshold;

  final List<FeedItemModel> _items = [];

  // ---------------------------------------------------------------------------
  // Accessors
  // ---------------------------------------------------------------------------

  /// How many items remain in the queue.
  int get length => _items.length;

  /// True when no items remain.
  bool get isEmpty => _items.isEmpty;

  /// True when the queue still has items.
  bool get isNotEmpty => _items.isNotEmpty;

  /// True when remaining items have dropped below [prefetchThreshold].
  bool get needsPrefetch => _items.length < prefetchThreshold;

  // ---------------------------------------------------------------------------
  // Mutation
  // ---------------------------------------------------------------------------

  /// Returns and removes the front item, or null when empty.
  FeedItemModel? pop() {
    if (_items.isEmpty) return null;
    return _items.removeAt(0);
  }

  /// Returns the front item without removing it, or null when empty.
  FeedItemModel? peek() => _items.isNotEmpty ? _items.first : null;

  /// Appends all [newItems] to the back of the queue.
  void add(List<FeedItemModel> newItems) {
    _items.addAll(newItems);
  }

  /// Removes all items — used when resetting the feed (e.g. language change).
  void clear() => _items.clear();

  /// A read-only snapshot of the current queue contents.
  List<FeedItemModel> toList() => List<FeedItemModel>.unmodifiable(_items);
}
