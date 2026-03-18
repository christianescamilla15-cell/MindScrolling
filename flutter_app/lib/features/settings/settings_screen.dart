import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/notification_service.dart';
import '../../shared/extensions/context_extensions.dart';
import '../premium/premium_controller.dart';
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
        title: Text(context.tr.settings, style: AppTypography.displaySmall),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: [
            // ── Section: Language ──────────────────────────────────────────
            _SectionHeader(title: context.tr.language),
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
            _SectionHeader(title: context.tr.navigateTo),
            _SettingsCard(
              children: [
                _NavTile(
                  icon: Icons.map_outlined,
                  label: context.tr.philosophyMap,
                  onTap: () => context.push('/philosophy-map'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.flag_outlined,
                  label: context.tr.dailyChallenge,
                  onTap: () => context.push('/challenges'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.star_border_rounded,
                  label: context.tr.premium,
                  onTap: () => context.push('/premium'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.library_books_outlined,
                  label: context.tr.explorePacks,
                  onTap: () => context.push('/packs'),
                ),
                _Divider(),
                _NavTile(
                  icon: Icons.favorite_border_rounded,
                  label: context.tr.donations,
                  onTap: () => context.push('/donations'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section: Notifications ────────────────────────────────────
            _SectionHeader(title: context.tr.notifications),
            _SettingsCard(
              children: [
                _NotificationTile(),
              ],
            ),
            const SizedBox(height: 24),

            // ── Section: About ─────────────────────────────────────────────
            _SectionHeader(title: context.tr.about),
            _SettingsCard(
              children: [
                const _DevVersionTile(version: '1.1.0'),
                _Divider(),
                _NavTile(
                  icon: Icons.privacy_tip_outlined,
                  label: context.tr.privacyPolicy,
                  onTap: () => _launchPrivacyPolicy(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Section: Reset ─────────────────────────────────────────────
            _SectionHeader(title: context.tr.reset),
            _SettingsCard(
              children: [
                _ActionTile(
                  icon: Icons.restart_alt_rounded,
                  label: context.tr.resetExperience,
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
          SnackBar(
            content: Text(context.tr.couldNotOpenPrivacy),
            backgroundColor: const Color(0xFF1C1C22),
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
          context.tr.resetExperienceTitle,
          style: AppTypography.displaySmall,
        ),
        content: Text(
          context.tr.resetExperienceMsg,
          style: AppTypography.bodySmall,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.tr.cancel,
                style:
                    AppTypography.buttonLabel.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(context.tr.reset,
                style:
                    AppTypography.buttonLabel.copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(settingsControllerProvider.notifier).resetExperience();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr.resetExperienceDone),
            backgroundColor: const Color(0xFF1C1C22),
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
          Text(context.tr.language, style: AppTypography.bodyMedium),
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
// Notification tile
// ---------------------------------------------------------------------------

class _NotificationTile extends StatefulWidget {
  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await NotificationService.isEnabled();
    final time = await NotificationService.getScheduledTime();
    if (mounted) setState(() { _enabled = enabled; _time = time; });
  }

  Future<void> _toggle(bool value) async {
    // Persist and update UI immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mindscroll_notif_enabled', value);
    if (mounted) setState(() => _enabled = value);

    if (value) {
      try {
        await NotificationService.requestPermission();
      } catch (_) {
        // Permission dialog may fail on some devices — continue anyway
      }
      try {
        await NotificationService.scheduleDailyReminder(
          hour: _time.hour,
          minute: _time.minute,
          title: context.tr.dailyReminder,
          body: context.tr.dailyReminderBody,
        );
        await NotificationService.scheduleWeeklyMapReminder(
          title: context.tr.weeklyMapTitle,
          body: context.tr.weeklyMapBody,
        );
      } catch (_) {
        // Scheduling may fail but the preference is saved
      }
    } else {
      try {
        await NotificationService.cancelAll();
      } catch (_) {}
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.stoicism,
            surface: Color(0xFF1C1C28),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _time = picked);
      if (_enabled) {
        await NotificationService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
          title: context.tr.dailyReminder,
          body: context.tr.dailyReminderBody,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Icon(
            _enabled ? Icons.notifications_active : Icons.notifications_outlined,
            color: _enabled ? AppColors.stoicism : AppColors.textMuted,
            size: 22,
          ),
          title: Text(context.tr.dailyReminder, style: AppTypography.bodyMedium),
          subtitle: Text(
            _enabled ? context.tr.notificationsEnabled : context.tr.notificationsDisabled,
            style: AppTypography.bodySmall,
          ),
          trailing: Switch(
            value: _enabled,
            onChanged: _toggle,
            activeColor: AppColors.stoicism,
          ),
        ),
        if (_enabled)
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: const Icon(Icons.access_time, color: AppColors.textMuted, size: 22),
            title: Text(context.tr.reminderTime, style: AppTypography.bodyMedium),
            trailing: GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  _time.format(context),
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.stoicism),
                ),
              ),
            ),
          ),
      ],
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

// ---------------------------------------------------------------------------
// Dev version tile — tap 5× to open dev panel
// ---------------------------------------------------------------------------

class _DevVersionTile extends StatefulWidget {
  final String version;
  const _DevVersionTile({required this.version});

  @override
  State<_DevVersionTile> createState() => _DevVersionTileState();
}

class _DevVersionTileState extends State<_DevVersionTile> {
  int _tapCount = 0;
  DateTime? _lastTap;

  void _onTap() {
    final now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) > const Duration(seconds: 2)) {
      _tapCount = 0;
    }
    _lastTap = now;
    _tapCount++;
    if (_tapCount >= 5) {
      _tapCount = 0;
      _showDevPanel();
    }
  }

  void _showDevPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _DevPremiumSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: const Icon(Icons.info_outline, color: AppColors.textMuted, size: 22),
        title: Text(context.tr.appVersion, style: AppTypography.bodyMedium),
        trailing: Text(widget.version, style: AppTypography.bodySmall),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dev premium state panel (shown after 5 taps on version)
// ---------------------------------------------------------------------------

class _DevPremiumSheet extends ConsumerWidget {
  const _DevPremiumSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ps = ref.watch(premiumStateProvider);
    final controller = ref.read(premiumControllerProvider.notifier);

    String currentLabel;
    Color currentColor;
    if (ps.premiumState.isPremium) {
      currentLabel = 'MindScrolling Inside';
      currentColor = const Color(0xFF8b5cf6);
    } else if (ps.isTrial) {
      currentLabel = 'Free Trial (${ps.trialDaysLeft}d)';
      currentColor = const Color(0xFFf59e0b);
    } else {
      currentLabel = 'Free';
      currentColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('🛠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Dev Tools', style: AppTypography.displaySmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: currentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: currentColor.withOpacity(0.4)),
                ),
                child: Text(
                  currentLabel,
                  style: AppTypography.labelSmall.copyWith(color: currentColor, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Override local — no modifica la DB. Tap versión 5× para abrir.',
            style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: 20),
          _DevStateButton(
            icon: '🔒',
            label: 'Free',
            subtitle: 'Sin premium, trial expirado',
            color: Colors.grey,
            onTap: () { Navigator.pop(context); controller.devSetState('free'); },
          ),
          const SizedBox(height: 10),
          _DevStateButton(
            icon: '⏳',
            label: 'Free Trial — 6 días',
            subtitle: 'Trial activo, sin pago',
            color: const Color(0xFFf59e0b),
            onTap: () { Navigator.pop(context); controller.devSetState('trial'); },
          ),
          const SizedBox(height: 10),
          _DevStateButton(
            icon: '✦',
            label: 'MindScrolling Inside',
            subtitle: 'Premium completo activado',
            color: const Color(0xFF8b5cf6),
            onTap: () { Navigator.pop(context); controller.devSetState('premium'); },
          ),
          const SizedBox(height: 10),
          _DevStateButton(
            icon: '↩',
            label: 'Reset — usar backend real',
            subtitle: 'Elimina el override y recarga desde servidor',
            color: Colors.redAccent,
            onTap: () { Navigator.pop(context); controller.devSetState('reset'); },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _DevStateButton extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DevStateButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.07),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTypography.bodyMedium.copyWith(color: color, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textMuted)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }
}
