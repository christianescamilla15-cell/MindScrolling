import '../../models/user_profile_model.dart';
import '../../../core/network/api_client.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSource(this._apiClient);

  /// GET /profile
  /// Returns null if the profile has never been saved (404 treated as empty).
  Future<UserProfileModel?> getProfile() async {
    try {
      final json = await _apiClient.get('/profile');
      // Backend returns the profile object directly (or null wrapped as {data: null} by ApiClient)
      if (json.containsKey('data')) {
        // ApiClient wraps non-Map responses as {data: decoded} — null profile case
        final raw = json['data'];
        if (raw == null) return null;
        if (raw is Map<String, dynamic>) return UserProfileModel.fromJson(raw);
        return null;
      }
      // Profile object returned directly as a Map
      if (json.containsKey('device_id')) {
        return UserProfileModel.fromJson(json);
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /profile
  Future<void> saveProfile(UserProfileModel profile) async {
    await _apiClient.post('/profile', body: profile.toJson());
  }
}
