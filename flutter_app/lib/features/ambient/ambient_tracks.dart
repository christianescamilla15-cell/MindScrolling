import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../core/constants/api_constants.dart';

class AmbientTrack {
  final String id;
  final String nameEn;
  final String nameEs;
  final IconData icon;
  final Color accentColor;
  final String? audioUrl;

  const AmbientTrack({
    required this.id,
    required this.nameEn,
    required this.nameEs,
    required this.icon,
    required this.accentColor,
    this.audioUrl,
  });
}

// Audio served from the MindScrolling backend at /static/audio/
// These are generated ambient sine-wave tones (calm, meditative)
// PRODUCTION: Replace with real Pixabay/Zen meditation tracks

List<AmbientTrack> get kAmbientTracks => [
      const AmbientTrack(
        id: 'relax',
        nameEn: 'Relax',
        nameEs: 'Relajaci\u00f3n',
        icon: Icons.waves_outlined,
        accentColor: AppColors.stoicism,
        audioUrl: '${ApiConstants.baseUrl}/static/audio/Clean_20Soul.mp3',
      ),
      const AmbientTrack(
        id: 'deep_focus',
        nameEn: 'Deep Focus',
        nameEs: 'Enfoque profundo',
        icon: Icons.self_improvement_outlined,
        accentColor: AppColors.discipline,
        audioUrl: '${ApiConstants.baseUrl}/static/audio/Meditation_20Impromptu_2001.mp3',
      ),
      const AmbientTrack(
        id: 'night_reflection',
        nameEn: 'Night Reflection',
        nameEs: 'Reflexi\u00f3n nocturna',
        icon: Icons.nightlight_outlined,
        accentColor: AppColors.reflection,
        audioUrl: '${ApiConstants.baseUrl}/static/audio/Long_20Note_20Four.mp3',
      ),
    ];

AmbientTrack? trackById(String id) {
  try {
    return kAmbientTracks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}

/// Maps emotional tags to the most fitting ambient track.
/// Used by the Insight panel to adapt audio to the user's emotional state.
///
/// Mapping:
///   calm, mindfulness, gratitude, self_love → 'relax'
///   focus, discipline, motivation, learning → 'deep_focus'
///   reflection, sadness, existence, meaning → 'night_reflection'
AmbientTrack? trackForEmotion(List<String> tags) {
  const emotionToTrack = {
    'calm': 'relax',
    'mindfulness': 'relax',
    'gratitude': 'relax',
    'self_love': 'relax',
    'peace': 'relax',
    'focus': 'deep_focus',
    'discipline': 'deep_focus',
    'motivation': 'deep_focus',
    'learning': 'deep_focus',
    'curiosity': 'deep_focus',
    'courage': 'deep_focus',
    'self_improvement': 'deep_focus',
    'reflection': 'night_reflection',
    'sadness': 'night_reflection',
    'existence': 'night_reflection',
    'meaning': 'night_reflection',
    'wisdom': 'night_reflection',
    'anxiety': 'relax',
    'inner_strength': 'deep_focus',
    'resilience': 'deep_focus',
    'creativity': 'night_reflection',
  };

  for (final tag in tags) {
    final trackId = emotionToTrack[tag];
    if (trackId != null) return trackById(trackId);
  }
  return null;
}
