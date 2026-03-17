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
  AmbientTrack(
    id: 'relax',
    nameEn: 'Relax',
    nameEs: 'Relajacion',
    icon: Icons.waves_outlined,
    accentColor: AppColors.stoicism,
    audioUrl: '${ApiConstants.baseUrl}/static/audio/Clean_20Soul.mp3',
  ),
  AmbientTrack(
    id: 'deep_focus',
    nameEn: 'Deep Focus',
    nameEs: 'Enfoque profundo',
    icon: Icons.self_improvement_outlined,
    accentColor: AppColors.discipline,
    audioUrl: '${ApiConstants.baseUrl}/static/audio/Meditation_20Impromptu_2001.mp3',
  ),
  AmbientTrack(
    id: 'night_reflection',
    nameEn: 'Night Reflection',
    nameEs: 'Reflexion nocturna',
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
