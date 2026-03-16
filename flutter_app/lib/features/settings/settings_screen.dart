import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/app_constants.dart';
import 'settings_controller.dart';

// Teal accent used throughout the settings screen.
const Color _accent = Color(0xFF14B8A6);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: AppColors.textSecondary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/feed'),
        ),
        title: Text('Settings', style: AppTypography.displaySmall),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ── Section: Language ──────────────────────────────────────────
            _SectionHeader(title: 'Language'),
            _SettingsCard(
              children: [
                _LanguageToggle(
                  currentLang: settingsState.lang,
                  onChanged: (lang) =>
                      ref.read(settingsControllerProvider.notifier).setLang(lang),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section: Navigate to ───────────────────────────────────────
            _SectionHeader(title: 'Navigate to'),
            _SettingsCard(
              children: [
                _NavTile(
                  icon: Icons.map_outlined,
                  label: 'Philosophy Map',
                  onTap: () => context.push('/philosophy-map'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.flag_outlined,
                  label: 'Daily Challenge',
                  onTap: () => context.push('/challenges'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.star_border_rounded,
                  label: 'Premium',
                  onTap: () => context.push('/premium'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.favorite_border_rounded,
                  label: 'Donations',
                  onTap: () => context.push('/donations'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section: About ─────────────────────────────────────────────
            _SectionHeader(title: 'About'),
            _SettingsCard(
              children: [
                _InfoTile(
                  icon: Icons.info_outline,
                  label: 'App Version',
                  trailing: Text(
                    '1.0.0',
                    style: AppTypography.bodySmall,
                  ),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Policy',
                  onTap: () => _launchPrivacyPolicy(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section: Reset ─────────────────────────────────────────────
            _SectionHeader(title: 'Reset'),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.restart_alt_rounded,
                  label: 'Reset Onboarding',
                  color: Colors.redAccent,
                  onTap: () => _confirmResetOnboarding(context, ref),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Future<void> _launchPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse('https://mindscroll.app/privacy');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open privacy policy'),
            backgroundColor: Color(0xFF1C1C22),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _confirmResetOnboarding(
      BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          'Reset Onboarding?',
          style: AppTypography.displaySmall,
        ),
        content: Text(
          'The onboarding flow will be shown again on the next app restart.',
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style:
                    AppTypography.buttonLabel.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Reset',
                style:
                    AppTypography.buttonLabel.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(settingsControllerProvider.notifier).resetOnboarding();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Onboarding reset. Restart the app to re-run it.'),
            backgroundColor: Color(0xFF1C1C22),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Language toggle
// ---------------------------------------------------------------------------

class _LanguageToggle extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const _LanguageToggle({
    required this.currentLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: const Icon(Icons.language, color: _accent, size: 22),
      title:
          Text('Language', style: AppTypography.bodyMedium),
      trailing: _LangToggleButtons(
        currentLang: currentLang,
        onChanged: onChanged,
      ),
    );
  }
}

class _LangToggleButtons extends StatelessWidget {
  final String currentLang;
  final ValueChanged<String> onChanged;

  const _LangToggleButtons({
    required this.currentLang,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: AppConstants.supportedLangs.map((lang) {
        final isSelected = lang == currentLang;
        return GestureDetector(
          onTap: () => onChanged(lang),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? _accent.withOpacity(0.18) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? _accent : AppColors.borderStrong,
                width: 1.2,
              ),
            ),
            child: Text(
              lang.toUpperCase(),
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? _accent : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation tile
// ---------------------------------------------------------------------------

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: _accent, size: 22),
      title: Text(label, style: AppTypography.bodyMedium),
      trailing: const Icon(Icons.chevron_right,
          color: AppColors.textMuted, size: 20),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Info tile (no tap)
// ---------------------------------------------------------------------------

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;

  const _InfoTile({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: AppColors.textMuted, size: 22),
      title: Text(label, style: AppTypography.bodyMedium),
      trailing: trailing,
    );
  }
}

// ---------------------------------------------------------------------------
// Destructive action tile
// ---------------------------------------------------------------------------

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(color: color),
      ),
      onTap: onTap,
    );
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          color: _accent,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card container
// ---------------------------------------------------------------------------

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Thin divider
// ---------------------------------------------------------------------------

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.border,
      indent: 52,
      endIndent: 0,
    );
  }
}
