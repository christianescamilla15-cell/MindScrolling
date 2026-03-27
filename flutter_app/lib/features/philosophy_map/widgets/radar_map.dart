import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../data/models/philosophy_map_model.dart';

/// 4-axis radar chart rendered with [CustomPainter].
///
/// The chart is a diamond/square shape rotated 45°.
/// Each axis represents one category; the filled area is proportional to scores.
class RadarMap extends StatefulWidget {
  final PhilosophyScores scores;
  final double size;

  const RadarMap({
    super.key,
    required this.scores,
    this.size = 240,
  });

  @override
  State<RadarMap> createState() => _RadarMapState();
}

class _RadarMapState extends State<RadarMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(RadarMap old) {
    super.didUpdateWidget(old);
    _ctrl.forward(from: 0);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _RadarPainter(
            scores: widget.scores,
            progress: _anim.value,
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

// Axis order: top = wisdom/stoicism, right = discipline, bottom = philosophy, left = reflection
const _axes = [
  _Axis(key: 'wisdom', label: 'Wisdom', color: AppColors.stoicism, angle: -math.pi / 2),
  _Axis(key: 'discipline', label: 'Discipline', color: AppColors.discipline, angle: 0),
  _Axis(key: 'philosophy', label: 'Philosophy', color: AppColors.philosophy, angle: math.pi / 2),
  _Axis(key: 'reflection', label: 'Reflection', color: AppColors.reflection, angle: math.pi),
];

class _RadarPainter extends CustomPainter {
  final PhilosophyScores scores;
  final double progress;

  const _RadarPainter({required this.scores, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 24;
    final scoreMap = scores.toMap();
    final total = scores.total > 0 ? scores.total : 1.0;

    // ── Background grid (3 rings) ─────────────────────────────────────
    final gridPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int ring = 1; ring <= 3; ring++) {
      final r = maxR * ring / 3;
      final path = _buildPolygon(center, r, _axes.map((a) => a.angle).toList());
      canvas.drawPath(path, gridPaint);
    }

    // Axis lines
    for (final axis in _axes) {
      final end = Offset(
        center.dx + maxR * math.cos(axis.angle),
        center.dy + maxR * math.sin(axis.angle),
      );
      canvas.drawLine(center, end, gridPaint);
    }

    // ── Filled area ───────────────────────────────────────────────────
    final points = _axes.map((axis) {
      final norm = (scoreMap[axis.key] ?? 0) / total;
      final r = norm * maxR * progress;
      return Offset(
        center.dx + r * math.cos(axis.angle),
        center.dy + r * math.sin(axis.angle),
      );
    }).toList();

    if (points.isNotEmpty) {
      final fillPath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      }
      fillPath.close();

      canvas.drawPath(
        fillPath,
        Paint()
          ..color = AppColors.stoicism.withOpacity(0.15)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(
        fillPath,
        Paint()
          ..color = AppColors.stoicism.withOpacity(0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // Dots at each vertex
      for (int i = 0; i < points.length; i++) {
        canvas.drawCircle(
          points[i],
          4,
          Paint()..color = _axes[i].color,
        );
      }
    }
  }

  Path _buildPolygon(Offset center, double r, List<double> angles) {
    final path = Path();
    for (int i = 0; i < angles.length; i++) {
      final p = Offset(
        center.dx + r * math.cos(angles[i]),
        center.dy + r * math.sin(angles[i]),
      );
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_RadarPainter old) =>
      old.scores != scores || old.progress != progress;
}

class _Axis {
  final String key;
  final String label;
  final Color color;
  final double angle;
  const _Axis({
    required this.key,
    required this.label,
    required this.color,
    required this.angle,
  });
}
