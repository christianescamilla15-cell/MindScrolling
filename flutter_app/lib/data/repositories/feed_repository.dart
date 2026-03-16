import '../datasources/local/feed_local_ds.dart';
import '../datasources/remote/feed_remote_ds.dart';
import '../datasources/remote/profile_remote_ds.dart';
import '../datasources/remote/vault_remote_ds.dart';
import '../models/feed_item_model.dart';
import '../models/quote_model.dart';
import '../models/swipe_event_model.dart';
import '../models/user_profile_model.dart';
import '../../core/network/api_result.dart';

/// Repository for all feed-related operations.
/// Wraps [FeedRemoteDataSource] and [FeedLocalDataSource].
/// All public methods return [ApiResult] so callers never catch raw exceptions.
class FeedRepository {
  final FeedRemoteDataSource _remote;
  final FeedLocalDataSource _local;
  final ProfileRemoteDataSource? _profile;
  final VaultRemoteDataSource? _vault;

  const FeedRepository({
    required FeedRemoteDataSource remote,
    required FeedLocalDataSource local,
    ProfileRemoteDataSource? profile,
    VaultRemoteDataSource? vault,
  })  : _remote = remote,
        _local = local,
        _profile = profile,
        _vault = vault;

  /// Returns a mixed list of [FeedItemModel] items built from quotes.
  /// Tries remote first; falls back to cached feed on the first page if the
  /// network call fails. Special cards (reflection / evolution) are injected
  /// at fixed intervals.
  Future<ApiResult<List<FeedItemModel>>> getFeed({
    String lang = 'en',
    String? cursor,
  }) async {
    try {
      final response = await _remote.fetchFeed(lang: lang, cursor: cursor);
      final rawList = response['data'];

      List<QuoteModel> quotes;
      if (rawList is List) {
        quotes = rawList
            .whereType<Map<String, dynamic>>()
            .map(QuoteModel.fromJson)
            .toList();
      } else {
        quotes = [];
      }

      // Cache the first page (no cursor = first page).
      if (cursor == null && quotes.isNotEmpty) {
        _local.cacheFeed(quotes);
      }

      return ApiSuccess(_buildFeedItems(quotes));
    } catch (e) {
      // Network failed — fall back to cache (first page only).
      if (cursor == null) {
        final cached = _local.getCachedFeed();
        if (cached != null && cached.isNotEmpty) {
          return ApiSuccess(_buildFeedItems(cached));
        }
      }
      return ApiError('Failed to load feed: $e');
    }
  }

  /// Fire-and-forget swipe recording.
  /// Errors are silently swallowed — a telemetry failure must never block UX.
  Future<void> recordSwipe(SwipeEventModel event) async {
    try {
      await _remote.recordSwipe(event);
    } catch (_) {
      // Intentionally ignored.
    }
  }

  /// Fire-and-forget like / unlike.
  Future<void> likeQuote(String id, bool liked) async {
    try {
      await _remote.likeQuote(id, liked);
    } catch (_) {
      // Intentionally ignored.
    }
  }

  // -------------------------------------------------------------------------
  // Vault
  // -------------------------------------------------------------------------

  Future<ApiResult<List<QuoteModel>>> getVault() async {
    try {
      final items = await _vault?.getVault() ?? [];
      return ApiSuccess(items);
    } catch (e) {
      return ApiError(e.toString());
    }
  }

  Future<void> saveToVault(String quoteId) async {
    try {
      await _vault?.saveToVault(quoteId);
    } catch (_) {}
  }

  Future<void> removeFromVault(String quoteId) async {
    try {
      await _vault?.removeFromVault(quoteId);
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Profile
  // -------------------------------------------------------------------------

  Future<void> postProfile(UserProfileModel profile) async {
    try {
      await _profile?.saveProfile(profile);
    } catch (_) {}
  }

  /// Injects special cards at fixed positions in the quote list:
  /// - After every 10 quotes → evolution card
  /// - After every 5 quotes (not 10) → reflection card
  List<FeedItemModel> _buildFeedItems(List<QuoteModel> quotes) {
    final items = <FeedItemModel>[];
    for (var i = 0; i < quotes.length; i++) {
      items.add(FeedItemModel.quote(quotes[i]));
      final position = i + 1;
      if (position % 10 == 0) {
        items.add(const FeedItemModel.evolution({}));
      } else if (position % 5 == 0) {
        items.add(const FeedItemModel.reflection());
      }
    }
    return items;
  }
}
