import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/providers/author_affinity_provider.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/author_avatar.dart';

/// Displays the top 5 authors the user engages with most.
/// Shown at the bottom of the profile screen.
class AuthorAffinityWidget extends ConsumerWidget {
  const AuthorAffinityWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affinityState = ref.watch(authorAffinityProvider);
    final topAuthors = affinityState.topAuthors(limit: 5);
    final tr = context.tr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_outlined,
                  color: AppColors.stoicism, size: 18),
              const SizedBox(width: 8),
              Text(tr.topAuthors, style: AppTypography.authorText),
            ],
          ),
          const SizedBox(height: 16),
          if (topAuthors.isEmpty)
            Text(
              tr.authorAffinityEmpty,
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textMuted),
            )
          else
            Column(
              children: topAuthors.asMap().entries.map((entry) {
                final rank = entry.key + 1;
                final author = entry.value.key;
                final score = entry.value.value;
                return _AuthorAffinityRow(
                  rank: rank,
                  author: author,
                  score: score,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _AuthorAffinityRow extends StatelessWidget {
  const _AuthorAffinityRow({
    required this.rank,
    required this.author,
    required this.score,
  });

  final int rank;
  final String author;
  final int score;

  @override
  Widget build(BuildContext context) {
    // Pick a subtle accent per rank position.
    final rankColors = [
      AppColors.stoicism,
      AppColors.discipline,
      AppColors.reflection,
      AppColors.philosophy,
      AppColors.textMuted,
    ];
    final color = rankColors[(rank - 1).clamp(0, rankColors.length - 1)];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Rank badge
          SizedBox(
            width: 24,
            child: Text(
              '$rank',
              style: AppTypography.labelSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          AuthorAvatar(name: author, size: 36, accentColor: color),
          const SizedBox(width: 12),
          // Name
          Expanded(
            child: Text(
              author,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Score pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Text(
              '$score',
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
