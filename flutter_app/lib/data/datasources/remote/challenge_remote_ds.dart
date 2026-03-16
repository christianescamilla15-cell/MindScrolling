import '../../../core/network/api_client.dart';

class ChallengeRemoteDataSource {
  final ApiClient _apiClient;

  const ChallengeRemoteDataSource(this._apiClient);

  /// GET /challenges/today
  /// Returns { id, code, title, description, active_date }
  Future<Map<String, dynamic>> getTodayChallenge() async {
    return _apiClient.get('/challenges/today');
  }

  /// POST /challenges/:id/progress  with { progress, completed }
  Future<void> updateProgress(
    String challengeId,
    int progress,
    bool completed,
  ) async {
    await _apiClient.post(
      '/challenges/$challengeId/progress',
      body: {'progress': progress, 'completed': completed},
    );
  }

  /// GET /map
  /// Returns { current: { wisdom, discipline, reflection, philosophy },
  ///           snapshot: same|null, snapshot_date: string|null }
  Future<Map<String, dynamic>> getMap() async {
    return _apiClient.get('/map');
  }

  /// POST /map/snapshot
  Future<void> saveMapSnapshot() async {
    await _apiClient.post('/map/snapshot');
  }
}
