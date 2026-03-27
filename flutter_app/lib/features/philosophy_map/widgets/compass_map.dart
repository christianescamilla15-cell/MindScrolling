import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/philosophy_map_model.dart';

/// Circular compass-style visualization of the four philosophy scores.
///
/// Points: UP = stoicism, RIGHT = discipline, DOWN = philosophy, LEFT = reflection.
/// Each point is rendered as a colored circle whose radius scales with the score.
/// Lines connect each point to the center.
class CompassMap extends StatelessWidget {
  final PhilosophyScores scores;
  final double size;

  const CompassMap({
    super.key,
    required this.scores,
    this.size = 260,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CompassPainter(scores: scores),
        child: _Labels(size: size, scores: scores),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _CompassPainter extends CustomPainter {
  final PhilosophyScores scores;

  const _CompassPainter({required this.scores});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 28;

    // ── Background ring ────────────────────────────────────────────────
    final ringPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, ringPaint);

    // Cross-hair lines
    final crossPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;
    canvas.drawLine(
        center - Offset(radius, 0), center + Offset(radius, 0), crossPaint);
    canvas.drawLine(
        center - Offset(0, radius), center + Offset(0, radius), crossPaint);

    // ── Points (UP=stoicism, RIGHT=discipline, DOWN=philosophy, LEFT=reflection) ──
    const points = [
      _Point(key: 'wisdom', angle: -math.pi / 2, color: AppColors.stoicism),
      _Point(key: 'discipline', angle: 0, color: AppColors.discipline),
      _Point(key: 'philosophy', angle: math.pi / 2, color: AppColors.philosophy),
      _Point(key: 'reflection', angle: math.pi, color: AppColors.reflection),
    ];

    final scoreMap = scores.toMap();
    final total = scores.total;

    for (final p in points) {
      final raw = scoreMap[p.key] ?? 0.0;
      final normalized = total > 0 ? raw / total : 0.0;
      final dist = normalized * radius;

      final pointOffset = Offset(
        center.dx + dist * math.cos(p.angle),
        center.dy + dist * math.sin(p.angle),
      );

      // Line to center
      canvas.drawLine(
        center,
        pointOffset,
        Paint()
          ..color = p.color.withOpacity(0.4)
          ..strokeWidth = 1.5,
      );

      // Dot — size proportional to score
      final dotRadius = 6 + normalized * 12;
      canvas.drawCircle(
        pointOffset,
        dotRadius,
        Paint()..color = p.color.withOpacity(0.9),
      );

      // Glow ring
      canvas.drawCircle(
        pointOffset,
        dotRadius + 4,
        Paint()
          ..color = p.color.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
    }

    // Center dot
    canvas.drawCircle(
      center,
      4,
      Paint()..color = AppColors.textMuted,
    );
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.scores != scores;
}

class _Point {
  final String key;
  final double angle;
  final Color color;
  const _Point({required this.key, required this.angle, required this.color});
}

// ---------------------------------------------------------------------------
// Labels widget (overlay on the custom paint)
// ---------------------------------------------------------------------------

class _Labels extends StatelessWidget {
  final double size;
  final PhilosophyScores scores;

  const _Labels({required this.size, required this.scores});

  @override
  Widget build(BuildContext context) {
    final half = size / 2;

    return Stack(
      children: [
        // UP — stoicism
        const Positioned(
          top: 2,
          left: 0,
          right: 0,
          child: Center(
            child: _Label('Stoicism', AppColors.stoicism),
          ),
        ),
        // RIGHT — discipline
        Positioned(
          right: 2,
          top: half - 10,
          child: const _Label('Discipline', AppColors.discipline),
        ),
        // DOWN — philosophy
        const Positioned(
          bottom: 2,
          left: 0,
          right: 0,
          child: Center(
            child: _Label('Philosophy', AppColors.philosophy),
          ),
        ),
        // LEFT — reflection
        Positioned(
          left: 2,
          top: half - 10,
          child: const _Label('Reflection', AppColors.reflection),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final Color color;
  const _Label(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.caption.copyWith(color: color, fontSize: 10),
    );
  }
}
