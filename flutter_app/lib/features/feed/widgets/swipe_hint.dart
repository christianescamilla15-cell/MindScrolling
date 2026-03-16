import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';

/// Animated swipe direction hint overlay. Shown on first launch, fades out
/// after 2.5 seconds.
class SwipeHint extends StatefulWidget {
  const SwipeHint({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  State<SwipeHint> createState() => _SwipeHintState();
}

class _SwipeHintState extends State<SwipeHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _controller.forward().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              _DirectionHint(icon: Icons.arrow_upward, label: 'PHILOSOPHY', color: AppColors.philosophy),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _DirectionHint(icon: Icons.arrow_back, label: 'STOICISM', color: AppColors.stoicism),
                  SizedBox(width: 64),
                  _DirectionHint(icon: Icons.arrow_forward, label: 'DISCIPLINE', color: AppColors.discipline),
                ],
              ),
              SizedBox(height: 32),
              _DirectionHint(icon: Icons.arrow_downward, label: 'REFLECTION', color: AppColors.reflection),
            ],
          ),
        ),
      ),
    );
  }
}

class _DirectionHint extends StatelessWidget {
  const _DirectionHint({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: color,
            letterSpacing: 1.4,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
