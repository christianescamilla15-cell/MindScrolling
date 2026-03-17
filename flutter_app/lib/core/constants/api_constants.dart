/// All API endpoint constants for MindScroll.
///
/// [baseUrl] falls back to the Android emulator loopback address when no
/// compile-time constant `API_BASE_URL` is provided. Override at build time:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.x:3000
class ApiConstants {
  ApiConstants._();

  /// Base URL. Override with `--dart-define=API_BASE_URL=<url>`.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  // ------------------------------------------------------------------
  // Feed
  // ------------------------------------------------------------------

  /// GET /quotes/feed?lang=en&cursor=<uuid>&limit=20
  static const String feedPath = '/quotes/feed';

  // ------------------------------------------------------------------
  // Swipes
  // ------------------------------------------------------------------

  /// POST /swipes
  static const String swipePath = '/swipes';

  // ------------------------------------------------------------------
  // Likes
  // ------------------------------------------------------------------

  /// POST /quotes/:id/like
  static String likePath(String id) => '/quotes/$id/like';

  // ------------------------------------------------------------------
  // Vault
  // ------------------------------------------------------------------

  /// GET /vault  |  POST /vault
  static const String vaultPath = '/vault';

  /// DELETE /vault/:quote_id
  static String vaultItemPath(String id) => '/vault/$id';

  // ------------------------------------------------------------------
  // Profile
  // ------------------------------------------------------------------

  /// GET /profile  |  POST /profile
  static const String profilePath = '/profile';

  // ------------------------------------------------------------------
  // Challenges
  // ------------------------------------------------------------------

  /// GET /challenges/today
  static const String challengeTodayPath = '/challenges/today';

  /// POST /challenges/:id/progress
  static String challengeProgressPath(String id) =>
      '/challenges/$id/progress';

  // ------------------------------------------------------------------
  // Map
  // ------------------------------------------------------------------

  /// GET /map
  static const String mapPath = '/map';

  /// POST /map/snapshot
  static const String mapSnapshotPath = '/map/snapshot';

  // ------------------------------------------------------------------
  // Premium
  // ------------------------------------------------------------------

  /// GET /premium/status
  static const String premiumStatusPath = '/premium/status';

  /// POST /premium/unlock
  static const String premiumUnlockPath = '/premium/unlock';

  // ------------------------------------------------------------------
  // Stats
  // ------------------------------------------------------------------

  /// GET /stats
  static const String statsPath = '/stats';

  // ------------------------------------------------------------------
  // Health
  // ------------------------------------------------------------------

  /// GET /health
  static const String healthPath = '/health';

  // ------------------------------------------------------------------
  // Insights
  // ------------------------------------------------------------------

  /// GET /insights/weekly
  static const String insightsWeeklyPath = '/insights/weekly';
}
