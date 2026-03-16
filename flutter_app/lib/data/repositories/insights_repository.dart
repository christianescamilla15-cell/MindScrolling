import '../datasources/remote/insights_remote_ds.dart';
import '../models/insight_model.dart';
import '../../core/network/api_result.dart';

/// Repository for AI-generated weekly insights.
///
/// Wraps the remote data source and returns [ApiResult] so the UI layer
/// never has to handle raw exceptions.
class InsightsRepository {
  final InsightsRemoteDataSource _remote;

  const InsightsRepository({required InsightsRemoteDataSource remote})
      : _remote = remote;

  /// Fetches the weekly insight for the current device.
  ///
  /// Returns [ApiSuccess(null)] when the backend has no insight yet
  /// (API key not configured or user has too little history).
  Future<ApiResult<InsightModel?>> getWeeklyInsight() async {
    try {
      final json = await _remote.getWeeklyInsight();
      final insightText = json['insight'] as String?;
      if (insightText == null || insightText.trim().isEmpty) {
        return const ApiSuccess(null);
      }
      return ApiSuccess(InsightModel.fromJson(json));
    } catch (e) {
      return ApiError('Failed to load insight: $e');
    }
  }
}
