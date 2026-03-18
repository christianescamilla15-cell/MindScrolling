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
      // Backend returns the profile object directly as a Map with device_id
      if (json.containsKey('device_id')) {
        return UserProfileModel.fromJson(json);
      }
      return null;
    } on ApiException catch (e) {
      // Backend returns 404 when no profile exists
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  /// POST /profile
  Future<void> saveProfile(UserProfileModel profile) async {
    await _apiClient.post('/profile', body: profile.toJson());
  }
}
