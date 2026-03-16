import '../datasources/remote/stats_remote_ds.dart';
import '../../core/network/api_result.dart';

/// Repository for app-wide statistics: streak, total reflections,
/// and per-category swipe counts.
class StatsRepository {
  final StatsRemoteDataSource _remote;

  const StatsRepository({required StatsRemoteDataSource remote})
      : _remote = remote;

  /// Fetches stats from the server.
  ///
  /// Returns a map with at minimum:
  /// - `streak` (int) — current daily streak
  /// - `total_reflections` (int) — all-time swipe count
  /// - `category_counts` (Map<String, int>) — swipes per category
  Future<ApiResult<Map<String, dynamic>>> getStats() async {
    try {
      final json = await _remote.getStats();
      // Normalise: server may wrap in a 'data' envelope or return flat.
      final data = json['data'] as Map<String, dynamic>? ?? json;
      return ApiSuccess(data);
    } catch (e) {
      return ApiError('Failed to load stats: $e');
    }
  }
}
