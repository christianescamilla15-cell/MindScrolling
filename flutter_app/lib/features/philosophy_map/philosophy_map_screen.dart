import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../shared/widgets/premium_gate.dart';
import '../../shared/widgets/radar_chart.dart';
import '../../shared/widgets/swipe_back_wrapper.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'philosophy_map_controller.dart';

class PhilosophyMapScreen extends ConsumerStatefulWidget {
  const PhilosophyMapScreen({super.key});

  @override
  ConsumerState<PhilosophyMapScreen> createState() =>
      _PhilosophyMapScreenState();
}

class _PhilosophyMapScreenState extends ConsumerState<PhilosophyMapScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(philosophyMapControllerProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(philosophyMapStateProvider);

    return SwipeBackWrapper(
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(context.tr.mapTitle, style: AppTypography.displaySmall),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.stoicism,
          indicatorWeight: 2,
          labelColor: AppColors.stoicism,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
          tabs: [
            Tab(text: context.tr.today.toUpperCase()),
            Tab(text: context.tr.evolution.toUpperCase()),
          ],
        ),
      ),
      body: PremiumGate(
        child: SafeArea(
          child: mapState.isLoading && mapState.mapData == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.stoicism,
                    strokeWidth: 2,
                  ),
                )
              : mapState.error != null && mapState.mapData == null
                  ? _ErrorView(
                      message: mapState.error!,
                      onRetry: () => ref
                          .read(philosophyMapControllerProvider.notifier)
                          .load(),
                    )
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _TodayTab(mapState: mapState),
                        _EvolutionTab(
                          mapState: mapState,
                          onSaveSnapshot: _handleSaveSnapshot,
                        ),
                      ],
                    ),
        ),
      ),
    ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tab 1: Today — Radar chart + mental state
// ---------------------------------------------------------------------------

class _TodayTab extends StatelessWidget {
  final PhilosophyMapState mapState;
  const _TodayTab({required this.mapState});

  @override
  Widget build(BuildContext context) {
    final data = mapState.mapData;
    final current = data?.current;
    final total = current?.total ?? 0;

    double pct(double raw) =>
        total > 0 ? ((raw / total) * 100).clamp(0, 100) : 0;

    final stoicism = pct(current?.wisdom ?? 0);
    final philosophy = pct(current?.philosophy ?? 0);
    final discipline = pct(current?.discipline ?? 0);
    final reflection = pct(current?.reflection ?? 0);

    // Determine dominant category
    final scores = {
      'stoicism': stoicism,
      'philosophy': philosophy,
      'discipline': discipline,
      'reflection': reflection,
    };
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final dominant = sorted.first.key;
    final secondary = sorted.length > 1 ? sorted[1].key : dominant;

    final mentalState = _getMentalState(dominant, secondary, context);
    final insight = _getInsight(dominant, context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        children: [
          // ── Mental state label ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.stoicism.withOpacity(0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.stoicism.withOpacity(0.2)),
            ),
            child: Text(
              mentalState,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.stoicism,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // ── Radar chart ─────────────────────────────────────────────────
          RadarChart(
            values: [stoicism, philosophy, discipline, reflection],
            labels: [
              context.tr.stoicism,
              context.tr.philosophy,
              context.tr.discipline,
              context.tr.reflection,
            ],
            colors: [
              AppColors.stoicism,
              AppColors.philosophy,
              AppColors.discipline,
              AppColors.reflection,
            ],
            size: MediaQuery.sizeOf(context).width * 0.72,
          ),

          const SizedBox(height: 32),

          // ── Insight text ────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: AppColors.categoryColor(dominant),
                  size: 24,
                ),
                const SizedBox(height: 12),
                Text(
                  insight,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── Distribution bars (compact) ─────────────────────────────────
          ...sorted.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CompactBar(
                  label: _categoryLabel(e.key, context),
                  value: e.value,
                  color: AppColors.categoryColor(e.key),
                ),
              )),
        ],
      ),
    );
  }

  String _getMentalState(String dom, String sec, BuildContext ctx) {
    final lang = Localizations.localeOf(ctx).languageCode;
    final map = lang == 'es'
        ? {
            'stoicism+philosophy': 'Pensador Resiliente',
            'stoicism+discipline': 'Guerrero Estoico',
            'stoicism+reflection': 'Sabio Interior',
            'philosophy+stoicism': 'Filósofo Sabio',
            'philosophy+discipline': 'Explorador Profundo',
            'philosophy+reflection': 'Mente Contemplativa',
            'discipline+stoicism': 'Líder Disciplinado',
            'discipline+philosophy': 'Estratega Mental',
            'discipline+reflection': 'Realizador Consciente',
            'reflection+stoicism': 'Espíritu Reflexivo',
            'reflection+philosophy': 'Alma Filosófica',
            'reflection+discipline': 'Buscador de Verdad',
          }
        : {
            'stoicism+philosophy': 'Resilient Thinker',
            'stoicism+discipline': 'Stoic Warrior',
            'stoicism+reflection': 'Inner Sage',
            'philosophy+stoicism': 'Wise Philosopher',
            'philosophy+discipline': 'Deep Explorer',
            'philosophy+reflection': 'Contemplative Mind',
            'discipline+stoicism': 'Disciplined Leader',
            'discipline+philosophy': 'Mental Strategist',
            'discipline+reflection': 'Mindful Achiever',
            'reflection+stoicism': 'Reflective Spirit',
            'reflection+philosophy': 'Philosophical Soul',
            'reflection+discipline': 'Truth Seeker',
          };
    return map['$dom+$sec'] ?? (lang == 'es' ? 'Mente Curiosa' : 'Curious Mind');
  }

  String _getInsight(String dominant, BuildContext ctx) {
    final lang = Localizations.localeOf(ctx).languageCode;
    if (lang == 'es') {
      return switch (dominant) {
        'stoicism' => 'Tu mente gravita hacia la resiliencia estoica. Buscas fortaleza interior y virtud en cada reflexión.',
        'philosophy' => 'Te atraen las preguntas filosóficas profundas. Tu curiosidad intelectual guía tu camino.',
        'discipline' => 'Estás enfocado en crecimiento y disciplina. La mejora constante define tu búsqueda.',
        'reflection' => 'Un espíritu reflexivo — miras hacia adentro para encontrar sentido y propósito.',
        _ => 'Tu mapa filosófico se está formando con cada interacción.',
      };
    }
    return switch (dominant) {
      'stoicism' => 'Your mind gravitates toward Stoic resilience. You seek inner strength and virtue in every reflection.',
      'philosophy' => 'You\'re drawn to deep philosophical questions. Intellectual curiosity guides your path.',
      'discipline' => 'You\'re focused on growth and discipline. Constant improvement defines your pursuit.',
      'reflection' => 'A reflective spirit — you look inward to find meaning and purpose.',
      _ => 'Your philosophical map is forming with each interaction.',
    };
  }

  String _categoryLabel(String key, BuildContext ctx) {
    return switch (key) {
      'stoicism' => ctx.tr.stoicism,
      'philosophy' => ctx.tr.philosophy,
      'discipline' => ctx.tr.discipline,
      'reflection' => ctx.tr.reflection,
      _ => key,
    };
  }
}

// ---------------------------------------------------------------------------
// Tab 2: Evolution — bars + snapshot comparison + save
// ---------------------------------------------------------------------------

class _EvolutionTab extends StatelessWidget {
  final PhilosophyMapState mapState;
  final VoidCallback onSaveSnapshot;

  const _EvolutionTab({
    required this.mapState,
    required this.onSaveSnapshot,
  });

  @override
  Widget build(BuildContext context) {
    final data = mapState.mapData;
    final current = data?.current;
    final total = current?.total ?? 0;

    double pct(double raw) =>
        total > 0 ? ((raw / total) * 100).clamp(0, 100) : 0;

    final snap = data?.snapshot;
    final snapTotal = snap?.total ?? 0;
    double? snapPct(double? raw) {
      if (snap == null || raw == null) return null;
      return snapTotal > 0 ? ((raw / snapTotal) * 100).clamp(0, 100) : 0;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr.mapSubtitle,
            style: AppTypography.bodySmall,
          ),
          const SizedBox(height: 28),

          // Score bars
          _ScoreBar(
            label: context.tr.stoicism,
            score: pct(current?.wisdom ?? 0),
            color: AppColors.stoicism,
            previousScore: snapPct(snap?.wisdom),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.philosophy,
            score: pct(current?.philosophy ?? 0),
            color: AppColors.philosophy,
            previousScore: snapPct(snap?.philosophy),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.discipline,
            score: pct(current?.discipline ?? 0),
            color: AppColors.discipline,
            previousScore: snapPct(snap?.discipline),
          ),
          const SizedBox(height: 20),
          _ScoreBar(
            label: context.tr.reflection,
            score: pct(current?.reflection ?? 0),
            color: AppColors.reflection,
            previousScore: snapPct(snap?.reflection),
          ),

          if (data?.snapshotDate != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.history, size: 14, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  '${context.tr.comparedTo}: ${data!.snapshotDate}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],

          const SizedBox(height: 36),

          // Save snapshot button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: mapState.isLoading ? null : onSaveSnapshot,
              icon: const Icon(Icons.camera_alt_outlined, size: 18),
              label: Text(context.tr.saveSnapshot),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.stoicism.withOpacity(0.15),
                foregroundColor: AppColors.stoicism,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: AppColors.stoicism.withOpacity(0.3)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact bar (for Today tab)
// ---------------------------------------------------------------------------

class _CompactBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _CompactBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: color),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (value / 100).clamp(0, 1),
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 36,
          child: Text(
            '${value.round()}%',
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Score bar (for Evolution tab)
// ---------------------------------------------------------------------------

class _ScoreBar extends StatelessWidget {
  final String label;
  final double score;
  final Color color;
  final double? previousScore;

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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w500,
            )),
            Row(
              children: [
                if (hasDiff && diff != 0) ...[
                  Icon(
                    diff > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: diff > 0 ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${diff.abs()}',
                    style: AppTypography.caption.copyWith(
                      color: diff > 0 ? const Color(0xFF4ADE80) : const Color(0xFFFF6B6B),
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
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
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
// Error view
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
            const Icon(Icons.error_outline, color: AppColors.textMuted, size: 40),
            const SizedBox(height: 16),
            Text(message, style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(context.tr.retry),
            ),
          ],
        ),
      ),
    );
  }
}
