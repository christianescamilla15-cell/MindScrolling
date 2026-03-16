import 'dart:convert';

import '../../../core/storage/cache_storage.dart';
import '../../models/quote_model.dart';

class FeedLocalDataSource {
  final CacheStorage _cache;

  static const _feedCacheKey = 'mindscroll_feed_cache';
  static const _feedCacheTtl = Duration(minutes: 5);

  const FeedLocalDataSource(this._cache);

  /// Returns the last cached feed page, or null if missing / expired.
  Future<List<QuoteModel>?> getCachedFeed() async {
    final raw = await _cache.get(_feedCacheKey);
    if (raw == null) return null;

    try {
      final List<dynamic> list = raw is String ? jsonDecode(raw) : raw;
      return list
          .whereType<Map<String, dynamic>>()
          .map(QuoteModel.fromJson)
          .toList();
    } catch (_) {
      await _cache.remove(_feedCacheKey);
      return null;
    }
  }

  /// Caches [quotes] with a 5-minute TTL.
  Future<void> cacheFeed(List<QuoteModel> quotes) async {
    final jsonList = quotes.map((q) => q.toJson()).toList();
    await _cache.set(_feedCacheKey, jsonList, ttl: _feedCacheTtl);
  }

  /// Removes the cached feed immediately.
  Future<void> clearCache() async {
    await _cache.remove(_feedCacheKey);
  }
}
