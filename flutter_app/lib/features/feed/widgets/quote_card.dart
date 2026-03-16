import 'package:flutter/material.dart';

import '../../../app/theme/colors.dart';
import '../../../app/theme/typography.dart';
import '../../../data/models/quote_model.dart';
import 'action_bar.dart';
import 'category_badge.dart';

/// Main quote card shown in the feed swiper.
///
/// Displays the quote text, author, category badge, and action bar.
/// [onExport] is null for free users (button hidden), non-null for premium.
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
  });

  final QuoteModel quote;
  final bool isLiked;
  final bool isSaved;
  final VoidCallback onLike;
  final VoidCallback onSave;
  final VoidCallback onShare;
  final VoidCallback? onExport;

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);

    return GestureDetector(
      onDoubleTap: onLike,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1C1C28), Color(0xFF14141E)],
          ),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.12),
              blurRadius: 32,
              spreadRadius: -4,
              offset: const Offset(0, 8),
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
                child: Container(color: accentColor),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category badge
                    CategoryBadge(category: quote.category),
                    const Spacer(flex: 2),
                    // Quote text
                    Text(
                      '\u201C${quote.text}\u201D',
                      style: AppTypography.quoteText.copyWith(
                        fontSize: _adaptiveFontSize(quote.text.length),
                        height: 1.5,
                      ),
                    ),
                    const Spacer(flex: 1),
                    // Author
                    Text(
                      '\u2014 ${quote.author}',
                      style: AppTypography.authorText,
                    ),
                    const SizedBox(height: 28),
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
                        if (onExport != null) ...[
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: onExport,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
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
    if (charCount < 80) return 26;
    if (charCount < 160) return 22;
    if (charCount < 280) return 19;
    return 17;
  }
}
