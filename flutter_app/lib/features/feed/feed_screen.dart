import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/feed_item_model.dart';
import '../../app/localization/app_strings.dart';
import '../ambient/ambient_audio_button.dart';
import '../ambient/ambient_audio_controller.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../../core/utils/haptics_service.dart';
import '../challenges/challenges_controller.dart';
import 'package:in_app_review/in_app_review.dart';
import '../../shared/widgets/streak_milestone_dialog.dart';
import '../premium/premium_controller.dart';
import '../share_export/share_export_service.dart';
import '../settings/settings_controller.dart';
import '../../data/providers/author_affinity_provider.dart';
import '../insight/insight_panel.dart';
import 'feed_controller.dart';
import 'feed_state.dart';
import 'widgets/challenge_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/refinement_card.dart';
import 'widgets/reflection_card.dart';
import 'widgets/soft_paywall_card.dart';
import 'widgets/swipe_direction_overlay.dart';
import 'widgets/swipe_hint.dart';

// ─── Provider override helper ─────────────────────────────────────────────────
// Usage: wrap FeedScreen in a ProviderScope that overrides feedControllerProvider
// with a real FeedController. See bootstrap_screen.dart for reference.

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final CardSwiperController _swiperController = CardSwiperController();
  bool _showHint = false;
  bool _trialExpiredDialogShown = false;
  ProviderSubscription<AsyncValue<PremiumUiState>>? _premiumSub;

  // Swipe direction overlay state
  String? _swipeDirection;
  double _swipeIntensity = 0.0;

  // Auto-dismiss timer for reflection / evolution cards (Fix 2)
  Timer? _reflectionDismissTimer;
  // Track which feed index the current timer was started for, so we do not
  // restart it unnecessarily on every build.
  int? _reflectionTimerIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load persisted swipe count + feed
      final feedCtrl = ref.read(feedControllerProvider.notifier);
      await feedCtrl.loadPersistedSwipeCount();
      final lang = ref.read(settingsStateProvider).lang;
      feedCtrl.loadInitialFeed(lang);

      // Listen for trial expiry — show dialog when premium status finishes loading
      _premiumSub = ref.listenManual(premiumControllerProvider, (prev, next) {
        final ps = next.valueOrNull;
        if (ps != null && !ps.isLoading && ps.trialExpired &&
            !ps.premiumState.isPremium && !_trialExpiredDialogShown) {
          if (mounted) {
            _trialExpiredDialogShown = true;
            _showTrialExpiredDialog(context);
          }
        }
      });

      // Show swipe hint on first ever feed visit
      final prefs = await SharedPreferences.getInstance();
      final hintShown = prefs.getBool('mindscroll_hint_shown') ?? false;
      if (!hintShown && mounted) {
        setState(() => _showHint = true);
        await prefs.setBool('mindscroll_hint_shown', true);
      }

      // Auto-start ambient audio:
      // - After onboarding (first time) OR
      // - Every session if user had it enabled
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        try {
          final audioState = ref.read(ambientAudioStateProvider);
          final shouldAutostart = prefs.getBool('mindscroll_audio_autostart') ?? false;

          if (shouldAutostart) {
            // First time after onboarding
            await prefs.setBool('mindscroll_audio_autostart', false);
            final audioCtrl = ref.read(ambientAudioControllerProvider.notifier);
            await audioCtrl.setEnabled(true);
            await audioCtrl.setVolume(0.35);
            await audioCtrl.playPause();
          } else if (audioState.isEnabled && !audioState.isPlaying) {
            // Returning user who had audio enabled — resume playback
            final audioCtrl = ref.read(ambientAudioControllerProvider.notifier);
            await audioCtrl.playPause();
          }
        } catch (_) {}
      }
    });
  }

  void _showTrialExpiredDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          ctx.tr.trialExpiredTitle,
          style: AppTypography.displaySmall.copyWith(color: AppColors.stoicism),
          textAlign: TextAlign.center,
        ),
        content: Text(
          ctx.tr.trialExpiredMsg,
          style: AppTypography.bodyMedium,
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text(ctx.tr.continueReading,
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(c);
              context.push('/premium');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.stoicism,
              foregroundColor: const Color(0xFF0D0D1A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(ctx.tr.trialExpiredButton,
                style: AppTypography.buttonLabel),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _premiumSub?.close();
    _reflectionDismissTimer?.cancel();
    _swiperController.dispose();
    super.dispose();
  }

  // ─── Reflection card auto-dismiss timer ──────────────────────────────────────

  /// Starts (or restarts) the 4-second auto-dismiss timer for reflection cards.
  ///
  /// [index] is the feed index of the current reflection card. The timer is
  /// only started once per index — subsequent builds caused by unrelated state
  /// changes will not reset the countdown.
  void _startReflectionDismissTimer(int index) {
    if (_reflectionTimerIndex == index && _reflectionDismissTimer?.isActive == true) {
      return; // Timer already running for this card.
    }
    _reflectionDismissTimer?.cancel();
    _reflectionTimerIndex = index;
    _reflectionDismissTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      // Programmatic swipe upwards triggers _onSwipe which calls
      // advanceReflectionCard() — no counter increment.
      _swiperController.swipe(CardSwiperDirection.top);
    });
  }

  void _cancelReflectionDismissTimer() {
    _reflectionDismissTimer?.cancel();
    _reflectionDismissTimer = null;
    _reflectionTimerIndex = null;
  }

  // ─── Swipe handler ───────────────────────────────────────────────────────────

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final state = ref.read(feedControllerProvider);
    final swipedItem = (previousIndex < state.items.length)
        ? state.items[previousIndex]
        : null;

    // Fix 3 — Reflection / evolution card: block horizontal swipes.
    // Returning false causes the card to snap back without any side-effects.
    if (swipedItem != null &&
        (swipedItem.isReflectionCard || swipedItem.isEvolutionCard) &&
        (direction == CardSwiperDirection.left ||
            direction == CardSwiperDirection.right)) {
      // Reset overlay so the direction indicator clears.
      setState(() {
        _swipeDirection = null;
        _swipeIntensity = 0.0;
      });
      return false; // Card snaps back; no state change.
    }

    // Always cancel the auto-dismiss timer when the user swipes manually.
    _cancelReflectionDismissTimer();

    final dirStr = switch (direction) {
      CardSwiperDirection.left => 'left',
      CardSwiperDirection.right => 'right',
      CardSwiperDirection.top => 'up',
      CardSwiperDirection.bottom => 'down',
      _ => 'left',
    };

    if (swipedItem != null && swipedItem.isSoftPaywallCard) {
      // Soft paywall card — dismiss without counting as a quote swipe (US-B07).
      ref.read(feedControllerProvider.notifier).advanceIndex();
    } else if (swipedItem != null &&
        (swipedItem.isReflectionCard || swipedItem.isEvolutionCard)) {
      // Fix 1 — Reflection / evolution card: advance without incrementing
      // the daily swipe counter.
      ref.read(feedControllerProvider.notifier).advanceReflectionCard();
    } else if (swipedItem != null && swipedItem.isRefinementCard) {
      // MED-07: Refinement card — dismiss without counting as quote swipe
      ref.read(feedControllerProvider.notifier).advanceIndex();
    } else {
      ref.read(feedControllerProvider.notifier).onSwipe(dirStr);
    }

    // Reset overlay after swipe completes.
    setState(() {
      _swipeDirection = null;
      _swipeIntensity = 0.0;
    });
    return true;
  }

  // ─── Build ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(feedControllerProvider);

    // Reload feed when the user changes the language in Settings
    ref.listen<SettingsState>(settingsStateProvider, (prev, next) {
      if (prev != null && prev.lang != next.lang) {
        ref.read(feedControllerProvider.notifier).loadInitialFeed(next.lang);
      }
    });

    // Show toast when state has message
    ref.listen<FeedState>(feedControllerProvider, (prev, next) {
      if (next.toastMessage != null &&
          next.toastMessage != prev?.toastMessage) {
        final resolved = context.tr.resolveToastKey(next.toastMessage!) ?? next.toastMessage!;
        _showToast(context, resolved, next.toastColor);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            ref.read(feedControllerProvider.notifier).clearToast();
          }
        });
      }
      // Streak milestone check
      if (prev != null && next.streak != prev.streak && mounted) {
        StreakMilestoneDialog.checkAndShow(context, next.streak);
      }
      // Sync challenge progress on every swipe (incremental updates)
      if (prev != null &&
          next.reflections > prev.reflections &&
          mounted) {
        final cs = ref.read(challengeStateProvider);
        if (!cs.completed) {
          ref
              .read(challengesControllerProvider.notifier)
              .updateFromSwipes(next.reflections);
          // Haptic on completion
          if (next.reflections >= cs.target && prev.reflections < cs.target) {
            HapticsService.heavyImpact();
          }
        }
      }
      // Refinement card injection at swipe 50 (all users, once only).
      if (prev != null &&
          next.reflections >= 50 &&
          prev.reflections < 50 &&
          mounted) {
        ref
            .read(feedControllerProvider.notifier)
            .maybeInjectRefinementCard()
            .ignore();
      }
      // Soft paywall injection at swipe 100 for Trial users (US-B07).
      if (prev != null &&
          next.reflections >= 100 &&
          prev.reflections < 100 &&
          mounted) {
        final isTrial = ref.read(premiumStateProvider).isTrial;
        if (isTrial) {
          ref
              .read(feedControllerProvider.notifier)
              .maybeinjectSoftPaywall()
              .ignore();
        }
      }
      // Rating prompt after 3rd vault save.
      if (next.requestRating && !(prev?.requestRating ?? false) && mounted) {
        ref.read(feedControllerProvider.notifier).clearRatingRequest();
        final review = InAppReview.instance;
        review.isAvailable().then((available) {
          if (available) review.requestReview();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  streak: state.streak,
                  reflections: state.reflections,
                  streakPulse: state.streakPulse,
                ),
                // Insight panel — visible only for Inside (premium) users
                if (ref.watch(premiumStateProvider).premiumState.isPremium)
                  const InsightPanel(),
                Expanded(child: _buildBody(state)),
                AppBottomNav(currentIndex: 0),
              ],
            ),
            // Swipe direction indicator
            SwipeDirectionOverlay(
              direction: _swipeDirection,
              intensity: _swipeIntensity,
            ),
            if (_showHint)
              SwipeHint(onDismiss: () => setState(() => _showHint = false)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(FeedState state) {
    if (state.isLoading && state.items.isEmpty) {
      return _LoadingShimmer();
    }
    if (state.hasError && state.items.isEmpty) {
      return _ErrorView(
        message: state.errorMessage ?? context.tr.couldNotLoadQuotes,
        onRetry: () {
          final lang = ref.read(settingsStateProvider).lang;
          ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);
        },
      );
    }
    if (state.isEmpty) {
      return Center(
        child: Text(context.tr.noQuotesAvailable, style: AppTypography.bodyMedium),
      );
    }
    if (state.items.isNotEmpty && state.currentIndex >= state.items.length) {
      return _ErrorView(
        message: context.tr.noMoreQuotes,
        onRetry: () {
          final lang = ref.read(settingsStateProvider).lang;
          ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);
        },
      );
    }

    final controller = ref.read(feedControllerProvider.notifier);
    final isPremium = ref.watch(premiumStateProvider).isPremium;

    // Free users: 20 quotes per session
    // Free users: 20 swipes per day
    if (!isPremium && state.reflections >= 20) {
      return _FeedLimitView(onUpgrade: () => context.push('/premium'));
    }

    return CardSwiper(
      key: const ValueKey('main_feed_swiper'),
      controller: _swiperController,
      cardsCount: state.items.length,
      initialIndex: state.currentIndex,
      onSwipe: _onSwipe,
      allowedSwipeDirection: const AllowedSwipeDirection.all(),
      numberOfCardsDisplayed: 1,
      backCardOffset: const Offset(0, 0),
      scale: 1.0,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
        // Guard against CardSwiper pre-rendering beyond the list end
        if (index >= state.items.length) return const SizedBox.shrink();

        // Track swipe direction from the top card only
        if (index == (state.currentIndex % state.items.length)) {
          final hAbs = horizontalOffsetPercentage.abs();
          final vAbs = verticalOffsetPercentage.abs();
          final maxOffset = hAbs > vAbs ? hAbs : vAbs;
          final intensity = (maxOffset / 40).clamp(0.0, 1.0);

          String? dir;
          if (maxOffset > 5) {
            if (hAbs > vAbs) {
              dir = horizontalOffsetPercentage > 0 ? 'right' : 'left';
            } else {
              dir = verticalOffsetPercentage > 0 ? 'down' : 'up';
            }
          }

          // Schedule state update after build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && (_swipeDirection != dir || (_swipeIntensity - intensity).abs() > 0.05)) {
              setState(() {
                _swipeDirection = dir;
                _swipeIntensity = intensity;
              });
            }
          });
        }

        final item = state.items[index];

        // Fix 2 — Start auto-dismiss timer when a reflection / evolution card
        // becomes the active (top) card. The timer check is index-gated so
        // it only fires once per card, not on every build frame.
        if ((item.isReflectionCard || item.isEvolutionCard) &&
            index == state.currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _startReflectionDismissTimer(index);
          });
        }

        return _buildCard(context, item, state, controller, isPremium);
      },
    );
  }

  Widget _buildCard(
    BuildContext context,
    FeedItemModel item,
    FeedState state,
    FeedController controller,
    bool isPremium,
  ) {
    if (item.isSoftPaywallCard) {
      return const SoftPaywallCard();
    }
    if (item.isRefinementCard) {
      final extra = item.extra ?? {};
      final topCategory = extra['topCategory'] as String? ?? 'stoicism';
      return RefinementCard(
        topCategory: topCategory,
        onDismiss: () => controller.advanceIndex(),
      );
    }
    if (item.isChallengeCard) {
      final extra = item.extra ?? {};
      return ChallengeCard(
        title: extra['title'] as String? ?? 'Daily Challenge',
        description: extra['description'] as String? ?? '',
        progressRatio: (extra['progress'] as num?)?.toDouble() ?? 0.0,
        onTrack: () {},
      );
    }
    if (item.isReflectionCard || item.isEvolutionCard) {
      return const ReflectionCard();
    }
    if (item.isQuote && item.quote != null) {
      final quote = item.quote!;
      return QuoteCard(
        quote: quote,
        isLiked: state.likedIds.contains(quote.id),
        isSaved: state.vault.any((q) => q.id == quote.id),
        onLike: () {
          final wasLiked = state.likedIds.contains(quote.id);
          controller.onLike(quote.id);
          if (!wasLiked) {
            ref.read(authorAffinityProvider.notifier).recordLike(quote.author);
          }
        },
        onSave: () {
          final alreadySaved = state.vault.any((q) => q.id == quote.id);
          controller.onVaultSave(quote, isPremium: isPremium);
          if (!alreadySaved) {
            ref.read(authorAffinityProvider.notifier).recordVaultSave(quote.author);
          }
        },
        onShare: () => ShareExportService.exportQuoteAsImage(context, quote),
        onExport: null,
        onMoreLikeThis: () => context.push('/similar/${quote.id}'),
      );
    }
    return const SizedBox.shrink();
  }

  void _showToast(BuildContext context, String message, String? hexColor) {
    Color color = AppColors.textSecondary;
    if (hexColor != null) {
      try {
        color = Color(int.parse(hexColor.replaceFirst('#', 'FF'), radix: 16));
      } catch (_) {}
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTypography.caption.copyWith(color: Colors.white)),
        backgroundColor: color.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

const _kFreeSwipeLimit = 20;

class _Header extends ConsumerWidget {
  const _Header({
    required this.streak,
    required this.reflections,
    required this.streakPulse,
  });

  final int streak;
  final int reflections;
  final bool streakPulse;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(premiumStateProvider).isPremium;
    final remaining = (_kFreeSwipeLimit - reflections).clamp(0, _kFreeSwipeLimit);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            context.tr.appName,
            style: AppTypography.displaySmall.copyWith(fontSize: 20),
          ),
          const SizedBox(width: 8),
          const AmbientAudioButton(),
          const Spacer(),
          // Free swipe counter — only shown for non-premium users
          if (!isPremium) ...[
            _FreeSwipeChip(remaining: remaining),
            const SizedBox(width: 8),
          ],
          // Reflection count
          _StatChip(
            icon: Icons.auto_stories_outlined,
            value: reflections.toString(),
            color: AppColors.philosophy,
          ),
          const SizedBox(width: 8),
          // Streak
          AnimatedScale(
            scale: streakPulse ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: _StatChip(
              icon: Icons.local_fire_department_outlined,
              value: streak.toString(),
              color: AppColors.streak,
            ),
          ),
        ],
      ),
    );
  }
}

class _FreeSwipeChip extends StatelessWidget {
  const _FreeSwipeChip({required this.remaining});
  final int remaining;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (remaining > 10) {
      color = AppColors.textMuted;
    } else if (remaining > 4) {
      color = AppColors.discipline; // orange
    } else {
      color = const Color(0xFFE05C5C); // red
    }

    return GestureDetector(
      onTap: () => context.push('/premium'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.30), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              remaining > 0
                  ? Icons.lock_open_outlined
                  : Icons.lock_outline_rounded,
              size: 11,
              color: color,
            ),
            const SizedBox(width: 3),
            Text(
              '$remaining/$_kFreeSwipeLimit',
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTypography.caption
                .copyWith(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom navigation ───────────────────────────────────────────────────────

// Bottom nav extracted to shared/widgets/app_bottom_nav.dart

// ─── Loading shimmer (interactive) ───────────────────────────────────────────

// Bundled quotes shown during cold start (~30s on Render free tier).
// These are hardcoded so no network call is needed.
const _kLoadingQuotes = [
  ('"The unexamined life is not worth living."', 'Socrates'),
  ('"He who has a why to live can bear almost any how."', 'Nietzsche'),
  ('"You have power over your mind, not outside events. Realise this, and you will find strength."', 'Marcus Aurelius'),
  ('"It is not that I\'m so smart, it\'s just that I stay with problems longer."', 'Einstein'),
  ('"Man is condemned to be free."', 'Sartre'),
  ('"Waste no more time arguing about what a good man should be. Be one."', 'Marcus Aurelius'),
];

class _LoadingShimmer extends StatefulWidget {
  const _LoadingShimmer();

  @override
  State<_LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<_LoadingShimmer>
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

// ─── Error view ──────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(message, style: AppTypography.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onRetry,
              child: Text(context.tr.tryAgain, style: const TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Feed limit view (free users, 20 quotes/session) ─────────────────────────

class _FeedLimitView extends StatelessWidget {
  const _FeedLimitView({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_outline, color: AppColors.stoicism, size: 48),
            const SizedBox(height: 16),
            Text(
              context.tr.feedLimitReached,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onUpgrade,
              child: Text(
                context.tr.premiumUnlock,
                style: const TextStyle(color: AppColors.stoicism),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
