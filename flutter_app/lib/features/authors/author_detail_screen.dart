import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/author_avatar.dart';
import '../../shared/widgets/swipe_back_wrapper.dart';
import '../settings/settings_controller.dart';

/// Author detail screen — shows bio, top quotes, and category distribution.
///
/// Accessed by tapping an author avatar in the feed or vault.
class AuthorDetailScreen extends ConsumerStatefulWidget {
  final String authorName;
  const AuthorDetailScreen({super.key, required this.authorName});

  @override
  ConsumerState<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends ConsumerState<AuthorDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Retry once if first attempt fails (Render cold start)
    for (int attempt = 0; attempt < 2; attempt++) {
      try {
        final api = ref.read(apiClientProvider);
        final lang = ref.read(settingsStateProvider).lang;
        final slug = widget.authorName
            .toLowerCase()
            .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
            .replaceAll(RegExp(r'^_+|_+$'), '');
        final result = await api.get('/authors/$slug', queryParams: {'lang': lang});
        if (mounted) setState(() { _data = result; _loading = false; });
        return;
      } catch (e) {
        debugPrint('[AuthorDetail] Attempt ${attempt + 1} failed for ${widget.authorName}: $e');
        if (attempt == 1) {
          if (mounted) setState(() { _loading = false; });
        }
        // Wait 2s before retry
        await Future.delayed(const Duration(seconds: 2));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwipeBackWrapper(
      child: Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App bar with author name ─────────────────────────────────
          SliverAppBar(
            backgroundColor: AppColors.background,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text(widget.authorName, style: AppTypography.displaySmall),
          ),

          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(
                color: AppColors.stoicism, strokeWidth: 2)),
            )
          else if (_data == null)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        context.tr.authorLoadError,
                        style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          setState(() { _loading = true; _data = null; });
                          _load();
                        },
                        child: Text(context.tr.retry,
                            style: const TextStyle(color: AppColors.stoicism)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── Avatar ──────────────────────────────────────────
                  Center(
                    child: AuthorAvatar(
                      name: widget.authorName,
                      size: 100,
                      accentColor: AppColors.categoryColor(
                        _data!['dominant_category'] ?? 'philosophy',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Name ────────────────────────────────────────────
                  Center(
                    child: Text(
                      widget.authorName,
                      style: AppTypography.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      context.tr.nQuotes(_data!['total_quotes'] as int? ?? 0),
                      style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Bio ─────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _data!['bio'] ?? '',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.7,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Top Quotes ──────────────────────────────────────
                  Text(
                    context.tr.topQuotes,
                    style: AppTypography.labelSmall.copyWith(
                      letterSpacing: 2,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...(_data!['top_quotes'] as List? ?? []).map<Widget>((q) {
                    final cat = q['category'] ?? 'philosophy';
                    final color = AppColors.categoryColor(cat);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\u201C${q['text']}\u201D',
                              style: AppTypography.quoteText.copyWith(
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                context.tr.categoryLabels[cat] ?? cat,
                                style: AppTypography.caption.copyWith(
                                  color: color,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ]),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
