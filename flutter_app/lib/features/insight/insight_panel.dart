import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/quote_model.dart';
import '../../shared/extensions/context_extensions.dart';
import '../hidden_modes/hidden_mode_controller.dart';
import '../hidden_modes/unlock_suggestion.dart';
import 'insight_controller.dart';

/// Collapsible Insight panel shown at the top of the feed for Inside users.
///
/// Provides an emotional input field and displays a personalized "quote of the day"
/// based on how the user is feeling.
class InsightPanel extends ConsumerStatefulWidget {
  const InsightPanel({super.key, this.onQuoteTap});

  /// Called when the user taps the quote of the day.
  final void Function(QuoteModel quote)? onQuoteTap;

  @override
  ConsumerState<InsightPanel> createState() => _InsightPanelState();
}

class _InsightPanelState extends ConsumerState<InsightPanel>
    with SingleTickerProviderStateMixin {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
      _focusNode.unfocus();
    }
  }

  void _submit() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _focusNode.unfocus();
    ref.read(insightControllerProvider.notifier).submitFeeling(text);
  }

  @override
  Widget build(BuildContext context) {
    final insightState = ref.watch(insightControllerProvider);
    final tr = context.tr;

    // HIGH-02: Use emotional theme for dynamic tinting after submission
    final theme = insightState.emotionalTheme;
    final accentColor = insightState.hasSubmitted ? theme.accent : const Color(0xFF8B5CF6);
    final bgColor = insightState.hasSubmitted ? theme.background : const Color(0xFF1A1A2E);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header (always visible) ──────────────────────────────────
          GestureDetector(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: accentColor, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      insightState.hasSubmitted
                          ? tr.insightYourQuote
                          : tr.insightTitle,
                      style: AppTypography.labelSmall.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable content ──────────────────────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Input field
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D0D1A).withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      maxLength: 200,
                      decoration: InputDecoration(
                        hintText: tr.insightHint,
                        hintStyle: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted,
                        ),
                        contentPadding: const EdgeInsets.all(12),
                        border: InputBorder.none,
                        counterText: '',
                        suffixIcon: insightState.isLoading
                            ? Padding(
                                padding: const EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: accentColor,
                                  ),
                                ),
                              )
                            : IconButton(
                                icon: const Icon(Icons.send_rounded, size: 20),
                                color: accentColor,
                                onPressed: _submit,
                              ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                  ),

                  // Detected tags
                  if (insightState.detectedTags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: insightState.detectedTags.take(5).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tag.replaceAll('_', ' '),
                            style: AppTypography.labelSmall.copyWith(
                              color: accentColor,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Quote of the day
                  if (insightState.quoteOfDay != null) ...[
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () => widget.onQuoteTap?.call(insightState.quoteOfDay!),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              accentColor.withValues(alpha: 0.15),
                              const Color(0xFF6366F1).withValues(alpha: 0.08),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '"${insightState.quoteOfDay!.text}"',
                              style: AppTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                height: 1.5,
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '— ${insightState.quoteOfDay!.author}',
                              style: AppTypography.labelSmall.copyWith(
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Hidden mode unlock suggestion
                  if (insightState.detectedHiddenMode != null &&
                      !ref.watch(hiddenModeControllerProvider)
                          .isModeUnlocked(insightState.detectedHiddenMode!)) ...[
                    const SizedBox(height: 10),
                    UnlockSuggestion(
                      mode: insightState.detectedHiddenMode!,
                      onDismiss: () {
                        // Just dismiss — user can trigger again later
                      },
                    ),
                  ],

                  // Refine button
                  if (insightState.hasSubmitted) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        _textController.clear();
                        ref.read(insightControllerProvider.notifier).reset();
                      },
                      child: Text(
                        tr.insightRefine,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
