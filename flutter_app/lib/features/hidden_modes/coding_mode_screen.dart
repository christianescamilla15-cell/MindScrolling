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

/// Coding mode screen — 4 branches + practice console.
class CodingModeScreen extends ConsumerStatefulWidget {
  const CodingModeScreen({super.key});

  @override
  ConsumerState<CodingModeScreen> createState() => _CodingModeScreenState();
}

class _CodingModeScreenState extends ConsumerState<CodingModeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _selectedBranch = ContentConstants.frontend;
  static const _branchMeta = <String, _BranchInfo>{
    ContentConstants.frontend: _BranchInfo(
      icon: Icons.web,
      color: Color(0xFF3B82F6),
      labelEn: 'Frontend',
      labelEs: 'Frontend',
    ),
    ContentConstants.backend: _BranchInfo(
      icon: Icons.dns,
      color: Color(0xFF10B981),
      labelEn: 'Backend',
      labelEs: 'Backend',
    ),
    ContentConstants.fundamentals: _BranchInfo(
      icon: Icons.account_tree,
      color: Color(0xFFF59E0B),
      labelEn: 'Fundamentals',
      labelEs: 'Fundamentos',
    ),
    ContentConstants.devopsTools: _BranchInfo(
      icon: Icons.terminal,
      color: Color(0xFF8B5CF6),
      labelEn: 'DevOps & Tools',
      labelEs: 'DevOps y Herramientas',
    ),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hiddenState = ref.watch(hiddenModeControllerProvider);
    final lang = ref.watch(settingsStateProvider).lang;

    if (hiddenState.isLoaded && !hiddenState.codingUnlocked) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go('/quiz/coding');
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.go('/feed'),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.code, color: Color(0xFF10B981), size: 22),
            const SizedBox(width: 8),
            Text(
              lang == 'es' ? 'Modo Programación' : 'Coding Mode',
              style: AppTypography.displaySmall,
            ),
          ],
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF10B981),
          labelColor: const Color(0xFF10B981),
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(text: lang == 'es' ? 'Aprender' : 'Learn'),
            Tab(text: lang == 'es' ? 'Practicar' : 'Practice'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Learn tab — branch selector + feed
          Column(
            children: [
              const SizedBox(height: 8),
              // Branch selector
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: ContentConstants.codingBranches.map((branch) {
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
              Expanded(
                child: HiddenModeFeed(
                  key: ValueKey('coding_$_selectedBranch'),
                  contentType: ContentConstants.coding,
                  subCategory: _selectedBranch,
                  accentColor: _branchMeta[_selectedBranch]!.color,
                ),
              ),
            ],
          ),

          // Practice tab — launches the full Practice Console screen
          _PracticeTabEntry(lang: lang),
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

/// Entry point shown in the Practice tab — navigates to the full
/// Practice Console screen at /practice.
class _PracticeTabEntry extends StatelessWidget {
  const _PracticeTabEntry({required this.lang});

  final String lang;

  @override
  Widget build(BuildContext context) {
    final isEs = lang == 'es';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.terminal,
              color: Color(0xFF10B981),
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            isEs ? 'Consola de Práctica' : 'Practice Console',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isEs
                ? 'Resuelve ejercicios de programación con pistas y retroalimentación en tiempo real.'
                : 'Solve coding exercises with hints and real-time feedback.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => context.push('/practice'),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEs ? 'Abrir consola' : 'Open Console',
                    style: AppTypography.buttonLabel.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
