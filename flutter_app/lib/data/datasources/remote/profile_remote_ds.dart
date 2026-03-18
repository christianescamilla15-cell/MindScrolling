import '../../models/user_profile_model.dart';
import '../../../core/network/api_client.dart';

class ProfileRemoteDataSource {
  final ApiClient _apiClient;

  const ProfileRemoteDataSource(this._apiClient);

  /// GET /profile
  /// Returns null if the profile has never been created.
  /// Backend returns 200 with the profile object, or 200 with JSON null.
  Future<UserProfileModel?> getProfile() async {
    try {
      final json = await _apiClient.get('/profile');
      // ApiClient wraps JSON null as {data: null}; profile object has device_id
      if (json.containsKey('device_id')) {
        return UserProfileModel.fromJson(json);
      }
      return null;
    } on ApiException catch (e) {
      // Fallback: treat 404 as no profile (backward compat)
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /profile
  Future<void> saveProfile(UserProfileModel profile) async {
    await _apiClient.post('/profile', body: profile.toJson());
  }
}
