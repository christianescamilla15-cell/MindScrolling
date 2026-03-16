import 'package:flutter/material.dart';

import '../../../app/theme/typography.dart';

/// An animated progress bar for a single philosophy category.
///
/// [score] is 0–100.  When [previousScore] is provided a delta arrow is shown.
class CategoryBar extends StatefulWidget {
  final String label;
  final double score;
  final Color color;
  final double? previousScore;

  const CategoryBar({
    super.key,
    required this.label,
    required this.score,
    required this.color,
    this.previousScore,
  });

  @override
  State<CategoryBar> createState() => _CategoryBarState();
}

class _CategoryBarState extends State<CategoryBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(CategoryBar old) {
    super.didUpdateWidget(old);
    if (old.score != widget.score) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pct = widget.score.clamp(0.0, 100.0);
    final prev = widget.previousScore?.clamp(0.0, 100.0);
    final delta = prev != null ? pct - prev : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Text(
                widget.label,
                style: AppTypography.authorText.copyWith(color: widget.color),
              ),
              const Spacer(),
              if (delta != 0) _DeltaIndicator(delta: delta),
              const SizedBox(width: 6),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: AppTypography.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Animated bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: AnimatedBuilder(
              animation: _anim,
              builder: (context, _) {
                return LinearProgressIndicator(
                  value: (_anim.value * pct) / 100.0,
                  backgroundColor: widget.color.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  minHeight: 8,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeltaIndicator extends StatelessWidget {
  final double delta;
  const _DeltaIndicator({required this.delta});

  @override
  Widget build(BuildContext context) {
    final isUp = delta > 0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isUp ? '▲' : '▼',
          style: TextStyle(
            fontSize: 10,
            color: isUp
                ? const Color(0xFF4ADE80) // green
                : const Color(0xFFFF6B6B), // red
          ),
        ),
        const SizedBox(width: 2),
        Text(
          '${delta.abs().toStringAsFixed(0)}%',
          style: AppTypography.caption.copyWith(
            color: isUp
                ? const Color(0xFF4ADE80)
                : const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }
}
