import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/quote_model.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/author_avatar.dart';
import '../../shared/widgets/swipe_back_wrapper.dart';
import '../share_export/share_export_service.dart';
import 'vault_controller.dart';

/// Bottom-sheet style screen displaying the user's saved quotes.
///
/// Use [showModalBottomSheet] with `isScrollControlled: true` for full
/// bottom-sheet behaviour, or mount as a route via GoRouter.
class VaultScreen extends ConsumerStatefulWidget {
  final VoidCallback? onClose;
  final void Function(String quoteId)? onRemove;

  const VaultScreen({
    super.key,
    this.onClose,
    this.onRemove,
  });

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(vaultControllerProvider.notifier);
      notifier.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultStateProvider);

    return SwipeBackWrapper(
      child: Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C22),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ----------------------------------------------------------------
          // Drag handle
          // ----------------------------------------------------------------
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ----------------------------------------------------------------
          // Header
          // ----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(context.tr.vault, style: AppTypography.displayMedium),
                const SizedBox(width: 10),
                _CountBadge(count: vaultState.items.length),
                const Spacer(),
                // Export button
                if (vaultState.items.isNotEmpty)
                  GestureDetector(
                    onTap: () => _exportVault(context, vaultState.items),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.file_download_outlined,
                          size: 22, color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),

          // ----------------------------------------------------------------
          // Body
          // ----------------------------------------------------------------
          Flexible(
            child: vaultState.isLoading
                ? const _LoadingView()
                : vaultState.items.isEmpty
                    ? const _EmptyView()
                    : _QuoteList(
                        items: vaultState.items,
                        onRemove: _handleRemove,
                      ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    ),
    );
  }

  void _exportVault(BuildContext context, List<QuoteModel> items) {
    final buffer = StringBuffer();
    final tr = context.tr;
    buffer.writeln('MindScrolling — ${tr.myVault}');
    buffer.writeln('=' * 40);
    buffer.writeln();
    for (final q in items) {
      buffer.writeln('\u201C${q.text}\u201D');
      buffer.writeln('\u2014 ${q.author} [${q.category}]');
      buffer.writeln();
    }
    buffer.writeln('---');
    buffer.writeln(tr.exportedFrom);
    Share.share(buffer.toString(), subject: 'MindScrolling ${tr.vault}');
  }

  void _handleRemove(String quoteId) {
    ref.read(vaultControllerProvider.notifier).remove(quoteId);
    widget.onRemove?.call(quoteId);
  }
}

// ---------------------------------------------------------------------------
// Count badge
// ---------------------------------------------------------------------------

class _CountBadge extends StatelessWidget {
  final int count;
  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.vault.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$count',
        style: AppTypography.labelSmall.copyWith(color: AppColors.vault),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading state
// ---------------------------------------------------------------------------

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.vault,
          strokeWidth: 2,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 48,
              color: AppColors.vault.withOpacity(0.4),
            ),
            const SizedBox(height: 16),
            Text(
              context.tr.emptyVaultMsg,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Scrollable list
// ---------------------------------------------------------------------------

class _QuoteList extends StatelessWidget {
  final List<QuoteModel> items;
  final void Function(String quoteId) onRemove;

  const _QuoteList({required this.items, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final quote = items[index];
        return Dismissible(
          key: ValueKey(quote.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => onRemove(quote.id),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B6B)),
          ),
          child: _VaultQuoteItem(quote: quote, onRemove: onRemove),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Individual vault item
// ---------------------------------------------------------------------------

class _VaultQuoteItem extends StatelessWidget {
  final QuoteModel quote;
  final void Function(String quoteId) onRemove;

  const _VaultQuoteItem({required this.quote, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final accentColor = AppColors.categoryColor(quote.category);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left border accent
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accentColor, accentColor.withOpacity(0.3)],
                ),
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote text
                    Text(
                      '\u201C${quote.text}\u201D',
                      style: AppTypography.quoteText.copyWith(
                        fontSize: 15,
                        height: 1.55,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),

                    // Author row + actions
                    Row(
                      children: [
                        AuthorAvatar(
                          name: quote.author,
                          size: 24,
                          accentColor: accentColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            quote.author,
                            style: AppTypography.authorText.copyWith(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        _CategoryChip(label: quote.category, color: accentColor),
                        const SizedBox(width: 8),
                        // Share button
                        GestureDetector(
                          onTap: () => ShareExportService.exportQuoteAsImage(context, quote),
                          child: const Icon(
                            Icons.ios_share_rounded,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  String _localize(String cat, BuildContext context) {
    final tr = context.tr;
    return switch (cat.toLowerCase()) {
      'stoicism'   => tr.stoicism,
      'philosophy' => tr.philosophy,
      'discipline' => tr.discipline,
      'reflection' => tr.reflection,
      _            => cat,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _localize(label, context).toLowerCase(),
        style: AppTypography.labelSmall.copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }
}
