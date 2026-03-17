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
import '../premium/premium_controller.dart';
import '../share_export/share_export_service.dart';
import '../settings/settings_controller.dart';
import 'feed_controller.dart';
import 'feed_state.dart';
import 'widgets/challenge_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/reflection_card.dart';
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

  // Swipe direction overlay state
  String? _swipeDirection;
  double _swipeIntensity = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Load feed
      final lang = ref.read(settingsStateProvider).lang;
      ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);

      // Check if trial expired — show dialog
      final ps = ref.read(premiumStateProvider);
      if (ps.trialExpired && !ps.premiumState.isPremium) {
        _showTrialExpiredDialog(context);
      }

      // Show swipe hint on first ever feed visit
      final prefs = await SharedPreferences.getInstance();
      final hintShown = prefs.getBool('mindscroll_hint_shown') ?? false;
      if (!hintShown && mounted) {
        setState(() => _showHint = true);
        await prefs.setBool('mindscroll_hint_shown', true);
      }

      // Auto-start ambient audio after onboarding (delayed to ensure audio is ready)
      final shouldAutostart = prefs.getBool('mindscroll_audio_autostart') ?? false;
      if (shouldAutostart) {
        await prefs.setBool('mindscroll_audio_autostart', false); // only once
        await Future.delayed(const Duration(seconds: 2)); // wait for audio init
        if (mounted) {
          try {
            final audioCtrl = ref.read(ambientAudioControllerProvider.notifier);
            await audioCtrl.setEnabled(true);
            await audioCtrl.setVolume(0.35);
            await audioCtrl.playPause();
          } catch (_) {}
        }
      }
    });
  }

  void _showTrialExpiredDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
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
    _swiperController.dispose();
    super.dispose();
  }

  // ─── Swipe handler ───────────────────────────────────────────────────────────

  bool _onSwipe(
    int previousIndex,
    int? currentIndex,
    CardSwiperDirection direction,
  ) {
    final dirStr = switch (direction) {
      CardSwiperDirection.left => 'left',
      CardSwiperDirection.right => 'right',
      CardSwiperDirection.top => 'up',
      CardSwiperDirection.bottom => 'down',
      _ => 'left',
    };
    ref.read(feedControllerProvider.notifier).onSwipe(dirStr);
    // Reset overlay after swipe completes
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
    if (!isPremium && state.currentIndex >= 20) {
      return _FeedLimitView(onUpgrade: () => context.push('/premium'));
    }

    return CardSwiper(
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
        onLike: () => controller.onLike(quote.id),
        onSave: () => controller.onVaultSave(quote, isPremium: isPremium),
        onShare: () => ShareExportService.exportQuoteAsImage(context, quote),
        onExport: null,
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
        backgroundColor: color.withOpacity(0.9),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.streak,
    required this.reflections,
    required this.streakPulse,
  });

  final int streak;
  final int reflections;
  final bool streakPulse;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Text(
            'MindScroll',
            style: AppTypography.displaySmall.copyWith(fontSize: 20),
          ),
          const SizedBox(width: 8),
          const AmbientAudioButton(),
          const Spacer(),
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
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
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

// ─── Loading shimmer ─────────────────────────────────────────────────────────

class _LoadingShimmer extends StatelessWidget {
  const _LoadingShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surfaceVariant,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(28),
        ),
      ),
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
