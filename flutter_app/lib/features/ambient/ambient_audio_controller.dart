import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ambient_audio_service.dart';
import 'ambient_tracks.dart';

const _kPrefEnabled = 'mindscroll.ambient.enabled';
const _kPrefTrackId = 'mindscroll.ambient.trackId';
const _kPrefVolume  = 'mindscroll.ambient.volume';

class AmbientAudioState {
  final bool isEnabled;
  final bool isPlaying;
  final String currentTrackId;
  final double volume;
  final bool isAvailable;

  const AmbientAudioState({
    this.isEnabled = false,
    this.isPlaying = false,
    this.currentTrackId = 'relax',
    this.volume = 0.6,
    this.isAvailable = false,
  });

  AmbientAudioState copyWith({
    bool? isEnabled,
    bool? isPlaying,
    String? currentTrackId,
    double? volume,
    bool? isAvailable,
  }) {
    return AmbientAudioState(
      isEnabled: isEnabled ?? this.isEnabled,
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrackId: currentTrackId ?? this.currentTrackId,
      volume: volume ?? this.volume,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  AmbientTrack get currentTrack =>
      trackById(currentTrackId) ?? kAmbientTracks.first;
}

class AmbientAudioController extends AsyncNotifier<AmbientAudioState> {
  final _service = AmbientAudioService();

  @override
  Future<AmbientAudioState> build() async {
    final available = kAmbientTracks.any((t) => t.audioUrl != null);
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kPrefEnabled) ?? false;
    final trackId = prefs.getString(_kPrefTrackId) ?? kAmbientTracks.first.id;
    final volume = prefs.getDouble(_kPrefVolume) ?? 0.6;

    await _service.init();
    await _service.setVolume(volume);
    ref.onDispose(() => _service.dispose());

    return AmbientAudioState(
      isEnabled: enabled,
      isPlaying: false,
      currentTrackId: trackId,
      volume: volume,
      isAvailable: available,
    );
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.valueOrNull ?? const AmbientAudioState();
    if (!enabled) await _service.stop();
    state = AsyncData(current.copyWith(isEnabled: enabled, isPlaying: false));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefEnabled, enabled);
  }

  Future<void> selectTrack(String trackId) async {
    final current = state.valueOrNull ?? const AmbientAudioState();
    final track = trackById(trackId) ?? kAmbientTracks.first;
    state = AsyncData(current.copyWith(currentTrackId: trackId));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefTrackId, trackId);
    if (current.isPlaying) {
      await _service.setTrack(track, autoPlay: true);
    }
  }

  Future<void> playPause() async {
    final current = state.valueOrNull ?? const AmbientAudioState();
    if (!current.isEnabled) await setEnabled(true);

    if (current.isPlaying) {
      await _service.pause();
      state = AsyncData(
        (state.valueOrNull ?? const AmbientAudioState()).copyWith(isPlaying: false),
      );
    } else {
      final track = current.currentTrack;
      if (track.audioUrl == null) {
        state = AsyncData(current.copyWith(isPlaying: false));
        return;
      }
      await _service.setTrack(track, autoPlay: true);
      state = AsyncData(
        (state.valueOrNull ?? const AmbientAudioState()).copyWith(isPlaying: true),
      );
    }
  }

  Future<void> stop() async {
    await _service.stop();
    state = AsyncData(
      (state.valueOrNull ?? const AmbientAudioState()).copyWith(isPlaying: false),
    );
  }

  Future<void> setVolume(double volume) async {
    await _service.setVolume(volume);
    state = AsyncData(
      (state.valueOrNull ?? const AmbientAudioState()).copyWith(volume: volume),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kPrefVolume, volume);
  }
}

final ambientAudioControllerProvider =
    AsyncNotifierProvider<AmbientAudioController, AmbientAudioState>(
  AmbientAudioController.new,
);

final ambientAudioStateProvider = Provider<AmbientAudioState>((ref) {
  return ref.watch(ambientAudioControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const AmbientAudioState(),
      );
});
