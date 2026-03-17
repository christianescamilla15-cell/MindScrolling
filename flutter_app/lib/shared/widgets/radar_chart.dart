import 'dart:math';
import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';

/// A 4-axis radar/spider chart for the philosophy map.
///
/// Each axis represents one philosophical category with a value from 0–100.
/// Draws a filled polygon over a background grid.
class RadarChart extends StatelessWidget {
  const RadarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.colors,
    this.previousValues,
    this.size = 240,
  });

  /// Values in order: [stoicism, philosophy, discipline, reflection] (0–100)
  final List<double> values;

  /// Labels in the same order
  final List<String> labels;

  /// Colors for each axis
  final List<Color> colors;

  /// Previous snapshot values (draws ghost overlay)
  final List<double>? previousValues;

  /// Widget size (square)
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(
          values: values,
          labels: labels,
          colors: colors,
          previousValues: previousValues,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({
    required this.values,
    required this.labels,
    required this.colors,
    this.previousValues,
  });

  final List<double> values;
  final List<String> labels;
  final List<Color> colors;
  final List<double>? previousValues;

  static const int _sides = 4;
  // Angles: top, right, bottom, left (clockwise from top)
  static const List<double> _angles = [
    -pi / 2,      // top (stoicism)
    0,            // right (philosophy)
    pi / 2,       // bottom (discipline)
    pi,           // left (reflection)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.35;

    // Draw grid rings (25%, 50%, 75%, 100%)
    _drawGrid(canvas, center, radius);

    // Draw axis lines
    _drawAxes(canvas, center, radius);

    // Draw previous snapshot polygon (ghost)
    if (previousValues != null) {
      _drawPolygon(
        canvas, center, radius, previousValues!,
        fillColor: AppColors.textMuted.withOpacity(0.06),
        strokeColor: AppColors.textMuted.withOpacity(0.2),
        strokeWidth: 1,
      );
    }

    // Draw current values polygon
    _drawPolygon(
      canvas, center, radius, values,
      fillColor: AppColors.stoicism.withOpacity(0.12),
      strokeColor: AppColors.stoicism.withOpacity(0.8),
      strokeWidth: 2,
    );

    // Draw value dots on each axis
    _drawDots(canvas, center, radius);

    // Draw labels
    _drawLabels(canvas, center, radius, size);
  }

  void _drawGrid(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (final level in [0.25, 0.5, 0.75, 1.0]) {
      final r = radius * level;
      final path = Path();
      for (int i = 0; i < _sides; i++) {
        final x = center.dx + r * cos(_angles[i]);
        final y = center.dy + r * sin(_angles[i]);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawAxes(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 0.5;

    for (int i = 0; i < _sides; i++) {
      final x = center.dx + radius * cos(_angles[i]);
      final y = center.dy + radius * sin(_angles[i]);
      canvas.drawLine(center, Offset(x, y), paint);
    }
  }

  void _drawPolygon(
    Canvas canvas,
    Offset center,
    double radius,
    List<double> vals, {
    required Color fillColor,
    required Color strokeColor,
    required double strokeWidth,
  }) {
    final path = Path();
    for (int i = 0; i < _sides; i++) {
      final v = (vals.length > i ? vals[i] : 0).clamp(0.0, 100.0) / 100;
      final r = radius * v;
      final x = center.dx + r * cos(_angles[i]);
      final y = center.dy + r * sin(_angles[i]);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill
    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // Stroke
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _drawDots(Canvas canvas, Offset center, double radius) {
    for (int i = 0; i < _sides; i++) {
      final v = (values.length > i ? values[i] : 0).clamp(0.0, 100.0) / 100;
      final r = radius * v;
      final x = center.dx + r * cos(_angles[i]);
      final y = center.dy + r * sin(_angles[i]);
      final color = colors.length > i ? colors[i] : AppColors.stoicism;

      // Outer glow
      canvas.drawCircle(
        Offset(x, y),
        6,
        Paint()..color = color.withOpacity(0.2),
      );
      // Inner dot
      canvas.drawCircle(
        Offset(x, y),
        3.5,
        Paint()..color = color,
      );
    }
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, Size size) {
    for (int i = 0; i < _sides; i++) {
      final label = labels.length > i ? labels[i] : '';
      final color = colors.length > i ? colors[i] : AppColors.textSecondary;
      final value = values.length > i ? values[i].round() : 0;

      // Position labels outside the chart
      final labelRadius = radius + 28;
      final x = center.dx + labelRadius * cos(_angles[i]);
      final y = center.dy + labelRadius * sin(_angles[i]);

      final textSpan = TextSpan(
        children: [
          TextSpan(
            text: '$label\n',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          TextSpan(
            text: '$value%',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              color: color.withOpacity(0.6),
            ),
          ),
        ],
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout(maxWidth: 80);

      // Center the label around the computed position
      final offset = Offset(
        x - textPainter.width / 2,
        y - textPainter.height / 2,
      );

      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.previousValues != previousValues;
  }
}
