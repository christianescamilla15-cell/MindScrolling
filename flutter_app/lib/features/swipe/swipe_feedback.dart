import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import 'swipe_direction.dart';

/// An overlay widget that gives the user visual feedback while dragging a
/// quote card in a particular direction.
///
/// Place this widget on top of the card stack and supply the current
/// [direction] and [progress] (0.0 → 1.0) driven by the drag gesture.
/// The overlay fades in with [AnimatedOpacity] and shows a translucent
/// background tinted with the category colour plus a centred direction label.
///
/// When [direction] is `null` or [progress] is 0 the overlay is invisible.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     CardStack(...),
///     SwipeFeedback(direction: _activeDir, progress: _dragProgress),
///   ],
/// )
/// ```
class SwipeFeedback extends StatelessWidget {
  const SwipeFeedback({
    super.key,
    required this.direction,
    required this.progress,
  });

  /// The direction the user is currently dragging, or `null` when idle.
  final SwipeDirection? direction;

  /// A value from 0.0 (no drag) to 1.0 (fully committed drag) that drives
  /// the overlay opacity and badge scale.
  final double progress;

  @override
  Widget build(BuildContext context) {
    final dir = direction;

    // Clamp to avoid any floating-point overshoot.
    final clamped = progress.clamp(0.0, 1.0);

    // Invisible when there is no active direction or drag hasn't started.
    if (dir == null || clamped == 0.0) {
      return const SizedBox.expand();
    }

    final categoryColor = dir.color;
    // Max overlay opacity is 0.35 so the card content is still visible.
    final overlayOpacity = (clamped * 0.35).clamp(0.0, 0.35);
    // Badge fades in faster — fully opaque at 60 % of progress.
    final badgeOpacity = ((clamped / 0.6)).clamp(0.0, 1.0);

    return SizedBox.expand(
      child: AnimatedOpacity(
        opacity: clamped > 0.0 ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 80),
        child: Stack(
          children: [
            // -----------------------------------------------------------------
            // Tinted background
            // -----------------------------------------------------------------
            Container(
              color: categoryColor.withOpacity(overlayOpacity),
            ),

            // -----------------------------------------------------------------
            // Direction badge (arrow + label)
            // -----------------------------------------------------------------
            Center(
              child: AnimatedOpacity(
                opacity: badgeOpacity,
                duration: const Duration(milliseconds: 60),
                child: _DirectionBadge(direction: dir, scale: clamped),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Direction badge
// ---------------------------------------------------------------------------

class _DirectionBadge extends StatelessWidget {
  const _DirectionBadge({
    required this.direction,
    required this.scale,
  });

  final SwipeDirection direction;

  /// 0.0–1.0 progress value used to lightly scale the badge for a pop feel.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final color = direction.color;
    // Subtle grow: starts at 0.85 and reaches 1.0 at full progress.
    final badgeScale = 0.85 + (scale * 0.15);

    return Transform.scale(
      scale: badgeScale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              direction.arrow,
              style: TextStyle(
                fontSize: 28,
                color: color,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              direction.label.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
