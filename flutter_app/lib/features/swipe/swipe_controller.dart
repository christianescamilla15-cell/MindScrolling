import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import 'swipe_direction.dart';

/// Tracks the current drag gesture and derives direction + edge colour.
///
/// This is a plain Dart class — no Flutter state management needed because
/// the parent [CardStack] drives repaints via its own [setState] calls.
class SwipeController {
  Offset _startPosition = Offset.zero;
  Offset _dragOffset = Offset.zero;
  bool isDragging = false;
  String? flyDirection; // set when a swipe is committed

  static const double threshold = 80.0;

  Offset get dragOffset => _dragOffset;

  // -------------------------------------------------------------------------
  // Drag lifecycle
  // -------------------------------------------------------------------------

  void startDrag(Offset position) {
    _startPosition = position;
    _dragOffset = Offset.zero;
    isDragging = true;
    flyDirection = null;
  }

  void updateDrag(Offset position) {
    _dragOffset = position - _startPosition;
  }

  /// Returns the committed direction string if the drag exceeds [threshold],
  /// otherwise null (drag was cancelled / too short).
  String? endDrag(Offset position) {
    _dragOffset = position - _startPosition;
    isDragging = false;

    final dx = _dragOffset.dx;
    final dy = _dragOffset.dy;
    final dist = _dragOffset.distance;

    if (dist < threshold) {
      _dragOffset = Offset.zero;
      return null;
    }

    final dir = _getDirection(dx, dy);
    flyDirection = dir;
    return dir;
  }

  void reset() {
    _dragOffset = Offset.zero;
    isDragging = false;
    flyDirection = null;
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  /// Determines primary axis from dx/dy magnitudes.
  String _getDirection(double dx, double dy) {
    if (dx.abs() >= dy.abs()) {
      return dx > 0 ? 'right' : 'left';
    } else {
      return dy > 0 ? 'down' : 'up';
    }
  }

  /// Returns the category accent colour appropriate for the current drag
  /// direction, or transparent when the user is not dragging.
  Color getEdgeColor() {
    if (!isDragging || _dragOffset.distance < 20) return AppColors.transparent;
    final dir = _getDirection(_dragOffset.dx, _dragOffset.dy);
    return AppColors.categoryColor(
      SwipeDirectionX.fromString(dir).category,
    );
  }

  /// Normalised drag progress [0, 1] toward the threshold. Used for animating
  /// the edge glow intensity.
  double get dragProgress =>
      (_dragOffset.distance / threshold).clamp(0.0, 1.0);

  /// Current direction of drag if one has been established, null otherwise.
  SwipeDirection? get currentDragDirection {
    if (!isDragging || _dragOffset.distance < 10) return null;
    return SwipeDirectionX.fromString(
      _getDirection(_dragOffset.dx, _dragOffset.dy),
    );
  }
}
