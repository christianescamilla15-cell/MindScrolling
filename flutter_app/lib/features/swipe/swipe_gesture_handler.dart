import 'package:flutter/material.dart';

import 'swipe_direction.dart';

/// A [GestureDetector] wrapper that converts a drag gesture into a committed
/// [SwipeDirection] and reports live drag progress.
///
/// A swipe is committed when the drag delta in the dominant axis exceeds
/// [horizontalThreshold] (for left/right) or [verticalThreshold] (for up/down).
/// When the axes are close, horizontal is preferred when `|dx| >= |dy|`.
///
/// [onSwipe] is called **once** when a swipe commits (finger lifts after
/// crossing the threshold).
///
/// [onDragUpdate] is called continuously during the drag with the current
/// candidate [SwipeDirection] (or `null` if the drag is ambiguous) and a
/// [double] normalised progress value (0.0–1.0) relative to the dominant
/// threshold. Useful for driving [SwipeFeedback].
///
/// [onDragEnd] is called when the gesture ends (regardless of commit).
///
/// Example:
/// ```dart
/// SwipeGestureHandler(
///   onSwipe: (dir) => _handleSwipe(dir),
///   onDragUpdate: (dir, progress) => setState(() {
///     _activeDir = dir;
///     _progress = progress;
///   }),
///   child: QuoteCard(quote: quote),
/// )
/// ```
class SwipeGestureHandler extends StatefulWidget {
  const SwipeGestureHandler({
    super.key,
    required this.child,
    required this.onSwipe,
    this.onDragUpdate,
    this.onDragEnd,
    this.horizontalThreshold = 60.0,
    this.verticalThreshold = 60.0,
    this.enabled = true,
  });

  /// The widget to wrap with swipe detection.
  final Widget child;

  /// Called once when a swipe is committed (drag lifted past threshold).
  final ValueChanged<SwipeDirection> onSwipe;

  /// Continuously called during a drag with the candidate direction and
  /// normalised progress (0.0–1.0). [direction] is `null` when the drag
  /// delta is below a minimum jitter threshold (< 4 px).
  final void Function(SwipeDirection? direction, double progress)?
      onDragUpdate;

  /// Called when the drag gesture ends, regardless of whether a swipe was
  /// committed. Use this to reset feedback state.
  final VoidCallback? onDragEnd;

  /// Minimum horizontal displacement (px) to commit a left/right swipe.
  final double horizontalThreshold;

  /// Minimum vertical displacement (px) to commit an up/down swipe.
  final double verticalThreshold;

  /// When `false`, gesture detection is disabled and the child is returned
  /// as-is.
  final bool enabled;

  @override
  State<SwipeGestureHandler> createState() => _SwipeGestureHandlerState();
}

class _SwipeGestureHandlerState extends State<SwipeGestureHandler> {
  Offset _start = Offset.zero;
  Offset _lastPosition = Offset.zero;
  bool _committed = false;

  void _onPanStart(DragStartDetails details) {
    _start = details.localPosition;
    _lastPosition = details.localPosition;
    _committed = false;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _lastPosition = details.localPosition;
    final delta = details.localPosition - _start;
    final dx = delta.dx;
    final dy = delta.dy;
    final adx = dx.abs();
    final ady = dy.abs();

    // Below jitter threshold — report nothing.
    if (adx < 4.0 && ady < 4.0) {
      widget.onDragUpdate?.call(null, 0.0);
      return;
    }

    // Resolve candidate direction (horizontal preferred on tie).
    final SwipeDirection candidate;
    final double progress;

    if (adx >= ady) {
      // Horizontal
      candidate = dx > 0 ? SwipeDirection.right : SwipeDirection.left;
      progress = (adx / widget.horizontalThreshold).clamp(0.0, 1.0);
    } else {
      // Vertical
      candidate = dy > 0 ? SwipeDirection.down : SwipeDirection.up;
      progress = (ady / widget.verticalThreshold).clamp(0.0, 1.0);
    }

    widget.onDragUpdate?.call(candidate, progress);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_committed) {
      // 1. Try positional commit — drag crossed the threshold slowly.
      final delta = _lastPosition - _start;
      _committed = resolveAndCommitSwipe(
        delta: delta,
        horizontalThreshold: widget.horizontalThreshold,
        verticalThreshold: widget.verticalThreshold,
        onSwipe: widget.onSwipe,
      );
    }

    if (!_committed) {
      // 2. Velocity fallback — fast flick that may not cross positional threshold.
      final velocity = details.velocity.pixelsPerSecond;
      final vx = velocity.dx;
      final vy = velocity.dy;
      final avx = vx.abs();
      final avy = vy.abs();

      if (avx >= 400 || avy >= 400) {
        final dir = avx >= avy
            ? (vx > 0 ? SwipeDirection.right : SwipeDirection.left)
            : (vy > 0 ? SwipeDirection.down : SwipeDirection.up);
        _committed = true;
        widget.onSwipe(dir);
      }
    }

    widget.onDragEnd?.call();
  }

  void _onPanCancel() {
    _committed = false;
    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onPanCancel: _onPanCancel,
      child: widget.child,
    );
  }
}

/// Internal helper: resolves a swipe direction from [delta] and commits the
/// swipe via [onSwipe] when the dominant axis exceeds its threshold.
///
/// Returns `true` if a swipe was committed (so callers can set [_committed]).
bool resolveAndCommitSwipe({
  required Offset delta,
  required double horizontalThreshold,
  required double verticalThreshold,
  required ValueChanged<SwipeDirection> onSwipe,
}) {
  final adx = delta.dx.abs();
  final ady = delta.dy.abs();

  if (adx >= ady && adx >= horizontalThreshold) {
    onSwipe(delta.dx > 0 ? SwipeDirection.right : SwipeDirection.left);
    return true;
  }
  if (ady > adx && ady >= verticalThreshold) {
    onSwipe(delta.dy > 0 ? SwipeDirection.down : SwipeDirection.up);
    return true;
  }
  return false;
}
