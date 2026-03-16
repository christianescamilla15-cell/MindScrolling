import '../../models/quote_model.dart';
import '../../../core/network/api_client.dart';

class VaultRemoteDataSource {
  final ApiClient _apiClient;

  const VaultRemoteDataSource(this._apiClient);

  /// GET /vault
  Future<List<QuoteModel>> getVault() async {
    final response = await _apiClient.get('/vault');
    final raw = response['data'];
    if (raw is! List) return [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map(QuoteModel.fromJson)
        .toList();
  }

  /// POST /vault  with { quote_id }
  Future<void> saveToVault(String quoteId) async {
    await _apiClient.post('/vault', body: {'quote_id': quoteId});
  }

  /// DELETE /vault/:quote_id
  Future<void> removeFromVault(String quoteId) async {
    await _apiClient.delete('/vault/$quoteId');
  }
}
