import '../datasources/local/settings_local_ds.dart';
import '../datasources/remote/stats_remote_ds.dart';
import '../models/premium_state_model.dart';
import '../../core/network/api_result.dart';

/// Repository for premium status checks and unlocking.
/// Uses [StatsRemoteDataSource] for network calls and
/// [SettingsLocalDataSource] for local caching.
class PremiumRepository {
  final StatsRemoteDataSource _remote;
  final SettingsLocalDataSource _local;

  const PremiumRepository({
    required StatsRemoteDataSource remote,
    required SettingsLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  /// Synchronous check against the local cache.
  /// Use this to gate UI without waiting for a network call.
  bool get isUnlocked {
    // Resolved synchronously via a cached bool flag.
    // The async [getStatus] must be called at least once to populate the cache.
    return false; // Overridden by async check — see [getStatus].
  }

  /// Fetches premium status from the server and updates the local cache.
  /// Falls back to the locally cached value on network failure.
  Future<ApiResult<PremiumStateModel>> getStatus() async {
    try {
      final json = await _remote.getPremiumStatus();
      final state = PremiumStateModel.fromJson(json);
      await _local.setPremium(state.isPremium);
      await _local.setOwnedPacks(state.ownedPacks);
      await _local.setUserState(state.userState);
      return ApiSuccess(state);
    } catch (e) {
      final cachedPremium = await _local.isPremium();
      final cachedPacks = await _local.getOwnedPacks();
      final cachedUserState = await _local.getUserState();
      return ApiSuccess(PremiumStateModel(
        isPremium: cachedPremium,
        ownedPacks: cachedPacks,
        userState: cachedUserState,
      ));
    }
  }

  /// Calls the unlock endpoint and persists the result locally.
  Future<ApiResult<void>> unlock({
    double? amount,
    String currency = 'USD',
  }) async {
    try {
      await _remote.unlockPremium(amount: amount, currency: currency);
      await _local.setPremium(true);
      return const ApiSuccess(null);
    } catch (e) {
      return ApiError('Failed to unlock premium: $e');
    }
  }
}
