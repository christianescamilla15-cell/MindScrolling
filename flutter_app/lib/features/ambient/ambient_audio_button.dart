import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/colors.dart';
import 'ambient_audio_controller.dart';
import 'ambient_audio_sheet.dart';

class AmbientAudioButton extends ConsumerWidget {
  const AmbientAudioButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ambientAudioStateProvider);
    final isPlaying = state.isPlaying;
    final accent = state.currentTrack.accentColor;

    return GestureDetector(
      onTap: () => AmbientAudioSheet.show(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: isPlaying ? accent.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isPlaying ? accent.withOpacity(0.4) : AppColors.border, width: 1),
        ),
        child: Icon(
          isPlaying ? Icons.equalizer_rounded : Icons.music_note_outlined,
          size: 18, color: isPlaying ? accent : AppColors.textMuted,
        ),
      ),
    );
  }
}
