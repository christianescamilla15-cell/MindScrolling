import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../data/models/user_profile_model.dart';
import '../../shared/extensions/context_extensions.dart';
import 'profile_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Editing state mirrors
  String? _ageRange;
  String? _interest;
  String? _goal;
  String _lang = 'en';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(profileControllerProvider.notifier).load();
    });
  }

  void _syncFromProfile(UserProfileModel? profile) {
    if (profile == null) return;
    _ageRange = profile.ageRange;
    _interest = profile.interest;
    _goal = profile.goal;
    _lang = profile.preferredLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final ps = ref.watch(profileStateProvider);

    // Sync local edit state when profile loads
    if (!ps.isEditing && ps.profile != null) {
      _syncFromProfile(ps.profile);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(context.tr.profileTitle),
        actions: [
          if (!ps.isEditing)
            TextButton(
              onPressed: () =>
                  ref.read(profileControllerProvider.notifier).setEditing(true),
              child: Text(
                context.tr.profileEdit,
                style: AppTypography.buttonLabel.copyWith(
                  color: AppColors.stoicism,
                ),
              ),
            ),
        ],
      ),
      body: ps.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.stoicism))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats ──────────────────────────────────────────────
                  _StatsSection(
                    streak: ps.streak,
                    reflections: ps.totalReflections,
                    profile: ps.profile,
                  ),

                  const SizedBox(height: 28),
                  _SectionTitle(context.tr.profileInfo),
                  const SizedBox(height: 12),

                  // ── Age range ──────────────────────────────────────────
                  _FieldLabel(context.tr.ageRange),
                  const SizedBox(height: 6),
                  _ChipSelector(
                    options: UserProfileModel.ageRanges,
                    selected: _ageRange,
                    enabled: ps.isEditing,
                    onChanged: (v) => setState(() => _ageRange = v),
                  ),

                  const SizedBox(height: 16),

                  // ── Interest ───────────────────────────────────────────
                  _FieldLabel(context.tr.interest),
                  const SizedBox(height: 6),
                  _ChipSelector(
                    options: UserProfileModel.interests,
                    selected: _interest,
                    enabled: ps.isEditing,
                    onChanged: (v) => setState(() => _interest = v),
                  ),

                  const SizedBox(height: 16),

                  // ── Goal ───────────────────────────────────────────────
                  _FieldLabel(context.tr.goal),
                  const SizedBox(height: 6),
                  _ChipSelector(
                    options: UserProfileModel.goals,
                    selected: _goal,
                    enabled: ps.isEditing,
                    onChanged: (v) => setState(() => _goal = v),
                  ),

                  const SizedBox(height: 16),

                  // ── Language ───────────────────────────────────────────
                  _FieldLabel(context.tr.language),
                  const SizedBox(height: 6),
                  _ChipSelector(
                    options: const ['en', 'es'],
                    selected: _lang,
                    enabled: ps.isEditing,
                    onChanged: (v) => setState(() => _lang = v ?? 'en'),
                    labelBuilder: (s) => s == 'en' ? 'English' : 'Español',
                  ),

                  const SizedBox(height: 32),

                  // ── Error ──────────────────────────────────────────────
                  if (ps.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        ps.error!,
                        style: AppTypography.bodySmall
                            .copyWith(color: const Color(0xFFFF6B6B)),
                      ),
                    ),

                  // ── Save / Cancel ─────────────────────────────────────
                  if (ps.isEditing) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: ps.isSaving ? null : _save,
                        child: ps.isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : const Text('Save'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          _syncFromProfile(ps.profile);
                          ref
                              .read(profileControllerProvider.notifier)
                              .setEditing(false);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  void _save() {
    final updated = UserProfileModel(
      ageRange: _ageRange,
      interest: _interest,
      goal: _goal,
      preferredLanguage: _lang,
    );
    ref.read(profileControllerProvider.notifier).save(updated);
  }
}

// ---------------------------------------------------------------------------
// Stats section
// ---------------------------------------------------------------------------

class _StatsSection extends StatelessWidget {
  final int streak;
  final int reflections;
  final UserProfileModel? profile;

  const _StatsSection({
    required this.streak,
    required this.reflections,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Streak + Reflections
          Row(
            children: [
              _StatTile(label: 'Streak', value: '$streak days', emoji: '🔥'),
              const SizedBox(width: 20),
              _StatTile(
                label: 'Reflections',
                value: '$reflections',
                emoji: '✦',
              ),
            ],
          ),

          if (profile != null) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            _CategoryBarsSection(profile: profile!),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(value, style: AppTypography.displaySmall),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.bodySmall),
      ],
    );
  }
}

class _CategoryBarsSection extends StatelessWidget {
  final UserProfileModel profile;
  const _CategoryBarsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    // Simple visual category bars derived from profile interest / goal
    final interest = profile.interest ?? '';
    final goal = profile.goal ?? '';

    final categories = {
      'stoicism': interest == 'stoicism' ? 0.8 : 0.3,
      'discipline': goal == 'discipline' ? 0.75 : 0.25,
      'reflection': interest == 'mindfulness' ? 0.7 : 0.35,
      'philosophy': interest == 'philosophy' ? 0.9 : 0.4,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Categories', style: AppTypography.authorText),
        const SizedBox(height: 8),
        ...categories.entries.map((entry) {
          final color = AppColors.categoryColor(entry.key);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: AppTypography.bodySmall.copyWith(color: color),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: entry.value,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 6,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.displaySmall);
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTypography.authorText);
  }
}

class _ChipSelector extends StatelessWidget {
  final List<String> options;
  final String? selected;
  final bool enabled;
  final void Function(String?) onChanged;
  final String Function(String)? labelBuilder;

  const _ChipSelector({
    required this.options,
    required this.selected,
    required this.enabled,
    required this.onChanged,
    this.labelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return GestureDetector(
          onTap: enabled ? () => onChanged(option) : null,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.stoicism.withOpacity(0.15)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.stoicism : AppColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Text(
              labelBuilder?.call(option) ?? option,
              style: AppTypography.bodySmall.copyWith(
                color: isSelected
                    ? AppColors.stoicism
                    : AppColors.textSecondary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
