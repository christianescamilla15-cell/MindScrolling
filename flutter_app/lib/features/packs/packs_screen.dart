import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/providers/core_providers.dart';
import '../../shared/extensions/context_extensions.dart';
import '../../shared/widgets/premium_gate.dart';
import '../premium/premium_controller.dart';

/// Explore premium content packs.
class PacksScreen extends ConsumerStatefulWidget {
  const PacksScreen({super.key});

  @override
  ConsumerState<PacksScreen> createState() => _PacksScreenState();
}

class _PacksScreenState extends ConsumerState<PacksScreen> {
  List<Map<String, dynamic>>? _packs;
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
      final response = await api.get('/packs');
      final list = (response['packs'] as List?)?.cast<Map<String, dynamic>>();
      if (mounted) setState(() { _packs = list; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _loading = false; });
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/feed'),
        ),
        title: Text(tr.premiumPacks, style: AppTypography.displaySmall),
      ),
      body: PremiumGate(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: AppColors.stoicism, strokeWidth: 2))
            : _error != null
                ? Center(
                    child: Text(_error!,
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.textMuted)))
                : _packs == null || _packs!.isEmpty
                    ? Center(
                        child: Text(tr.noPacks,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.textMuted)))
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: _packs!.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) =>
                            _PackCard(pack: _packs![index]),
                      ),
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final Map<String, dynamic> pack;

  const _PackCard({required this.pack});

  @override
  Widget build(BuildContext context) {
    final color = _parseColor(pack['color'] as String? ?? '#14B8A6');
    final name = pack['name'] as String? ?? '';
    final description = pack['description'] as String? ?? '';
    final quoteCount = pack['quote_count'] as int? ?? 0;
    final icon = _mapIcon(pack['icon'] as String? ?? 'auto_awesome');

    return Container(
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
                    Text('$quoteCount quotes',
                        style: AppTypography.caption
                            .copyWith(color: color.withOpacity(0.7))),
                  ],
                ),
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
          const SizedBox(height: 16),
          // Included badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'MindScrolling Inside',
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  IconData _mapIcon(String name) {
    switch (name) {
      case 'shield':
        return Icons.shield_outlined;
      case 'psychology':
        return Icons.psychology_outlined;
      case 'self_improvement':
        return Icons.self_improvement_outlined;
      default:
        return Icons.auto_awesome_outlined;
    }
  }
}
