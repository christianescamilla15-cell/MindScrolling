import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/feed_item_model.dart';
import '../premium/premium_controller.dart';
import '../share_export/share_export_service.dart';
import '../settings/settings_controller.dart';
import 'feed_controller.dart';
import 'feed_state.dart';
import 'widgets/challenge_card.dart';
import 'widgets/quote_card.dart';
import 'widgets/reflection_card.dart';
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
  bool _showHint = false; // set true on first-ever launch via SharedPreferences

  @override
  void initState() {
    super.initState();
    // Load feed on mount using the persisted language preference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final lang = ref.read(settingsStateProvider).lang;
      ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);
    });
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
        _showToast(context, next.toastMessage!, next.toastColor);
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
                _BottomNav(currentIndex: 0),
              ],
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
        message: state.errorMessage ?? 'Could not load quotes.',
        onRetry: () {
          final lang = ref.read(settingsStateProvider).lang;
          ref.read(feedControllerProvider.notifier).loadInitialFeed(lang);
        },
      );
    }
    if (state.isEmpty) {
      return const Center(
        child: Text('No quotes available.', style: AppTypography.bodyMedium),
      );
    }

    final controller = ref.read(feedControllerProvider.notifier);
    final isPremium = ref.watch(premiumStateProvider).isPremium;

    return CardSwiper(
      controller: _swiperController,
      cardsCount: state.items.length,
      initialIndex: state.currentIndex,
      onSwipe: _onSwipe,
      allowedSwipeDirection: const AllowedSwipeDirection.all(),
      numberOfCardsDisplayed: 2,
      backCardOffset: const Offset(0, 24),
      scale: 0.94,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      cardBuilder: (context, index, horizontalOffsetPercentage, verticalOffsetPercentage) {
        // Guard against CardSwiper pre-rendering beyond the list end
        if (index >= state.items.length) return const SizedBox.shrink();
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
        onSave: () => controller.onVaultSave(quote),
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

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex});

  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Feed',
            isActive: currentIndex == 0,
            onTap: () => context.go('/feed'),
          ),
          _NavItem(
            icon: Icons.bookmark_border,
            activeIcon: Icons.bookmark,
            label: 'Vault',
            isActive: currentIndex == 1,
            onTap: () => context.push('/vault'),
          ),
          _NavItem(
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: 'Map',
            isActive: currentIndex == 2,
            onTap: () => context.push('/philosophy-map'),
          ),
          _NavItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome,
            label: 'Insight',
            isActive: currentIndex == 3,
            activeColor: AppColors.philosophy,
            onTap: () => context.push('/insights'),
          ),
          _NavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: 'Settings',
            isActive: currentIndex == 4,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? (activeColor ?? AppColors.stoicism)
        : AppColors.textMuted;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isActive ? activeIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.caption.copyWith(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

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
              child: const Text('Try again', style: TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}
