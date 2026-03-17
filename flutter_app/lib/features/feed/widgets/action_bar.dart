import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../shared/extensions/context_extensions.dart';

/// Bottom action bar inside a QuoteCard.
///
/// Shows a heart icon, "DOUBLE TAP TO LIKE" hint text, and bookmark + share
/// icon buttons.
class ActionBar extends StatelessWidget {
  const ActionBar({
    super.key,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
    required this.onShare,
  });

  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Heart button
        _ActionIconButton(
          icon: isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? AppColors.like : AppColors.textMuted,
          onTap: onLike,
          semanticsLabel: isLiked ? 'Unlike' : 'Like',
        ),
        const SizedBox(width: 8),
        // Hint text (expands to fill centre)
        Expanded(
          child: Text(
            context.tr.doubleTapToLike.toUpperCase(),
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              letterSpacing: 1.2,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Bookmark button
        _ActionIconButton(
          icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: isSaved ? AppColors.vault : AppColors.textMuted,
          onTap: onSave,
          semanticsLabel: isSaved ? 'Remove from vault' : 'Save to vault',
        ),
        const SizedBox(width: 4),
        // Share button
        _ActionIconButton(
          icon: Icons.ios_share_outlined,
          color: AppColors.textMuted,
          onTap: onShare,
          semanticsLabel: 'Share',
        ),
      ],
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: color),
        ),
      ),
    );
  }
}
