import 'dart:async';
import 'package:flutter/foundation.dart';

/// A simple debouncer that delays the execution of an action until
/// [delay] has elapsed since the last call.
///
/// Usage:
/// ```dart
/// final _debounce = Debounce(delay: const Duration(milliseconds: 300));
///
/// void _onChanged(String value) {
///   _debounce(() => _search(value));
/// }
///
/// @override
/// void dispose() {
///   _debounce.dispose();
///   super.dispose();
/// }
/// ```
class Debounce {
  /// Creates a [Debounce] with the given [delay].
  Debounce({required this.delay});

  /// How long to wait after the last call before executing the action.
  final Duration delay;

  Timer? _timer;

  /// Schedules [action] to run after [delay].
  ///
  /// If called again before the timer fires, the previous schedule is
  /// cancelled and a new one is started.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Whether there is a pending scheduled action.
  bool get isPending => _timer?.isActive ?? false;

  /// Cancels any pending action without executing it.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels any pending action and releases resources.
  ///
  /// The instance must not be used after calling [dispose].
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
