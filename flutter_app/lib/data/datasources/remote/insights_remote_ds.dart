import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';

/// Remote data source for AI-generated weekly insights.
class InsightsRemoteDataSource {
  final ApiClient _apiClient;

  const InsightsRemoteDataSource(this._apiClient);

  /// GET /insights/weekly?lang=en|es
  /// Returns { insight: String | null }
  Future<Map<String, dynamic>> getWeeklyInsight({String lang = 'en'}) async {
    return _apiClient.get(
      ApiConstants.insightsWeeklyPath,
      queryParams: {'lang': lang},
    );
  }
}
