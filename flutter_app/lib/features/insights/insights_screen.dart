import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import 'insights_controller.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(insightsControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(insightsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
          child: Column(
            children: [
              _Header(
              onRefresh: state.isRefreshing
                  ? null
                  : () =>
                      ref.read(insightsControllerProvider.notifier).refresh(),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.philosophy,
                backgroundColor: AppColors.surface,
                onRefresh: () =>
                    ref.read(insightsControllerProvider.notifier).refresh(),
                child: _buildBody(state),
              ),
            ),
              AppBottomNav(currentIndex: 3),
            ],
          ),
        ),
    );
  }

  Widget _buildBody(InsightsState state) {
    if (state.isLoading) {
      return _LoadingView();
    }
    if (state.premiumRequired) {
      return _PremiumPromptView(
        onUpgrade: () => context.push('/premium'),
      );
    }
    if (state.error != null && state.insight == null) {
      return _ErrorView(
        message: state.error!,
        onRetry: () => ref.read(insightsControllerProvider.notifier).load(),
      );
    }
    if (state.insight == null) {
      return _EmptyView();
    }
    return _InsightView(
      state: state,
      onRefresh: () => ref.read(insightsControllerProvider.notifier).refresh(),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback? onRefresh;

  const _Header({this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
      child: Row(
        children: [
          Text(
            context.tr.weeklyInsight,
            style: AppTypography.displaySmall.copyWith(fontSize: 20),
          ),
          const Spacer(),
          // AI badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.philosophy.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.philosophy.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: AppColors.philosophy,
                ),
                const SizedBox(width: 4),
                Text(
                  context.tr.aiBadge,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.philosophy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(
              Icons.refresh_rounded,
              color: onRefresh != null
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              size: 22,
            ),
            tooltip: context.tr.refreshInsight,
          ),
        ],
      ),
    );
  }
}

// ─── Insight card ─────────────────────────────────────────────────────────────

class _InsightView extends StatelessWidget {
  final InsightsState state;
  final VoidCallback onRefresh;

  const _InsightView({required this.state, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final insight = state.insight!;
    final generatedAt = insight.generatedAt;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        // ── Date label ──────────────────────────────────────────────────
        if (generatedAt != null) ...[
          Row(
            children: [
              Icon(
                Icons.schedule_outlined,
                size: 13,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(generatedAt, context),
                style: AppTypography.caption
                    .copyWith(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ] else
          const SizedBox(height: 8),

        // ── Insight card ─────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.philosophy.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.philosophy.withOpacity(0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opening quote mark
              Text(
                '\u201C',
                style: AppTypography.quoteText.copyWith(
                  fontSize: 48,
                  color: AppColors.philosophy.withOpacity(0.4),
                  height: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              // Insight text
              Text(
                insight.insight,
                style: AppTypography.quoteText.copyWith(
                  fontSize: 18,
                  height: 1.7,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ── Caption ──────────────────────────────────────────────────────
        Row(
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 13,
              color: AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                context.tr.generatedByAI,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),

        // ── Error banner (stale data + error) ─────────────────────────
        if (state.error != null) ...[
          const SizedBox(height: 16),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFFF6B6B).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: Color(0xFFFF6B6B),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.tr.couldNotRefresh,
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFFFF6B6B),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Refreshing indicator ─────────────────────────────────────
        if (state.isRefreshing) ...[
          const SizedBox(height: 20),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: AppColors.philosophy,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime dt, BuildContext context) {
    final tr = context.tr;
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return tr.justGenerated;
    if (diff.inHours < 24) return tr.hoursAgo(diff.inHours);
    if (diff.inDays == 1) return tr.yesterday;
    return '${diff.inDays} ${tr.daysAgo}';
  }
}

// ─── Loading ─────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Shimmer.fromColors(
        baseColor: AppColors.surface,
        highlightColor: AppColors.surfaceVariant,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date shimmer
            Container(
              width: 100,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 20),
            // Card shimmer
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty ───────────────────────────────────────────────────────────────────

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 40),
        Icon(
          Icons.psychology_outlined,
          size: 56,
          color: AppColors.philosophy.withOpacity(0.4),
        ),
        const SizedBox(height: 24),
        Text(
          context.tr.insightForming,
          style: AppTypography.displaySmall.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          context.tr.insightFormingBody,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Tip cards
        _TipCard(
          icon: Icons.swipe,
          text: context.tr.insightTip1,
        ),
        const SizedBox(height: 10),
        _TipCard(
          icon: Icons.favorite_border,
          text: context.tr.insightTip2,
        ),
        const SizedBox(height: 10),
        _TipCard(
          icon: Icons.bookmark_border,
          text: context.tr.insightTip3,
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipCard({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.philosophy),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Premium prompt ───────────────────────────────────────────────────────────

class _PremiumPromptView extends StatelessWidget {
  final VoidCallback onUpgrade;

  const _PremiumPromptView({required this.onUpgrade});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 56,
              color: AppColors.philosophy.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              context.tr.insightPremiumTitle,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.tr.insightPremiumBody,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: onUpgrade,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.philosophy,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                context.tr.upgradeToPremium,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Error ───────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onRetry,
              child: Text(
                context.tr.tryAgain,
                style: const TextStyle(color: AppColors.philosophy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Bottom nav extracted to shared/widgets/app_bottom_nav.dart
