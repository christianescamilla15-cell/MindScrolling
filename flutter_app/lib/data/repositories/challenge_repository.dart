import 'dart:convert';

import '../datasources/remote/challenge_remote_ds.dart';
import '../models/challenge_model.dart';
import '../models/philosophy_map_model.dart';
import '../../core/network/api_result.dart';
import '../../core/storage/local_storage.dart';

/// Repository for daily challenges and the philosophy map.
class ChallengeRepository {
  final ChallengeRemoteDataSource _remote;

  static const _challengeCacheKey = 'mindscroll_challenge_cache';
  static const _progressCacheKey = 'mindscroll_challenge_progress';

  const ChallengeRepository({
    required ChallengeRemoteDataSource remote,
  }) : _remote = remote;

  // ── Challenge ─────────────────────────────────────────────────────────────

  /// Fetches today's challenge from the server and caches it locally.
  /// Falls back to the cached challenge (or a hard-coded default) on failure.
  Future<ApiResult<ChallengeModel>> getTodayChallenge() async {
    try {
      final json = await _remote.getTodayChallenge();
      final data = json['data'] as Map<String, dynamic>? ?? json;
      final challenge = ChallengeModel.fromJson(data);
      await LocalStorage.setString(
        _challengeCacheKey,
        jsonEncode(challenge.toJson()),
      );
      return ApiSuccess(challenge);
    } catch (e) {
      final cached = await _loadCachedChallenge();
      return ApiSuccess(cached);
    }
  }

  /// Fetches the progress for [challengeId] from the server.
  /// Falls back to locally cached progress on failure.
  Future<ApiResult<ChallengeProgressModel>> getChallengeProgress(
    String challengeId,
  ) async {
    try {
      final json = await _remote.getTodayChallenge();
      // Progress is usually embedded in the challenge response.
      final progressJson = json['progress'] as Map<String, dynamic>?;
      if (progressJson != null) {
        final progress = ChallengeProgressModel.fromJson(progressJson);
        await LocalStorage.setString(
          _progressCacheKey,
          jsonEncode(progress.toJson()),
        );
        return ApiSuccess(progress);
      }
      final cached = await _loadCachedProgress();
      return ApiSuccess(cached);
    } catch (e) {
      final cached = await _loadCachedProgress();
      return ApiSuccess(cached);
    }
  }

  /// Posts progress to the server. Fire-and-forget — failures are silent.
  Future<void> updateProgress(
    String challengeId,
    int progress,
    bool completed,
  ) async {
    try {
      await _remote.updateProgress(challengeId, progress, completed);
      // Persist locally so getChallengeProgress can reflect the update.
      final model = ChallengeProgressModel(
        progress: progress,
        completed: completed,
      );
      await LocalStorage.setString(
        _progressCacheKey,
        jsonEncode(model.toJson()),
      );
    } catch (_) {
      // Intentionally ignored — fire and forget.
    }
  }

  // ── Philosophy Map ────────────────────────────────────────────────────────

  /// Fetches the current philosophy map from the server.
  /// Returns an empty map on failure.
  Future<ApiResult<PhilosophyMapModel>> getPhilosophyMap() async {
    try {
      final json = await _remote.getMap();
      final data = json['data'] as Map<String, dynamic>? ?? json;
      return ApiSuccess(PhilosophyMapModel.fromJson(data));
    } catch (e) {
      return ApiError('Failed to load philosophy map: $e');
    }
  }

  /// Posts a snapshot of the current map. Fire-and-forget.
  Future<void> saveMapSnapshot() async {
    try {
      await _remote.saveMapSnapshot();
    } catch (_) {
      // Intentionally ignored.
    }
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<ChallengeModel> _loadCachedChallenge() async {
    final raw = await LocalStorage.getString(_challengeCacheKey);
    if (raw == null || raw.isEmpty) return ChallengeModel.defaultChallenge;
    try {
      return ChallengeModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return ChallengeModel.defaultChallenge;
    }
  }

  Future<ChallengeProgressModel> _loadCachedProgress() async {
    final raw = await LocalStorage.getString(_progressCacheKey);
    if (raw == null || raw.isEmpty) return const ChallengeProgressModel();
    try {
      return ChallengeProgressModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const ChallengeProgressModel();
    }
  }
}
