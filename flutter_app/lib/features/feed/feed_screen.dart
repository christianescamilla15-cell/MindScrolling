import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/feed_item_model.dart';
import '../ambient/ambient_audio_controller.dart';
import '../onboarding/feature_tour.dart';
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
import 'widgets/feed_error_view.dart';
import 'widgets/feed_header.dart';
import 'widgets/feed_limit_view.dart';
import 'widgets/feed_loading_shimmer.dart';
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

  // Auto-dismiss timer for reflection / evolution cards
  Timer? _reflectionDismissTimer;
  int? _reflectionTimerIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final feedCtrl = ref.read(feedControllerProvider.notifier);
      await feedCtrl.loadPersistedSwipeCount();
      final lang = ref.read(settingsStateProvider).lang;
      feedCtrl.loadInitialFeed(lang);

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

      final prefs = await SharedPreferences.getInstance();
      final hintShown = prefs.getBool('mindscroll_hint_shown') ?? false;
      if (!hintShown && mounted) {
        setState(() => _showHint = true);
        await prefs.setBool('mindscroll_hint_shown', true);
      }

      if (mounted) {
        try {
          await maybeShowFeatureTour(context);
        } catch (_) {}
      }

      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        try {
          final audioState = ref.read(ambientAudioStateProvider);
          final shouldAutostart = prefs.getBool('mindscroll_audio_autostart') ?? false;

          if (shouldAutostart) {
            await prefs.setBool('mindscroll_audio_autostart', false);
            final audioCtrl = ref.read(ambientAudioControllerProvider.notifier);
            await audioCtrl.setEnabled(true);
            await audioCtrl.setVolume(0.35);
            await audioCtrl.playPause();
          } else if (audioState.isEnabled && !audioState.isPlaying) {
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
                style: const TextStyle(color: AppColors.textMuted)),
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

  void _startReflectionDismissTimer(int index) {
    if (_reflectionTimerIndex == index && _reflectionDismissTimer?.isActive == true) {
      return;
    }
    _reflectionDismissTimer?.cancel();
    _reflectionTimerIndex = index;
    _reflectionDismissTimer = Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
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

    if (swipedItem != null &&
        (swipedItem.isReflectionCard || swipedItem.isEvolutionCard) &&
        (direction == CardSwiperDirection.left ||
            direction == CardSwiperDirection.right)) {
      setState(() {
        _swipeDirection = null;
        _swipeIntensity = 0.0;
      });
      return false;
    }

    _cancelReflectionDismissTimer();

    final dirStr = switch (direction) {
      CardSwiperDirection.left => 'left',
      CardSwiperDirection.right => 'right',
      CardSwiperDirection.top => 'up',
      CardSwiperDirection.bottom => 'down',
      _ => 'left',
    };

    if (swipedItem != null && swipedItem.isSoftPaywallCard) {
      ref.read(feedControllerProvider.notifier).advanceIndex();
    } else if (swipedItem != null &&
        (swipedItem.isReflectionCard || swipedItem.isEvolutionCard)) {
      ref.read(feedControllerProvider.notifier).advanceReflectionCard();
    } else if (swipedItem != null && swipedItem.isRefinementCard) {
      ref.read(feedControllerProvider.notifier).advanceIndex();
    } else {
      ref.read(feedControllerProvider.notifier).onSwipe(dirStr);
    }

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

    ref.listen<SettingsState>(settingsStateProvider, (prev, next) {
      if (prev != null && prev.lang != next.lang) {
        ref.read(feedControllerProvider.notifier).loadInitialFeed(next.lang);
      }
    });

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
      if (prev != null && next.streak != prev.streak && mounted) {
        StreakMilestoneDialog.checkAndShow(context, next.streak);
      }
      if (prev != null &&
          next.reflections > prev.reflections &&
          mounted) {
        final cs = ref.read(challengeStateProvider);
        if (!cs.completed) {
          ref
              .read(challengesControllerProvider.notifier)
              .updateFromSwipes(next.reflections);
          if (next.reflections >= cs.target && prev.reflections < cs.target) {
            HapticsService.heavyImpact();
          }
        }
      }
      if (prev != null &&
          next.reflections >= 50 &&
          prev.reflections < 50 &&
          mounted) {
        ref
            .read(feedControllerProvider.notifier)
            .maybeInjectRefinementCard()
            .ignore();
      }
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
                FeedHeader(
                  streak: state.streak,
                  reflections: state.reflections,
                  streakPulse: state.streakPulse,
                ),
                if (ref.watch(premiumStateProvider).premiumState.isPremium)
                  const InsightPanel(),
                Expanded(child: _buildBody(state)),
                const AppBottomNav(currentIndex: 0),
              ],
            ),
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
      return const FeedLoadingShimmer();
    }
    if (state.hasError && state.items.isEmpty) {
      return FeedErrorView(
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
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final lang = ref.read(settingsStateProvider).lang;
          ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);
        }
      });
      return const Center(
        child: CircularProgressIndicator(color: AppColors.stoicism),
      );
    }

    final controller = ref.read(feedControllerProvider.notifier);
    final isPremium = ref.watch(premiumStateProvider).isPremium;

    if (!isPremium && state.reflections >= 20) {
      return FeedLimitView(onUpgrade: () => context.push('/premium'));
    }

    return CardSwiper(
      key: const ValueKey('main_feed_swiper'),
      controller: _swiperController,
      cardsCount: state.items.length,
      initialIndex: state.currentIndex,
      onSwipe: _onSwipe,
      allowedSwipeDirection: const AllowedSwipeDirection.all(),
      numberOfCardsDisplayed: state.items.length >= 3 ? 3 : state.items.length.clamp(1, 3),
      backCardOffset: const Offset(0, -6),
      scale: 0.96,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
        if (index >= state.items.length) return const SizedBox.shrink();

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
        title: extra['title'] as String? ?? context.tr.challengeTitle,
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
