import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'philosophy_map_controller.dart';

// Category accent colors as specified (map-specific palette distinct from
// the global AppColors category accents used in the feed).
const Color _stoicismColor = Color(0xFF6B8F71);
const Color _philosophyColor = Color(0xFF7B9BB8);
const Color _disciplineColor = Color(0xFFC17F24);
const Color _reflectionColor = Color(0xFF9B6B8F);

class PhilosophyMapScreen extends ConsumerStatefulWidget {
  const PhilosophyMapScreen({super.key});

  @override
  ConsumerState<PhilosophyMapScreen> createState() =>
      _PhilosophyMapScreenState();
}

class _PhilosophyMapScreenState extends ConsumerState<PhilosophyMapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(philosophyMapControllerProvider.notifier).load();
    });
  }

  Future<void> _handleSaveSnapshot() async {
    await ref.read(philosophyMapControllerProvider.notifier).saveSnapshot();
    if (!mounted) return;
    final s = ref.read(philosophyMapStateProvider);
    if (s.snapshotSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr.snapshotSaved),
          backgroundColor: const Color(0xFF1C1C22),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (s.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${context.tr.snapshotError}: ${s.error}'),
          backgroundColor: Colors.red.shade900,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(philosophyMapStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/feed'),
        ),
        title: Text(
          context.tr.mapTitle,
          style: AppTypography.displaySmall,
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: mapState.isLoading && mapState.mapData == null
            ? const _LoadingView()
            : mapState.error != null && mapState.mapData == null
                ? _ErrorView(
                    message: mapState.error!,
                    onRetry: () =>
                        ref.read(philosophyMapControllerProvider.notifier).load(),
                  )
                : _MapBody(
                    mapState: mapState,
                    onSaveSnapshot: _handleSaveSnapshot,
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Main body
// ---------------------------------------------------------------------------

class _MapBody extends StatelessWidget {
  final PhilosophyMapState mapState;
  final VoidCallback onSaveSnapshot;

  const _MapBody({
    required this.mapState,
    required this.onSaveSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    final data = mapState.mapData;
    final current = data?.current;

    // Compute 0–100 scores for each category.
    final total = current?.total ?? 0;
    double _pct(double raw) =>
        total > 0 ? ((raw / total) * 100).clamp(0, 100) : 0;

    final stoicismPct = _pct(current?.wisdom ?? 0);
    final philosophyPct = _pct(current?.philosophy ?? 0);
    final disciplinePct = _pct(current?.discipline ?? 0);
    final reflectionPct = _pct(current?.reflection ?? 0);

    // Snapshot comparison values (null when no snapshot available).
    final snap = data?.snapshot;
    final snapTotal = snap?.total ?? 0;
    double? _snapPct(double? raw) {
      if (snap == null || raw == null) return null;
      return snapTotal > 0 ? ((raw / snapTotal) * 100).clamp(0, 100) : 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Subtitle ────────────────────────────────────────────────────
          Text(
            context.tr.mapSubtitle,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 28),

          // ── Score bars ──────────────────────────────────────────────────
          _ScoreBar(
            label: context.tr.stoicism,
            score: stoicismPct,
            color: _stoicismColor,
            previousScore: _snapPct(snap?.wisdom),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.philosophy,
            score: philosophyPct,
            color: _philosophyColor,
            previousScore: _snapPct(snap?.philosophy),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.discipline,
            score: disciplinePct,
            color: _disciplineColor,
            previousScore: _snapPct(snap?.discipline),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.reflection,
            score: reflectionPct,
            color: _reflectionColor,
            previousScore: _snapPct(snap?.reflection),
          ),

          // ── Snapshot comparison note ─────────────────────────────────
          if (data?.snapshotDate != null) ...[
            const SizedBox(height: 24),
            _SnapshotNote(snapshotDate: data!.snapshotDate!),
          ],

          const SizedBox(height: 36),

          // ── Save Snapshot button ──────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: _SaveSnapshotButton(
              isLoading: mapState.isLoading,
              onPressed: onSaveSnapshot,
            ),
          ),

          if (mapState.error != null) ...[
            const SizedBox(height: 12),
            Text(
              mapState.error!,
              style: AppTypography.caption.copyWith(color: Colors.red.shade300),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Score bar
// ---------------------------------------------------------------------------

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score; // 0–100
  final Color color;
  final double? previousScore; // null if no snapshot

  const _ScoreBar({
    required this.label,
    required this.score,
    required this.color,
    this.previousScore,
  });

  @override
  Widget build(BuildContext context) {
    final scoreInt = score.round();
    final hasDiff = previousScore != null;
    final diff = hasDiff ? (score - previousScore!).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                if (hasDiff && diff != 0) ...[
                  Icon(
                    diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: diff > 0 ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${diff.abs()}',
                    style: AppTypography.caption.copyWith(
                      color:
                          diff > 0 ? Colors.greenAccent : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  '$scoreInt',
                  style: AppTypography.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Track
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // Background track
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Previous score marker (ghost bar)
              if (hasDiff && previousScore! > 0)
                FractionallySizedBox(
                  widthFactor: (previousScore! / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              // Current score fill
              AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                widthFactor: (score / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Snapshot note
// ---------------------------------------------------------------------------

class _SnapshotNote extends StatelessWidget {
  final String snapshotDate;
  const _SnapshotNote({required this.snapshotDate});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.history, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(
          'Comparing to snapshot: $snapshotDate',
          style: AppTypography.caption,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Save Snapshot button
// ---------------------------------------------------------------------------

class _SaveSnapshotButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _SaveSnapshotButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading ? 0.6 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF6B8F71).withOpacity(0.15),
          foregroundColor: const Color(0xFF6B8F71),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFF6B8F71), width: 1),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6B8F71),
                ),
              )
            : Text(
                context.tr.saveSnapshot,
                style: AppTypography.buttonLabel,
              ),
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
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF6B8F71),
        strokeWidth: 2,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.textMuted, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.vault,
              ),
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }
}
