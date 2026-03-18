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
      final raw = json['data'];
      if (raw == null) return null;
      return UserProfileModel.fromJson(raw as Map<String, dynamic>);
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
