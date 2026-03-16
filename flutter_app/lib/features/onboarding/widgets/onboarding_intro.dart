import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Page 1 of onboarding: explains the 4-direction swipe mechanics.
///
/// Shows a compass-style 2×2 grid of animated direction indicators,
/// each pulsing gently to draw attention.
class OnboardingIntro extends StatefulWidget {
  const OnboardingIntro({super.key});

  @override
  State<OnboardingIntro> createState() => _OnboardingIntroState();
}

class _OnboardingIntroState extends State<OnboardingIntro>
    with TickerProviderStateMixin {
  final List<AnimationController> _pulseControllers = [];
  final List<Animation<double>> _scaleAnims = [];

  static const _directionBases = [
    _DirectionBase(arrow: '↑', category: 'stoicism', color: AppColors.stoicism),
    _DirectionBase(arrow: '→', category: 'discipline', color: AppColors.discipline),
    _DirectionBase(arrow: '←', category: 'reflection', color: AppColors.reflection),
    _DirectionBase(arrow: '↓', category: 'philosophy', color: AppColors.philosophy),
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _directionBases.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1200),
      );
      final anim = Tween<double>(begin: 1.0, end: 1.08).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _pulseControllers.add(ctrl);
      _scaleAnims.add(anim);

      // Stagger each direction's pulse start.
      Future.delayed(Duration(milliseconds: i * 250), () {
        if (mounted) ctrl.repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _pulseControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    // Build localised direction labels from the static base data.
    final directions = [
      _DirectionInfo(
        arrow: _directionBases[0].arrow,
        label: tr.swipeUpLabel,
        color: _directionBases[0].color,
      ),
      _DirectionInfo(
        arrow: _directionBases[1].arrow,
        label: tr.swipeRightLabel,
        color: _directionBases[1].color,
      ),
      _DirectionInfo(
        arrow: _directionBases[2].arrow,
        label: tr.swipeLeftLabel,
        color: _directionBases[2].color,
      ),
      _DirectionInfo(
        arrow: _directionBases[3].arrow,
        label: tr.swipeDownLabel,
        color: _directionBases[3].color,
      ),
    ];

    return Column(
      children: [
        // Title
        Text(
          tr.welcomeTitle,
          style: AppTypography.displayMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          tr.welcomeSubtitle,
          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        // 2×2 compass grid
        SizedBox(
          width: 260,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DirectionCard(
                    info: directions[0],
                    scaleAnim: _scaleAnims[0],
                  ),
                  _DirectionCard(
                    info: directions[1],
                    scaleAnim: _scaleAnims[1],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _DirectionCard(
                    info: directions[2],
                    scaleAnim: _scaleAnims[2],
                  ),
                  _DirectionCard(
                    info: directions[3],
                    scaleAnim: _scaleAnims[3],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          tr.swipeToExplore,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.info,
    required this.scaleAnim,
  });

  final _DirectionInfo info;
  final Animation<double> scaleAnim;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: scaleAnim,
      builder: (_, __) => Transform.scale(
        scale: scaleAnim.value,
        child: Container(
          width: 110,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: info.color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: info.color.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                info.arrow,
                style: TextStyle(
                  fontSize: 28,
                  color: info.color,
                  height: 1,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                info.label,
                style: AppTypography.labelSmall.copyWith(color: info.color),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Static base data (arrow + category + color) — locale-independent.
class _DirectionBase {
  final String arrow;
  final String category;
  final Color color;

  const _DirectionBase({
    required this.arrow,
    required this.category,
    required this.color,
  });
}

/// Runtime data including the localised label.
class _DirectionInfo {
  final String arrow;
  final String label;
  final Color color;

  const _DirectionInfo({
    required this.arrow,
    required this.label,
    required this.color,
  });
}
