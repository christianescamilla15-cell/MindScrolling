import '../../models/swipe_event_model.dart';
import '../../../core/network/api_client.dart';

class FeedRemoteDataSource {
  final ApiClient _apiClient;

  const FeedRemoteDataSource(this._apiClient);

  /// GET /quotes/feed
  /// Returns the raw feed payload: { data: [...], next_cursor: string|null, has_more: bool }
  Future<Map<String, dynamic>> fetchFeed({
    String lang = 'en',
    String? cursor,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'lang': lang,
      'limit': limit.toString(),
      if (cursor != null) 'cursor': cursor,
    };
    return _apiClient.get('/quotes/feed', queryParams: params);
  }

  /// POST /swipes
  Future<void> recordSwipe(SwipeEventModel event) async {
    await _apiClient.post('/swipes', body: event.toJson());
  }

  /// POST /quotes/:id/like  with { action: "like" | "unlike" }
  Future<void> likeQuote(String quoteId, bool liked) async {
    await _apiClient.post(
      '/quotes/$quoteId/like',
      body: {'action': liked ? 'like' : 'unlike'},
    );
  }
}
