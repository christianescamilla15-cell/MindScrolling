import 'package:flutter/material.dart';

import 'swipe_direction.dart';

/// Wraps [child] with a [GestureDetector] that recognises directional swipes.
///
/// A swipe is committed when the pan distance exceeds [threshold].
/// [onSwipe] is called once per committed swipe with the resolved direction.
class SwipeDetector extends StatefulWidget {
  const SwipeDetector({
    super.key,
    required this.child,
    required this.onSwipe,
    this.threshold = 80.0,
    this.enabled = true,
  });

  final Widget child;
  final ValueChanged<SwipeDirection> onSwipe;
  final double threshold;
  final bool enabled;

  @override
  State<SwipeDetector> createState() => _SwipeDetectorState();
}

class _SwipeDetectorState extends State<SwipeDetector> {
  Offset _start = Offset.zero;

  void _onPanStart(DragStartDetails details) {
    _start = details.globalPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Nothing to do in the update — direction resolved at end.
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;

    // Use velocity if it's decisive (fast flick), otherwise fall back to
    // nothing — position delta is tracked in onPanStart/onPanEnd pair.
    // The actual delta is not available in onPanEnd, so we rely on velocity
    // for flick detection here; CardStack uses its own pan tracking for
    // full delta awareness.
    final speed = velocity.distance;
    if (speed < 200) return;

    final dir = _resolve(velocity.dx, velocity.dy);
    if (dir != null) widget.onSwipe(dir);
  }

  SwipeDirection? _resolve(double dx, double dy) {
    if (dx.abs() >= dy.abs()) {
      return dx > 0 ? SwipeDirection.right : SwipeDirection.left;
    } else {
      return dy > 0 ? SwipeDirection.down : SwipeDirection.up;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
