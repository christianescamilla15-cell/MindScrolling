import '../../../core/network/api_client.dart';

class StatsRemoteDataSource {
  final ApiClient _apiClient;

  const StatsRemoteDataSource(this._apiClient);

  /// GET /stats
  /// Returns { streak: int, total_reflections: int, category_counts: Map }
  Future<Map<String, dynamic>> getStats() async {
    return _apiClient.get('/stats');
  }

  /// GET /premium/status
  /// Returns { is_premium: bool }
  Future<Map<String, dynamic>> getPremiumStatus() async {
    return _apiClient.get('/premium/status');
  }

  /// POST /premium/unlock
  /// Body: { purchase_type: 'premium_unlock', amount: double?, currency: string }
  Future<void> unlockPremium({
    double? amount,
    String currency = 'USD',
  }) async {
    await _apiClient.post(
      '/premium/unlock',
      body: {
        'purchase_type': 'premium_unlock',
        if (amount != null) 'amount': amount,
        'currency': currency,
      },
    );
  }
}
