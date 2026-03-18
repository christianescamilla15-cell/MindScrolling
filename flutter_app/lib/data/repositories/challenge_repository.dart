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
  Future<ApiResult<ChallengeModel>> getTodayChallenge({String lang = 'en'}) async {
    try {
      final json = await _remote.getTodayChallenge(lang: lang);
      // Backend returns { challenge: {...}, progress: {...} }
      final challengeData = json['challenge'] as Map<String, dynamic>? ?? json;
      final progressData = json['progress'] as Map<String, dynamic>?;

      final challenge = ChallengeModel.fromJson(challengeData);
      await LocalStorage.setString(
        _challengeCacheKey,
        jsonEncode(challenge.toJson()),
      );

      // Cache progress from the same response to avoid a second network call.
      // Inject top-level target into progress data so the model gets the server value.
      final serverTarget = (json['target'] as num?)?.toInt();
      if (progressData != null) {
        final enriched = {...progressData, if (serverTarget != null) 'target': serverTarget};
        await LocalStorage.setString(
          _progressCacheKey,
          jsonEncode(ChallengeProgressModel.fromJson(enriched).toJson()),
        );
      } else if (serverTarget != null) {
        await LocalStorage.setString(
          _progressCacheKey,
          jsonEncode(ChallengeProgressModel(target: serverTarget).toJson()),
        );
      }

      return ApiSuccess(challenge);
    } catch (e) {
      final cached = await _loadCachedChallenge();
      return ApiSuccess(cached);
    }
  }

  /// Returns the challenge progress — uses the cache populated by
  /// [getTodayChallenge] to avoid a redundant network round-trip.
  Future<ApiResult<ChallengeProgressModel>> getChallengeProgress(
    String challengeId,
  ) async {
    final cached = await _loadCachedProgress();
    return ApiSuccess(cached);
  }

  /// Posts progress delta to the server and caches the server-confirmed values.
  /// [count] is the number of new swipes to add (delta, not absolute).
  /// Fire-and-forget — failures are silent.
  Future<void> updateProgress(
    String challengeId,
    int count,
    bool completed,
  ) async {
    try {
      final response = await _remote.updateProgress(challengeId, count: count);
      // Use server-confirmed values instead of caller-predicted values
      final serverProgress = (response['progress'] as num?)?.toInt() ?? 0;
      final serverCompleted = response['completed'] as bool? ?? completed;
      final model = ChallengeProgressModel(
        progress: serverProgress,
        completed: serverCompleted,
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
      // Backend returns { current, snapshot, snapshot_date } directly — no 'data' wrapper
      return ApiSuccess(PhilosophyMapModel.fromJson(json));
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
