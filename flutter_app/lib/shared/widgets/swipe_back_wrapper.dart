import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Wraps any widget and enables an edge-swipe-right gesture to pop the current
/// route — equivalent to the native iOS swipe-back behaviour.
///
/// The gesture is intentionally restricted:
///   - The drag must START within [edgeWidth] pixels of the left edge.
///   - The horizontal velocity must exceed [velocityThreshold] px/s, OR
///     the total horizontal offset must exceed [offsetThreshold] px.
///
/// Both thresholds must be tuned conservatively so that the gesture does not
/// conflict with horizontal content inside the child (e.g. Dismissible rows).
///
/// Usage:
/// ```dart
/// return SwipeBackWrapper(child: Scaffold(...));
/// ```
class SwipeBackWrapper extends StatefulWidget {
  final Widget child;

  /// Maximum x-position at which a drag must begin to qualify as an edge swipe.
  final double edgeWidth;

  /// Minimum fling velocity (px/s) to trigger the pop on drag-end.
  final double velocityThreshold;

  /// Minimum drag offset (px) to trigger the pop on drag-end when velocity
  /// is too low (slow deliberate swipe rather than a fling).
  final double offsetThreshold;

  const SwipeBackWrapper({
    required this.child,
    super.key,
    this.edgeWidth = 20.0,
    this.velocityThreshold = 300.0,
    this.offsetThreshold = 100.0,
  });

  @override
  State<SwipeBackWrapper> createState() => _SwipeBackWrapperState();
}

class _SwipeBackWrapperState extends State<SwipeBackWrapper> {
  // x position where the drag started; null when no drag is in progress.
  double? _dragStartX;

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final startX = _dragStartX;
    _dragStartX = null;

    if (startX == null) return;

    // Only honour drags that originated near the left edge.
    if (startX > widget.edgeWidth) return;

    final velocity = details.primaryVelocity ?? 0.0;
    final offset = (details.localPosition.dx - startX).abs();

    final isFling = velocity > widget.velocityThreshold;
    final isSlowSwipe = offset > widget.offsetThreshold;

    if (isFling || isSlowSwipe) {
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      // behavior: opaque so the gesture arena picks this up even when the
      // child has no interactive widgets near the left edge.
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
