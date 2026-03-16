import 'dart:collection';

import '../../data/models/swipe_event_model.dart';
import '../../data/repositories/feed_repository.dart';

/// Dispatches swipe analytics events to the backend.
///
/// - Events are fire-and-forget.
/// - If a dispatch fails, the event is placed in an in-memory retry queue
///   and retried on the next successful dispatch.
class SwipeEventDispatcher {
  SwipeEventDispatcher({required FeedRepository repository})
      : _repository = repository;

  final FeedRepository _repository;
  final Queue<SwipeEventModel> _retryQueue = Queue();
  bool _isDispatching = false;

  /// Dispatches [event] to the backend and drains any queued events.
  /// Errors are silently swallowed — telemetry must never block UX.
  Future<void> dispatch(SwipeEventModel event) async {
    if (_isDispatching) {
      _retryQueue.addLast(event);
      return;
    }

    _isDispatching = true;
    try {
      await _repository.recordSwipe(event);
      await _drainQueue();
    } catch (_) {
      _retryQueue.addLast(event);
    } finally {
      _isDispatching = false;
    }
  }

  Future<void> _drainQueue() async {
    while (_retryQueue.isNotEmpty) {
      final queued = _retryQueue.removeFirst();
      try {
        await _repository.recordSwipe(queued);
      } catch (_) {
        // Put it back at the front and stop draining.
        _retryQueue.addFirst(queued);
        break;
      }
    }
  }

  /// How many events are currently waiting in the retry queue.
  int get queueLength => _retryQueue.length;
}
