import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/extensions/context_extensions.dart';
import '../settings/settings_controller.dart';

// ---------------------------------------------------------------------------
// Pack catalog screen — visible to ALL user tiers (Free, Trial, Inside, Pack owner).
// PremiumGate removed per Block B scope: US-B01.
// ---------------------------------------------------------------------------

class PacksScreen extends ConsumerStatefulWidget {
  const PacksScreen({super.key});

  @override
  ConsumerState<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends ConsumerState<PacksScreen> {
  List<Map<String, dynamic>>? _packs;
  String? _userState;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPacks();
  }

  Future<void> _loadPacks() async {
    try {
      final api = ref.read(apiClientProvider);
      final lang = ref.read(settingsStateProvider).lang;
      final response = await api.get('/packs', queryParams: {'lang': lang});
      final list = (response['packs'] as List?)?.cast<Map<String, dynamic>>();
      // user_state is a root-level field from GET /packs (e.g. 'inside', 'pack_owner', 'free')
      final userState = response['user_state'] as String?;
      if (mounted) {
        setState(() {
          _packs = list;
          _userState = userState;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(tr.premiumPacks, style: AppTypography.displaySmall),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  color: AppColors.stoicism, strokeWidth: 2))
          : _error != null
              ? _ErrorState(
                  message: _error!,
                  onRetry: () {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    _loadPacks();
                  },
                )
              : _packs == null || _packs!.isEmpty
                  ? Center(
                      child: Text(tr.noPacks,
                          style: AppTypography.bodyMedium
                              .copyWith(color: AppColors.textMuted)))
                  : _PackList(packs: _packs!, userState: _userState),
    );
  }
}

// ---------------------------------------------------------------------------
// Pack list
// ---------------------------------------------------------------------------

class _PackList extends StatelessWidget {
  final List<Map<String, dynamic>> packs;
  final String? userState;

  const _PackList({required this.packs, this.userState});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: packs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) =>
          _PackCard(pack: packs[index], userState: userState),
    );
  }
}

// ---------------------------------------------------------------------------
// Single pack card
// ---------------------------------------------------------------------------

class _PackCard extends StatelessWidget {
  final Map<String, dynamic> pack;
  final String? userState;

  const _PackCard({required this.pack, this.userState});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(pack['color'] as String? ?? '#14B8A6');
    final name = pack['name'] as String? ?? '';
    final description = pack['description'] as String? ?? '';
    final quoteCount = (pack['quote_count'] as num?)?.toInt() ?? 0;
    final icon = _mapIcon(pack['icon'] as String? ?? 'auto_awesome');
    final accessStatus = pack['access_status'] as String? ?? 'preview_only';
    final priceUsd = pack['price'] is Map
        ? (pack['price'] as Map)['usd']?.toString() ?? '2.99'
        : pack['price']?.toString() ?? '2.99';
    final packId = pack['id'] as String? ?? '';
    final packColorHex = pack['color'] as String? ?? '#14B8A6';

    // HIGH-02: entitled users skip the preview screen and go straight to the feed.
    final void Function() onTap;
    if (accessStatus == 'unlocked') {
      onTap = () => context.push(
            '/packs/${Uri.encodeComponent(packId)}/feed',
            extra: {'packName': name, 'packColor': packColorHex},
          );
    } else {
      onTap = () => context.push(
            '/packs/${Uri.encodeComponent(packId)}/preview',
            extra: {'packName': name, 'packColor': packColorHex},
          );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: AppTypography.displaySmall
                              .copyWith(color: color, fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(context.tr.nQuotes(quoteCount),
                          style: AppTypography.caption
                              .copyWith(color: color.withOpacity(0.7))),
                    ],
                  ),
                ),
                // Access status badge
                _AccessBadge(
                  accessStatus: accessStatus,
                  userState: userState,
                  priceUsd: priceUsd,
                  color: color,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Description
            Text(description,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                )),
            // Price row — show when not unlocked
            if (accessStatus != 'unlocked') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: color.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    context.tr.packGetFor,
                    style: AppTypography.caption.copyWith(
                      color: color.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '').substring(0, 6);
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return const Color(0xFF14B8A6); // fallback teal
    }
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'shield':
        return Icons.shield_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'self_improvement':
        return Icons.self_improvement_outlined;
      case 'palette':
        return Icons.palette_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'psychology_alt':
        return Icons.psychology_alt_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}

// ---------------------------------------------------------------------------
// Access badge chip
// ---------------------------------------------------------------------------

class _AccessBadge extends StatelessWidget {
  final String accessStatus;
  // userState is the root-level field from GET /packs ('inside', 'pack_owner', 'free', etc.)
  final String? userState;
  final String priceUsd;
  final Color color;

  const _AccessBadge({
    required this.accessStatus,
    required this.userState,
    required this.priceUsd,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tr = context.tr;

    late String label;
    late Color badgeColor;
    late Color bgColor;

    // CRIT-03: combine access_status with user_state to show the correct badge.
    // 'unlocked' + 'inside'     → "Included in Inside"
    // 'unlocked' + anything else → "Unlocked"  (individual pack buyer)
    // 'preview_only'            → "Preview"
    // 'purchasable' / default   → price chip
    switch (accessStatus) {
      case 'unlocked':
        final isInsideUser = userState == 'inside';
        label = isInsideUser ? tr.packIncludedInInside : tr.packUnlocked;
        badgeColor = AppColors.stoicism;
        bgColor = AppColors.stoicism.withOpacity(0.12);
      case 'preview_only':
        label = tr.packPreview;
        badgeColor = AppColors.philosophy;
        bgColor = AppColors.philosophy.withOpacity(0.12);
      case 'purchasable':
      default:
        label = '\$$priceUsd';
        badgeColor = color;
        bgColor = color.withOpacity(0.12);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: badgeColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Error state
// ---------------------------------------------------------------------------

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined,
                color: AppColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onRetry,
              child: Text(context.tr.retry,
                  style: const TextStyle(color: AppColors.stoicism)),
            ),
          ],
        ),
      ),
    );
  }
}
