import '../../../core/network/api_client.dart';

class ChallengeRemoteDataSource {
  final ApiClient _apiClient;

  const ChallengeRemoteDataSource(this._apiClient);

  /// GET /challenges/today
  /// Returns { id, code, title, description, active_date }
  Future<Map<String, dynamic>> getTodayChallenge({String lang = 'en'}) async {
    return _apiClient.get('/challenges/today', queryParams: {'lang': lang});
  }

  /// POST /challenges/:id/progress
  /// Returns { updated: bool, progress: int, completed: bool }
  Future<Map<String, dynamic>> updateProgress(String challengeId) async {
    return _apiClient.post('/challenges/$challengeId/progress');
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
