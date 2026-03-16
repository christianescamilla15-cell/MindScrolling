/// In-memory TTL cache.
///
/// Values are stored in a plain [Map] with an associated expiry timestamp.
/// Nothing is persisted to disk — the cache resets on every app restart,
/// making it suitable for session-scoped data such as API responses.
///
/// Usage:
/// ```dart
/// final cache = CacheStorage();
/// cache.set('feed', quotes, ttl: Duration(minutes: 3));
/// final cached = cache.get<List<Quote>>('feed');
/// ```
class CacheStorage {
  CacheStorage();

  final Map<String, _CacheEntry> _store = {};

  // ------------------------------------------------------------------
  // Write
  // ------------------------------------------------------------------

  /// Stores [value] under [key] with the given [ttl] (default 5 minutes).
  ///
  /// Overwrites any existing entry for the same key.
  void set(
    String key,
    dynamic value, {
    Duration ttl = const Duration(minutes: 5),
  }) {
    _store[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl),
    );
  }

  // ------------------------------------------------------------------
  // Read
  // ------------------------------------------------------------------

  /// Returns the cached value cast to [T], or `null` if the entry is
  /// absent or has expired.
  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    if (entry.value is T) return entry.value as T;
    return null;
  }

  /// Returns `true` if [key] exists and has not expired.
  bool has(String key) => get<dynamic>(key) != null;

  // ------------------------------------------------------------------
  // Invalidation
  // ------------------------------------------------------------------

  /// Removes the entry for [key] regardless of expiry.
  void invalidate(String key) => _store.remove(key);

  /// Removes all entries from the cache.
  void clear() => _store.clear();

  /// Removes all entries that have already expired.
  void evictExpired() {
    _store.removeWhere((_, entry) => entry.isExpired);
  }
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

class _CacheEntry {
  _CacheEntry({required this.value, required this.expiresAt});

  final dynamic value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
