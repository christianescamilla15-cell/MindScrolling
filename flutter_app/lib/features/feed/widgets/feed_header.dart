import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';
import '../../ambient/ambient_audio_button.dart';
import '../../premium/premium_controller.dart';

const kFreeSwipeLimit = 20;

class FeedHeader extends ConsumerWidget {
  const FeedHeader({
    super.key,
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
    final remaining = (kFreeSwipeLimit - reflections).clamp(0, kFreeSwipeLimit);

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
            FreeSwipeChip(remaining: remaining),
            const SizedBox(width: 8),
          ],
          // Reflection count
          StatChip(
            icon: Icons.auto_stories_outlined,
            value: reflections.toString(),
            color: AppColors.philosophy,
          ),
          const SizedBox(width: 8),
          // Streak
          AnimatedScale(
            scale: streakPulse ? 1.25 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: StatChip(
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

class FreeSwipeChip extends StatelessWidget {
  const FreeSwipeChip({super.key, required this.remaining});
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
              '$remaining/$kFreeSwipeLimit',
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

class StatChip extends StatelessWidget {
  const StatChip({
    super.key,
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
