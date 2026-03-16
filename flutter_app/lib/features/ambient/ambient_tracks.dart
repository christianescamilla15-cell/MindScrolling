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

const List<AmbientTrack> kAmbientTracks = [
  AmbientTrack(
    id: 'relax',
    nameEn: 'Relax',
    nameEs: 'Relajacion',
    icon: Icons.waves_outlined,
    accentColor: AppColors.stoicism,
    audioUrl: null,
  ),
  AmbientTrack(
    id: 'deep_focus',
    nameEn: 'Deep Focus',
    nameEs: 'Enfoque profundo',
    icon: Icons.self_improvement_outlined,
    accentColor: AppColors.discipline,
    audioUrl: null,
  ),
  AmbientTrack(
    id: 'night_reflection',
    nameEn: 'Night Reflection',
    nameEs: 'Reflexion nocturna',
    icon: Icons.nightlight_outlined,
    accentColor: AppColors.reflection,
    audioUrl: null,
  ),
];

AmbientTrack? trackById(String id) {
  try {
    return kAmbientTracks.firstWhere((t) => t.id == id);
  } catch (_) {
    return null;
  }
}
