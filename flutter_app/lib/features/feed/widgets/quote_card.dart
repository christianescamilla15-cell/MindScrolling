import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/quote_model.dart';
import '../../../shared/widgets/author_avatar.dart';
import 'action_bar.dart';
import 'category_badge.dart';

/// Main quote card shown in the feed swiper.
///
/// Premium, minimalist design inspired by Stoic/Quoto/Headspace.
/// Generous whitespace, serif quote typography, author avatar circle.
class QuoteCard extends StatelessWidget {
  const QuoteCard({
    super.key,
    required this.quote,
    required this.isLiked,
    required this.isSaved,
    required this.onLike,
    required this.onSave,
    required this.onShare,
    this.onExport,
    this.onMoreLikeThis,
  });

  final QuoteModel quote;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onExport;
  final VoidCallback? onMoreLikeThis;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);

    return GestureDetector(
      onDoubleTap: onLike,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C28), Color(0xFF13131B)],
          ),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.10),
              blurRadius: 40,
              spreadRadius: -8,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Category accent bar on the left edge
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 3,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        accentColor.withValues(alpha: 0.8),
                        accentColor.withValues(alpha: 0.2),
                      ],
                    ),
                  ),
                ),
              ),

              // Subtle accent glow top-right
              Positioned(
                top: -60,
                right: -60,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accentColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 28, 32, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Category badge (left-aligned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CategoryBadge(category: quote.category),
                    ),

                    const Spacer(flex: 1),

                    // Author portrait — large, centered
                    GestureDetector(
                      onTap: () => context.push('/author/${Uri.encodeComponent(quote.authorSlug)}'),
                      child: AuthorAvatar(
                        name: quote.author,
                        size: 72,
                        accentColor: accentColor,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Author name centered
                    Text(
                      quote.author,
                      style: AppTypography.labelSmall.copyWith(
                        color: accentColor,
                        letterSpacing: 1.2,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Quote text — premium serif typography
                    Text(
                      '\u201C${quote.text}\u201D',
                      style: AppTypography.quoteText.copyWith(
                        fontSize: _adaptiveFontSize(quote.text.length),
                        height: 1.55,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 1),

                    // Divider
                    Container(
                      width: 40,
                      height: 1,
                      color: accentColor.withValues(alpha: 0.2),
                    ),

                    const SizedBox(height: 20),

                    // Action bar
                    Row(
                      children: [
                        Expanded(
                          child: ActionBar(
                            isLiked: isLiked,
                            isSaved: isSaved,
                            onLike: onLike,
                            onSave: onSave,
                            onShare: onShare,
                          ),
                        ),
                        if (onMoreLikeThis != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onMoreLikeThis,
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.auto_awesome_mosaic,
                                size: 20,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                        if (onExport != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onExport,
                            behavior: HitTestBehavior.opaque,
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Icon(
                                Icons.photo_camera_outlined,
                                size: 22,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _adaptiveFontSize(int charCount) {
    if (charCount < 60) return 28;
    if (charCount < 120) return 24;
    if (charCount < 200) return 21;
    if (charCount < 300) return 18;
    return 16;
  }
}
