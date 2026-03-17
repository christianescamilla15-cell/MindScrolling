import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Floating direction label that appears during card drag.
///
/// Shows the category name (localized) in the direction the user is swiping.
/// Opacity scales with [intensity] (0.0 = invisible, 1.0 = fully visible).
class SwipeDirectionOverlay extends StatelessWidget {
  const SwipeDirectionOverlay({
    super.key,
    required this.direction,
    required this.intensity,
  });

  /// 'up', 'down', 'left', 'right' or null
  final String? direction;

  /// 0.0 to 1.0 — how far the user has dragged
  final double intensity;

  @override
  Widget build(BuildContext context) {
    if (direction == null || intensity < 0.1) return const SizedBox.shrink();

    final tr = context.tr;

    final (label, color, alignment) = switch (direction) {
      'up'    => (tr.swipeUpLabel,    AppColors.stoicism,   Alignment.topCenter),
      'down'  => (tr.swipeDownLabel,  AppColors.philosophy, Alignment.bottomCenter),
      'left'  => (tr.swipeLeftLabel,  AppColors.reflection, Alignment.centerLeft),
      'right' => (tr.swipeRightLabel, AppColors.discipline, Alignment.centerRight),
      _       => ('', AppColors.textMuted, Alignment.center),
    };

    if (label.isEmpty) return const SizedBox.shrink();

    final opacity = (intensity * 1.5).clamp(0.0, 1.0);

    // Position based on direction
    final EdgeInsets padding = switch (direction) {
      'up'    => const EdgeInsets.only(top: 20),
      'down'  => const EdgeInsets.only(bottom: 20),
      'left'  => const EdgeInsets.only(left: 24),
      'right' => const EdgeInsets.only(right: 24),
      _       => EdgeInsets.zero,
    };

    return Positioned.fill(
      child: IgnorePointer(
        child: Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 100),
              opacity: opacity,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: color.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _directionIcon(direction!),
                      size: 16,
                      color: color,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: AppTypography.labelSmall.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _directionIcon(String dir) => switch (dir) {
    'up'    => Icons.arrow_upward_rounded,
    'down'  => Icons.arrow_downward_rounded,
    'left'  => Icons.arrow_back_rounded,
    'right' => Icons.arrow_forward_rounded,
    _       => Icons.swipe,
  };
}
