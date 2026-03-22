import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'onboarding_controller.dart';
import 'widgets/onboarding_intro.dart';
import 'widgets/age_selector.dart';
import 'widgets/interest_selector.dart';
import 'widgets/goal_selector.dart';

/// 3-page onboarding flow.
///
/// Page 0: SwipeGuide (OnboardingIntro)
/// Page 1: Profile collection
/// Page 2: Ready / launch
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;
  late final OnboardingController _controller;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _controller = OnboardingController()..addListener(_rebuild);
  }

  void _rebuild() => setState(() {});

  @override
  void dispose() {
    _controller
      ..removeListener(_rebuild)
      ..dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Page indicator dots
            const SizedBox(height: 16),
            _PageDots(
              count: OnboardingController.totalPages,
              current: _controller.currentPage,
            ),
            const SizedBox(height: 8),
            // PageView
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: _controller.onPageChanged,
                children: [
                  _Page0(
                    onNext: () => _controller.nextPage(_pageController),
                  ),
                  _Page1(
                    controller: _controller,
                    onNext: () => _controller.nextPage(_pageController),
                  ),
                  _Page2(
                    isCompleting: _controller.isCompleting,
                    onStart: () => _controller.complete(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 0: Swipe guide
// ---------------------------------------------------------------------------

class _Page0 extends StatefulWidget {
  const _Page0({required this.onNext});
  final VoidCallback onNext;

  @override
  State<_Page0> createState() => _Page0State();
}

class _Page0State extends State<_Page0> with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _titleFade;
  late final Animation<double> _subtitleFade;
  late final Animation<double> _compassFade;
  late final Animation<double> _buttonFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<Offset> _subtitleSlide;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Staggered: title → subtitle → compass → button
    _titleFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_titleFade);

    _subtitleFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.15, 0.45, curve: Curves.easeOut),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(_subtitleFade);

    _compassFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );

    _buttonFade = CurvedAnimation(
      parent: _fadeCtrl,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 48),

          // ── Hero headline with staggered fade ──
          SlideTransition(
            position: _titleSlide,
            child: FadeTransition(
              opacity: _titleFade,
              child: Text(
                'Stop Doom-Scrolling.',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textPrimary,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SlideTransition(
            position: _subtitleSlide,
            child: FadeTransition(
              opacity: _subtitleFade,
              child: Text(
                'Start Thinking.',
                style: AppTypography.displayLarge.copyWith(
                  fontSize: 32,
                  fontStyle: FontStyle.italic,
                  color: AppColors.stoicism,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          FadeTransition(
            opacity: _subtitleFade,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 24, height: 1, color: AppColors.textMuted),
                const SizedBox(width: 12),
                Text(
                  'MindScrolling',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    letterSpacing: 3,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(width: 12),
                Container(width: 24, height: 1, color: AppColors.textMuted),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // ── Compass grid with fade ──
          FadeTransition(
            opacity: _compassFade,
            child: const OnboardingIntro(),
          ),

          const SizedBox(height: 40),

          // ── CTA button with fade ──
          FadeTransition(
            opacity: _buttonFade,
            child: _PrimaryButton(
              label: context.tr.onboardingNext,
              onPressed: widget.onNext,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 1: Profile collection
// ---------------------------------------------------------------------------

class _Page1 extends StatelessWidget {
  const _Page1({required this.controller, required this.onNext});
  final OnboardingController controller;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text(
            context.tr.tellUsAboutYourself,
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.tr.allFieldsOptional,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          AgeSelector(
            selected: controller.ageRange,
            onSelected: controller.setAgeRange,
          ),
          const SizedBox(height: 28),
          InterestSelector(
            selected: controller.interest,
            onSelected: controller.setInterest,
          ),
          const SizedBox(height: 28),
          GoalSelector(
            selected: controller.goal,
            onSelected: controller.setGoal,
          ),
          const SizedBox(height: 28),
          _LangToggle(
            selected: controller.lang,
            onSelected: controller.setLang,
          ),
          const SizedBox(height: 40),
          _PrimaryButton(
            label: context.tr.beginScrolling,
            onPressed: onNext,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page 2: Ready
// ---------------------------------------------------------------------------

class _Page2 extends StatefulWidget {
  const _Page2({required this.isCompleting, required this.onStart});
  final bool isCompleting;
  final VoidCallback onStart;

  @override
  State<_Page2> createState() => _Page2State();
}

class _Page2State extends State<_Page2> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _iconFade;
  late final Animation<double> _textFade;
  late final Animation<double> _btnFade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _iconFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    _textFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _btnFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated icon
          FadeTransition(
            opacity: _iconFade,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.stoicism.withOpacity(0.1),
                border: Border.all(
                  color: AppColors.stoicism.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 36,
                color: AppColors.stoicism,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Text
          FadeTransition(
            opacity: _textFade,
            child: Column(
              children: [
                Text(
                  context.tr.youreAllSet,
                  style: AppTypography.displayLarge.copyWith(
                    fontStyle: FontStyle.italic,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr.wisdomAwaits,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Trial info
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B6B3A).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '7 ${context.tr.trialDaysLeft(7).split(' ').skip(1).join(' ')}',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF4ADE80),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 48),

          // Button
          FadeTransition(
            opacity: _btnFade,
            child: _PrimaryButton(
              label: widget.isCompleting
                  ? context.tr.starting
                  : context.tr.startScrolling,
              onPressed: widget.isCompleting ? null : widget.onStart,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Language toggle
// ---------------------------------------------------------------------------

class _LangToggle extends StatelessWidget {
  const _LangToggle({required this.selected, required this.onSelected});
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr.language,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              _LangOption(code: 'EN', isSelected: selected == 'en', onTap: () => onSelected('en')),
              _LangOption(code: 'ES', isSelected: selected == 'es', onTap: () => onSelected('es')),
            ],
          ),
        ),
      ],
    );
  }
}

class _LangOption extends StatelessWidget {
  const _LangOption({
    required this.code,
    required this.isSelected,
    required this.onTap,
  });
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.stoicism.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppColors.stoicism, width: 1.5)
                : Border.all(color: Colors.transparent),
          ),
          child: Text(
            code,
            textAlign: TextAlign.center,
            style: AppTypography.buttonLabel.copyWith(
              color: isSelected ? AppColors.stoicism : AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared: Primary button
// ---------------------------------------------------------------------------

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(label, style: AppTypography.buttonLabel),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Page indicator dots
// ---------------------------------------------------------------------------

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? AppColors.stoicism : AppColors.textMuted,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
