import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';

// ─── Public preference key ────────────────────────────────────────────────────

const String kFeatureTourDoneKey = 'mindscroll_feature_tour_done';

// ─── Entry-point helper ───────────────────────────────────────────────────────

/// Shows [FeatureTour] as a full-screen [showGeneralDialog] overlay if the
/// user has not yet seen it.  Safe to call from a post-frame callback.
Future<void> maybeShowFeatureTour(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final done = prefs.getBool(kFeatureTourDoneKey) ?? false;
  if (done) return;
  if (!context.mounted) return;

  // CRIT-01: Mark tour as done BEFORE showing, so a kill mid-tour
  // doesn't cause infinite re-show on next launch.
  await prefs.setBool(kFeatureTourDoneKey, true);

  if (!context.mounted) return;

  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 400),
    transitionBuilder: (ctx, anim, _, child) {
      return FadeTransition(opacity: anim, child: child);
    },
    pageBuilder: (ctx, _, __) => const FeatureTour(),
  );
}

// ─── Tour data model ──────────────────────────────────────────────────────────

class _TourStep {
  const _TourStep({
    required this.icon,
    required this.color,
    required this.titleKey,
    required this.bodyKey,
    this.customVisual,
  });

  final IconData icon;
  final Color color;

  /// Key selectors into [AppStrings] — resolved at build time.
  final String Function(dynamic tr) titleKey;
  final String Function(dynamic tr) bodyKey;

  /// Optional replacement for the default icon circle.
  final Widget Function(Color color)? customVisual;
}

// ─── Feature tour widget ──────────────────────────────────────────────────────

class FeatureTour extends StatefulWidget {
  const FeatureTour({super.key});

  @override
  State<FeatureTour> createState() => _FeatureTourState();
}

class _FeatureTourState extends State<FeatureTour>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Per-page stagger controllers (icon, title, body, button).
  late final List<AnimationController> _staggerCtrls;
  late final List<List<Animation<double>>> _staggerFades;

  static const int _totalPages = 8;
  static const Duration _staggerIn = Duration(milliseconds: 500);
  static const Duration _staggerDelay = Duration(milliseconds: 100);

  // Step definitions — icons and colors per spec.
  late final List<_TourStep> _steps;

  @override
  void initState() {
    super.initState();

    _steps = [
      _TourStep(
        icon: Icons.swipe_outlined,
        color: AppColors.stoicism,           // teal
        titleKey: (tr) => tr.tourSwipeTitle,
        bodyKey: (tr) => tr.tourSwipeBody,
        customVisual: (color) => _SwipeDirectionVisual(color: color),
      ),
      _TourStep(
        icon: Icons.favorite_outline,
        color: AppColors.discipline,          // orange
        titleKey: (tr) => tr.tourLikeTitle,
        bodyKey: (tr) => tr.tourLikeBody,
        customVisual: (color) => _PulsingHeartVisual(color: color),
      ),
      _TourStep(
        icon: Icons.bookmark_outline,
        color: AppColors.stoicism,
        titleKey: (tr) => tr.tourVaultTitle,
        bodyKey: (tr) => tr.tourVaultBody,
      ),
      _TourStep(
        icon: Icons.explore_outlined,
        color: AppColors.reflection,          // purple
        titleKey: (tr) => tr.tourMapTitle,
        bodyKey: (tr) => tr.tourMapBody,
        customVisual: (color) => _DiamondMapVisual(color: color),
      ),
      _TourStep(
        icon: Icons.local_fire_department_outlined,
        color: AppColors.philosophy,          // amber
        titleKey: (tr) => tr.tourChallengeTitle,
        bodyKey: (tr) => tr.tourChallengeBody,
      ),
      _TourStep(
        icon: Icons.equalizer_rounded,
        color: const Color(0xFF60A5FA),       // blue
        titleKey: (tr) => tr.tourAudioTitle,
        bodyKey: (tr) => tr.tourAudioBody,
        customVisual: (color) => _EqualizerVisual(color: color),
      ),
      _TourStep(
        icon: Icons.auto_awesome,
        color: const Color(0xFF8B5CF6),       // violet
        titleKey: (tr) => tr.tourPremiumTitle,
        bodyKey: (tr) => tr.tourPremiumBody,
      ),
      _TourStep(
        icon: Icons.self_improvement_outlined,
        color: AppColors.stoicism,
        titleKey: (tr) => tr.tourReadyTitle,
        bodyKey: (tr) => tr.tourReadyBody,
      ),
    ];

    // Build per-page stagger animation controllers.
    _staggerCtrls = List.generate(
      _totalPages,
      (_) => AnimationController(vsync: this, duration: _staggerIn),
    );

    _staggerFades = _staggerCtrls.map((ctrl) {
      // Four elements: icon, title, body, button — each offset by 100 ms.
      return List.generate(4, (i) {
        final start = (i * 0.18).clamp(0.0, 1.0);
        final end = (start + 0.55).clamp(0.0, 1.0);
        return CurvedAnimation(
          parent: ctrl,
          curve: Interval(start, end, curve: Curves.easeOut),
        );
      });
    }).toList();

    // Play stagger for the first page immediately.
    _playStagger(0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final c in _staggerCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _playStagger(int page) {
    _staggerCtrls[page].forward(from: 0);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  void _onNext() {
    if (_currentPage < _totalPages - 1) {
      _goToPage(_currentPage + 1);
    } else {
      _dismiss();
    }
  }

  void _dismiss() {
    Navigator.of(context).pop();
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    // CRIT-03: Intercept hardware back — go to previous page instead of exiting
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_currentPage > 0) {
          _goToPage(_currentPage - 1);
        }
      },
      child: Material(
      color: Colors.transparent,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xF514141E),
              Color(0xFF0F0F13),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip button row
              _SkipRow(
                currentPage: _currentPage,
                totalPages: _totalPages,
                onSkip: _dismiss,
              ),
              // Page content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (page) {
                    setState(() => _currentPage = page);
                    // Small delay lets the slide settle before fading content in.
                    Timer(_staggerDelay, () {
                      if (mounted) _playStagger(page);
                    });
                  },
                  itemCount: _totalPages,
                  itemBuilder: (_, index) => _TourPage(
                    step: _steps[index],
                    fades: _staggerFades[index],
                    isLast: index == _totalPages - 1,
                    onNext: _onNext,
                  ),
                ),
              ),
              // Page dots
              _PageDots(currentPage: _currentPage, total: _totalPages),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// ─── Skip row ─────────────────────────────────────────────────────────────────

class _SkipRow extends StatelessWidget {
  const _SkipRow({
    required this.currentPage,
    required this.totalPages,
    required this.onSkip,
  });

  final int currentPage;
  final int totalPages;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage == totalPages - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (!isLast)
            TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                context.tr.tourSkip,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            )
          else
            const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─── Individual tour page ─────────────────────────────────────────────────────

class _TourPage extends StatelessWidget {
  const _TourPage({
    required this.step,
    required this.fades,
    required this.isLast,
    required this.onNext,
  });

  final _TourStep step;
  final List<Animation<double>> fades;
  final bool isLast;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    final title = step.titleKey(tr);
    final body = step.bodyKey(tr);
    final buttonLabel = isLast ? tr.tourStart : tr.tourNext;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual (icon circle or custom)
          FadeTransition(
            opacity: fades[0],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.15),
                end: Offset.zero,
              ).animate(fades[0]),
              child: step.customVisual != null
                  ? step.customVisual!(step.color)
                  : _IconCircle(icon: step.icon, color: step.color),
            ),
          ),
          const SizedBox(height: 36),
          // Title
          FadeTransition(
            opacity: fades[1],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.12),
                end: Offset.zero,
              ).animate(fades[1]),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.displayMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Body
          FadeTransition(
            opacity: fades[2],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.10),
                end: Offset.zero,
              ).animate(fades[2]),
              child: Text(
                body,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 48),
          // Button
          FadeTransition(
            opacity: fades[3],
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(fades[3]),
              child: SizedBox(
                width: double.infinity,
                child: _TourButton(
                  label: buttonLabel,
                  color: step.color,
                  isLast: isLast,
                  onTap: onNext,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Tour button ──────────────────────────────────────────────────────────────

class _TourButton extends StatelessWidget {
  const _TourButton({
    required this.label,
    required this.color,
    required this.isLast,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isLast ? color : color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isLast ? 0 : 0.4),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: AppTypography.buttonLabel.copyWith(
                color: isLast
                    ? const Color(0xFF0F0F13)
                    : color,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isLast) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16,
                color: color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Page dots ────────────────────────────────────────────────────────────────

class _PageDots extends StatelessWidget {
  const _PageDots({required this.currentPage, required this.total});

  final int currentPage;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.textPrimary
                : AppColors.textMuted,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

// ─── Icon circle visual (default) ────────────────────────────────────────────

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Icon(icon, size: 36, color: color),
    );
  }
}

// ─── Step 1: Swipe direction visual ──────────────────────────────────────────

class _SwipeDirectionVisual extends StatelessWidget {
  const _SwipeDirectionVisual({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center dot
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.6),
            ),
          ),
          // Up arrow — Wisdom / Stoicism
          Positioned(
            top: 0,
            child: _DirectionArrow(
              icon: Icons.keyboard_arrow_up_rounded,
              label: tr.swipeUpLabel,
              color: color,
            ),
          ),
          // Down arrow — Philosophy
          Positioned(
            bottom: 0,
            child: _DirectionArrow(
              icon: Icons.keyboard_arrow_down_rounded,
              label: tr.swipeDownLabel,
              color: AppColors.philosophy,
            ),
          ),
          // Left arrow — Reflection
          Positioned(
            left: 0,
            child: _DirectionArrow(
              icon: Icons.keyboard_arrow_left_rounded,
              label: tr.swipeLeftLabel,
              color: AppColors.reflection,
              horizontal: true,
            ),
          ),
          // Right arrow — Discipline
          Positioned(
            right: 0,
            child: _DirectionArrow(
              icon: Icons.keyboard_arrow_right_rounded,
              label: tr.swipeRightLabel,
              color: AppColors.discipline,
              horizontal: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _DirectionArrow extends StatelessWidget {
  const _DirectionArrow({
    required this.icon,
    required this.label,
    required this.color,
    this.horizontal = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          style: AppTypography.caption.copyWith(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );

    if (horizontal) {
      return Row(mainAxisSize: MainAxisSize.min, children: [content]);
    }
    return content;
  }
}

// ─── Step 2: Pulsing heart visual ────────────────────────────────────────────

class _PulsingHeartVisual extends StatefulWidget {
  const _PulsingHeartVisual({required this.color});

  final Color color;

  @override
  State<_PulsingHeartVisual> createState() => _PulsingHeartVisualState();
}

class _PulsingHeartVisualState extends State<_PulsingHeartVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color.withValues(alpha: 0.12),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
        child: Icon(Icons.favorite, size: 36, color: widget.color),
      ),
    );
  }
}

// ─── Step 4: Diamond map visual ───────────────────────────────────────────────

class _DiamondMapVisual extends StatelessWidget {
  const _DiamondMapVisual({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: CustomPaint(
        painter: _DiamondPainter(color: color),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  const _DiamondPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.42;

    // Axis lines
    final axisPaint = Paint()
      ..color = color.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx, cy - r), Offset(cx, cy + r), axisPaint);
    canvas.drawLine(Offset(cx - r, cy), Offset(cx + r, cy), axisPaint);

    // Filled diamond (simulated radar)
    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..color = color.withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Slightly asymmetric to look like a real chart
    final path = Path()
      ..moveTo(cx, cy - r * 0.75)   // top
      ..lineTo(cx + r * 0.65, cy)   // right
      ..lineTo(cx, cy + r * 0.55)   // bottom
      ..lineTo(cx - r * 0.80, cy)   // left
      ..close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Axis dots
    final dotPaint = Paint()..color = color.withValues(alpha: 0.6);
    for (final pt in [
      Offset(cx, cy - r),
      Offset(cx + r, cy),
      Offset(cx, cy + r),
      Offset(cx - r, cy),
    ]) {
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_DiamondPainter old) => old.color != color;
}

// ─── Step 6: Equalizer visual ─────────────────────────────────────────────────

class _EqualizerVisual extends StatefulWidget {
  const _EqualizerVisual({required this.color});

  final Color color;

  @override
  State<_EqualizerVisual> createState() => _EqualizerVisualState();
}

class _EqualizerVisualState extends State<_EqualizerVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Bar target heights (0–1 normalised, will be mapped to pixels).
  static const List<double> _barHeights = [0.45, 0.75, 0.55, 0.90, 0.60];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.color.withValues(alpha: 0.12),
        border: Border.all(
          color: widget.color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(_barHeights.length, (i) {
              // Each bar oscillates at a different phase.
              final phase = (i * 0.2 + _ctrl.value).clamp(0.0, 1.0);
              final phaseAnim = (0.5 - (phase - 0.5).abs()) * 2.0;
              final height = 8.0 +
                  (_barHeights[i] * 24.0 * phaseAnim).clamp(4.0, 28.0);
              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.only(bottom: 18, left: 2, right: 2),
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.80),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
