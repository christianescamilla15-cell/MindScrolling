import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Bundled quotes shown during cold start (~30s on Render free tier).
/// These are hardcoded so no network call is needed.
const _kLoadingQuotes = [
  ('"The unexamined life is not worth living."', 'Socrates'),
  ('"He who has a why to live can bear almost any how."', 'Nietzsche'),
  ('"You have power over your mind, not outside events. Realise this, and you will find strength."', 'Marcus Aurelius'),
  ('"It is not that I\'m so smart, it\'s just that I stay with problems longer."', 'Einstein'),
  ('"Man is condemned to be free."', 'Sartre'),
  ('"Waste no more time arguing about what a good man should be. Be one."', 'Marcus Aurelius'),
];

class FeedLoadingShimmer extends StatefulWidget {
  const FeedLoadingShimmer({super.key});

  @override
  State<FeedLoadingShimmer> createState() => _FeedLoadingShimmerState();
}

class _FeedLoadingShimmerState extends State<FeedLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  int _quoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _quoteIndex = DateTime.now().millisecondsSinceEpoch % _kLoadingQuotes.length;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
    _cycle();
  }

  void _cycle() async {
    while (mounted) {
      await Future.delayed(const Duration(seconds: 6));
      if (!mounted) return;
      await _ctrl.reverse();
      if (!mounted) return;
      setState(() {
        _quoteIndex = (_quoteIndex + 1) % _kLoadingQuotes.length;
      });
      if (!mounted) return;
      if (mounted) _ctrl.forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (quote, author) = _kLoadingQuotes[_quoteIndex];
    return Stack(
      children: [
        // Shimmer card placeholder
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Shimmer.fromColors(
            baseColor: AppColors.surface,
            highlightColor: AppColors.surfaceVariant,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        // Overlaid animated quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      style: AppTypography.quoteText.copyWith(
                        fontSize: 20,
                        height: 1.6,
                        color: AppColors.textPrimary.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '— $author',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.stoicism,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: AppColors.stoicism.withValues(alpha: 0.4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.tr.loadingReflections,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
