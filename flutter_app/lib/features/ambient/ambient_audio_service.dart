import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'ambient_tracks.dart';

class AmbientAudioService {
  AudioPlayer? _player;
  bool _initialized = false;
  String? _currentUrl;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    _player = AudioPlayer();

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ));
    } catch (e) {
      debugPrint('[AmbientAudioService] AudioSession configure error: $e');
    }
  }

  Future<void> setTrack(AmbientTrack track, {bool autoPlay = true}) async {
    await init();
    final url = track.audioUrl;

    if (url == null) {
      await _player?.stop();
      _currentUrl = null;
      return;
    }

    if (_currentUrl == url) {
      if (autoPlay && !(_player?.playing ?? false)) {
        await _player?.play();
      }
      return;
    }

    try {
      await _player?.stop();
      _currentUrl = url;
      await _player?.setUrl(url);
      _player?.setLoopMode(LoopMode.one);
      if (autoPlay) await _player?.play();
    } catch (e) {
      debugPrint('[AmbientAudioService] setTrack error: $e');
      _currentUrl = null;
    }
  }

  Future<void> play() async {
    if (_currentUrl == null) return;
    try { await _player?.play(); } catch (e) {
      debugPrint('[AmbientAudioService] play error: $e');
    }
  }

  Future<void> pause() async {
    try { await _player?.pause(); } catch (e) {
      debugPrint('[AmbientAudioService] pause error: $e');
    }
  }

  Future<void> stop() async {
    try { await _player?.stop(); _currentUrl = null; } catch (e) {
      debugPrint('[AmbientAudioService] stop error: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try { await _player?.setVolume(volume.clamp(0.0, 1.0)); } catch (e) {
      debugPrint('[AmbientAudioService] setVolume error: $e');
    }
  }

  bool get isPlaying => _player?.playing ?? false;

  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    _initialized = false;
    _currentUrl = null;
  }
}
