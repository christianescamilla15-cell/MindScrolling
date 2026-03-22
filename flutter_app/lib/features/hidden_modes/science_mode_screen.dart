import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/content_constants.dart';
import '../../shared/extensions/context_extensions.dart';
import '../settings/settings_controller.dart';
import 'hidden_mode_controller.dart';
import 'hidden_mode_feed.dart';

/// Science mode screen — 4 branches of scientific knowledge.
///
/// Reuses the feed visual paradigm but adapted for science content.
/// Requires quiz unlock (HiddenModeController.scienceUnlocked).
class ScienceModeScreen extends ConsumerStatefulWidget {
  const ScienceModeScreen({super.key});

  @override
  ConsumerState<ScienceModeScreen> createState() => _ScienceModeScreenState();
}

class _ScienceModeScreenState extends ConsumerState<ScienceModeScreen> {
  String _selectedBranch = ContentConstants.scienceGeneral;

  static const _branchMeta = <String, _BranchInfo>{
    ContentConstants.scienceGeneral: _BranchInfo(
      icon: Icons.science_outlined,
      color: Color(0xFF3B82F6),
      labelEn: 'General Science',
      labelEs: 'Ciencia General',
    ),
    ContentConstants.physics: _BranchInfo(
      icon: Icons.bolt,
      color: Color(0xFFF59E0B),
      labelEn: 'Physics',
      labelEs: 'Física',
    ),
    ContentConstants.mathematics: _BranchInfo(
      icon: Icons.functions,
      color: Color(0xFF8B5CF6),
      labelEn: 'Mathematics',
      labelEs: 'Matemáticas',
    ),
    ContentConstants.technology: _BranchInfo(
      icon: Icons.memory,
      color: Color(0xFF10B981),
      labelEn: 'Technology',
      labelEs: 'Tecnología',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final hiddenState = ref.watch(hiddenModeControllerProvider);
    final lang = ref.watch(settingsStateProvider).lang;

    // Redirect if not unlocked
    if (hiddenState.isLoaded && !hiddenState.scienceUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/quiz/science');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/feed'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.science_outlined, color: Color(0xFF3B82F6), size: 22),
            const SizedBox(width: 8),
            Text(
              lang == 'es' ? 'Modo Ciencia' : 'Science Mode',
              style: AppTypography.displaySmall,
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Branch selector
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: ContentConstants.scienceBranches.map((branch) {
                final meta = _branchMeta[branch]!;
                final isSelected = _selectedBranch == branch;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedBranch = branch),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? meta.color.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: isSelected ? meta.color : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(meta.icon, size: 16, color: isSelected ? meta.color : AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(
                            lang == 'es' ? meta.labelEs : meta.labelEn,
                            style: AppTypography.labelSmall.copyWith(
                              color: isSelected ? meta.color : AppColors.textMuted,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Content feed for the selected branch
          Expanded(
            child: HiddenModeFeed(
              key: ValueKey('science_$_selectedBranch'),
              contentType: ContentConstants.science,
              subCategory: _selectedBranch,
              accentColor: _branchMeta[_selectedBranch]!.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _BranchInfo {
  final IconData icon;
  final Color color;
  final String labelEn;
  final String labelEs;

  const _BranchInfo({
    required this.icon,
    required this.color,
    required this.labelEn,
    required this.labelEs,
  });
}
