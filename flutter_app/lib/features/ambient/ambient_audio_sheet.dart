import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';
import '../../shared/extensions/context_extensions.dart';
import 'ambient_audio_controller.dart';
import 'ambient_tracks.dart';

class AmbientAudioSheet extends ConsumerWidget {
  const AmbientAudioSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AmbientAudioSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambientAudioStateProvider);
    final controller = ref.read(ambientAudioControllerProvider.notifier);
    final tr = context.tr;
    final lang = Localizations.localeOf(context).languageCode;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C28),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, MediaQuery.paddingOf(context).bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: AppColors.borderStrong, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.music_note_outlined, color: AppColors.stoicism, size: 20),
              const SizedBox(width: 8),
              Text(tr.ambientAudio, style: AppTypography.displaySmall),
              const Spacer(),
              Switch(
                value: state.isEnabled,
                onChanged: (v) => controller.setEnabled(v),
                activeThumbColor: AppColors.stoicism,
                inactiveTrackColor: AppColors.surface,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(tr.soundscapes, style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Row(
            children: kAmbientTracks.map((track) {
              final isSelected = track.id == state.currentTrackId;
              final label = lang == 'es' ? track.nameEs : track.nameEn;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _TrackChip(
                    label: label,
                    icon: track.icon,
                    accentColor: track.accentColor,
                    isSelected: isSelected,
                    onTap: () => controller.selectTrack(track.id),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          if (state.isPlaying) ...[
            Row(children: [
              const Icon(Icons.equalizer, color: AppColors.stoicism, size: 14),
              const SizedBox(width: 6),
              Text(
                '${tr.nowPlaying} — ${lang == 'es' ? state.currentTrack.nameEs : state.currentTrack.nameEn}',
                style: AppTypography.caption.copyWith(color: AppColors.stoicism),
              ),
            ]),
            const SizedBox(height: 16),
          ],
          if (!state.isAvailable) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.textMuted, size: 16),
                const SizedBox(width: 10),
                Expanded(child: Text(tr.audioComingSoon, style: AppTypography.bodySmall)),
              ]),
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.isEnabled
                    ? state.currentTrack.accentColor.withOpacity(0.15)
                    : AppColors.surface,
                foregroundColor:
                    state.isEnabled ? state.currentTrack.accentColor : AppColors.textMuted,
                elevation: 0,
                side: BorderSide(
                    color: state.isEnabled
                        ? state.currentTrack.accentColor.withOpacity(0.4)
                        : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon:
                  Icon(state.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 26),
              label: Text(
                state.isPlaying ? tr.pause : tr.play,
                style: AppTypography.buttonLabel.copyWith(
                  color: state.isEnabled ? state.currentTrack.accentColor : AppColors.textMuted,
                ),
              ),
              onPressed: state.isEnabled ? () => controller.playPause() : null,
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            const Icon(Icons.volume_down_outlined, color: AppColors.textMuted, size: 18),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: state.currentTrack.accentColor,
                  inactiveTrackColor: AppColors.border,
                  thumbColor: state.currentTrack.accentColor,
                  overlayColor: state.currentTrack.accentColor.withOpacity(0.12),
                  trackHeight: 3.0,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                ),
                child: Slider(
                    value: state.volume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (v) => controller.setVolume(v)),
              ),
            ),
            const Icon(Icons.volume_up_outlined, color: AppColors.textMuted, size: 18),
          ]),
        ],
      ),
    );
  }
}

class _TrackChip extends StatelessWidget {
  const _TrackChip(
      {required this.label,
      required this.icon,
      required this.accentColor,
      required this.isSelected,
      required this.onTap});
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.12) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isSelected ? accentColor.withOpacity(0.5) : AppColors.border,
              width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 22, color: isSelected ? accentColor : AppColors.textMuted),
          const SizedBox(height: 6),
          Text(label,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: isSelected ? accentColor : AppColors.textMuted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 10,
              )),
        ]),
      ),
    );
  }
}
