import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/quote_model.dart';
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

    return Container(
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
                Text('Vault', style: AppTypography.displayMedium),
                const SizedBox(width: 10),
                _CountBadge(count: vaultState.items.length),
                const Spacer(),
                _CloseButton(
                  onTap: widget.onClose ?? () => Navigator.of(context).pop(),
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
    );
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
// Close button
// ---------------------------------------------------------------------------

class _CloseButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CloseButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.close, size: 18, color: AppColors.textSecondary),
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
        child: Text(
          '🔮 Save quotes to build your vault',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
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
        return _VaultQuoteItem(quote: quote, onRemove: onRemove);
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Colored left border accent (4 px)
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quote text (italic)
                    Text(
                      '"${quote.text}"',
                      style: AppTypography.quoteText.copyWith(
                        fontSize: 14,
                        height: 1.5,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Author + category chip
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '— ${quote.author}',
                            style: AppTypography.authorText,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _CategoryChip(
                          label: quote.category,
                          color: accentColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Remove (×) button
            GestureDetector(
              onTap: () => onRemove(quote.id),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Center(
                  child: Icon(Icons.close, size: 16, color: AppColors.textMuted),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toLowerCase(),
        style: AppTypography.labelSmall.copyWith(color: color, letterSpacing: 0.5),
      ),
    );
  }
}
