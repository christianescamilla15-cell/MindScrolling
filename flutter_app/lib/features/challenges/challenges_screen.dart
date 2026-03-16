import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/widgets/premium_gate.dart';
import '../../shared/extensions/context_extensions.dart';
import 'challenges_controller.dart';

/// Screen showing today's daily philosophy challenge with a progress ring,
/// description, and a "Complete Challenge" button.
class ChallengesScreen extends ConsumerStatefulWidget {
  const ChallengesScreen({super.key});

  @override
  ConsumerState<ChallengesScreen> createState() => _ChallengesScreenState();
}

class _ChallengesScreenState extends ConsumerState<ChallengesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(challengesControllerProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = ref.watch(challengeStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D0D1A),
        elevation: 0,
        centerTitle: false,
        title: Text(
          context.tr.dailyChallenge,
          style: AppTypography.displaySmall,
        ),
      ),
      body: PremiumGate(
        child: cs.isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.stoicism,
                  strokeWidth: 2,
                ),
              )
            : _ChallengeBody(cs: cs),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Body
// ---------------------------------------------------------------------------

class _ChallengeBody extends ConsumerWidget {
  final ChallengeState cs;

  const _ChallengeBody({required this.cs});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenge = cs.challenge;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),

          // ── Progress ring ──────────────────────────────────────────────
          _ProgressRing(ratio: cs.ratio, completed: cs.completed),

          const SizedBox(height: 32),

          // ── Challenge card ─────────────────────────────────────────────
          _ChallengeCard(
            title: challenge?.title ?? context.tr.dailyReflection,
            description: challenge?.description ??
                context.tr.defaultChallengeDesc,
            activeDate: challenge?.activeDate ?? '',
          ),

          const SizedBox(height: 12),

          // ── Inline error note (non-blocking) ───────────────────────────
          if (cs.error != null && !cs.isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.cloud_off,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.tr.offlineChallenge,
                      style: AppTypography.caption,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // ── Action button ──────────────────────────────────────────────
          _ActionButton(
            completed: cs.completed,
            onTap: cs.completed
                ? null
                : () =>
                    ref.read(challengesControllerProvider.notifier).complete(),
          ),

          const SizedBox(height: 16),

          if (!cs.completed)
            TextButton(
              onPressed: () => ref
                  .read(challengesControllerProvider.notifier)
                  .incrementProgress(),
              child: Text(
                context.tr.logOneStep,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.stoicism,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Progress ring
// ---------------------------------------------------------------------------

class _ProgressRing extends StatelessWidget {
  final double ratio;
  final bool completed;

  const _ProgressRing({required this.ratio, required this.completed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background track
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 10,
            backgroundColor: AppColors.stoicism.withOpacity(0.12),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.transparent),
          ),
          // Progress arc
          CircularProgressIndicator(
            value: ratio,
            strokeWidth: 10,
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              completed ? AppColors.stoicism : AppColors.stoicism,
            ),
            strokeCap: StrokeCap.round,
          ),
          // Centre content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (completed)
                const Icon(Icons.check_circle_outline,
                    color: AppColors.stoicism, size: 32)
              else
                Text(
                  '${(ratio * 100).round()}%',
                  style: AppTypography.displayMedium.copyWith(
                    color: AppColors.stoicism,
                    fontStyle: FontStyle.normal,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                completed ? context.tr.complete : context.tr.progress,
                style: AppTypography.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Challenge card
// ---------------------------------------------------------------------------

class _ChallengeCard extends StatelessWidget {
  final String title;
  final String description;
  final String activeDate;

  const _ChallengeCard({
    required this.title,
    required this.description,
    required this.activeDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date chip
          if (activeDate.isNotEmpty)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.stoicism.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                activeDate,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.stoicism,
                ),
              ),
            ),
          if (activeDate.isNotEmpty) const SizedBox(height: 14),

          // Title
          Text(title, style: AppTypography.displaySmall),
          const SizedBox(height: 10),

          // Description
          Text(
            description,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Action button
// ---------------------------------------------------------------------------

class _ActionButton extends StatelessWidget {
  final bool completed;
  final VoidCallback? onTap;

  const _ActionButton({required this.completed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              completed ? AppColors.stoicism.withOpacity(0.25) : AppColors.stoicism,
          foregroundColor:
              completed ? AppColors.textSecondary : AppColors.background,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          disabledBackgroundColor: AppColors.stoicism.withOpacity(0.25),
          disabledForegroundColor: AppColors.textSecondary,
        ),
        child: Text(
          completed ? context.tr.challengeCompleted : context.tr.completeChallenge,
          style: AppTypography.buttonLabel,
        ),
      ),
    );
  }
}
