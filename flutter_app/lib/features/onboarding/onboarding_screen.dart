import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
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

class _Page0 extends StatelessWidget {
  const _Page0({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 24),
          const OnboardingIntro(),
          const SizedBox(height: 40),
          _PrimaryButton(
            label: 'Next',
            onPressed: onNext,
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
            'Tell us about yourself',
            style: AppTypography.displaySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'All fields are optional.',
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
            label: 'Begin Scrolling',
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

class _Page2 extends StatelessWidget {
  const _Page2({required this.isCompleting, required this.onStart});
  final bool isCompleting;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '✦',
            style: TextStyle(
              fontSize: 48,
              color: AppColors.stoicism,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "You're all set.",
            style: AppTypography.displayLarge.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Wisdom awaits in every direction.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 56),
          _PrimaryButton(
            label: isCompleting ? 'Starting…' : 'Start Scrolling',
            onPressed: isCompleting ? null : onStart,
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
          'Language',
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
            color: active ? AppColors.stoicism : AppColors.border,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
