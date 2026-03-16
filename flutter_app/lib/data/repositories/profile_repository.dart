import '../datasources/local/settings_local_ds.dart';
import '../datasources/remote/profile_remote_ds.dart';
import '../models/user_profile_model.dart';
import '../../core/network/api_result.dart';

/// Repository for user profile operations.
/// Uses [ProfileRemoteDataSource] for network calls and
/// [SettingsLocalDataSource] to cache the profile locally.
class ProfileRepository {
  final ProfileRemoteDataSource _remote;
  final SettingsLocalDataSource _local;

  const ProfileRepository({
    required ProfileRemoteDataSource remote,
    required SettingsLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  /// Fetches the profile from the server, caches it locally, and returns it.
  /// Falls back to the locally cached profile on network failure.
  /// Returns `null` data when no profile has been saved yet.
  Future<ApiResult<UserProfileModel?>> getProfile() async {
    try {
      final profile = await _remote.getProfile();
      if (profile != null) {
        await _local.setProfile(profile.toJson());
      }
      return ApiSuccess(profile);
    } catch (e) {
      // Fall back to locally cached profile.
      final cached = await _local.getProfile();
      if (cached != null) {
        try {
          return ApiSuccess(UserProfileModel.fromJson(cached));
        } catch (_) {}
      }
      return ApiError('Failed to load profile: $e');
    }
  }

  /// Saves the profile to the server and caches it locally.
  Future<ApiResult<void>> saveProfile(UserProfileModel profile) async {
    try {
      await _remote.saveProfile(profile);
      await _local.setProfile(profile.toJson());
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to save profile: $e');
    }
  }
}
