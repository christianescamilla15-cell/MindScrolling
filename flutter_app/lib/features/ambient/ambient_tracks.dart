import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

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

// Royalty-free ambient audio streams from Pixabay (CC0 license)
const List<AmbientTrack> kAmbientTracks = [
  AmbientTrack(
    id: 'relax',
    nameEn: 'Relax',
    nameEs: 'Relajacion',
    icon: Icons.waves_outlined,
    accentColor: AppColors.stoicism,
    audioUrl: 'https://cdn.pixabay.com/audio/2024/11/28/audio_3a6a84e951.mp3',
  ),
  AmbientTrack(
    id: 'deep_focus',
    nameEn: 'Deep Focus',
    nameEs: 'Enfoque profundo',
    icon: Icons.self_improvement_outlined,
    accentColor: AppColors.discipline,
    audioUrl: 'https://cdn.pixabay.com/audio/2022/10/25/audio_540843e92f.mp3',
  ),
  AmbientTrack(
    id: 'night_reflection',
    nameEn: 'Night Reflection',
    nameEs: 'Reflexion nocturna',
    icon: Icons.nightlight_outlined,
    accentColor: AppColors.reflection,
    audioUrl: 'https://cdn.pixabay.com/audio/2023/09/04/audio_4b3de66fd7.mp3',
  ),
];

AmbientTrack? trackById(String id) {
  try {
    return kAmbientTracks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
