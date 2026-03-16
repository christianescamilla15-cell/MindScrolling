/// Application-wide constants for keys, defaults, and thresholds.
class AppConstants {
  AppConstants._();

  // ------------------------------------------------------------------
  // SharedPreferences / SecureStorage keys
  // ------------------------------------------------------------------

  /// Key that stores whether the user has completed onboarding.
  static const String onboardingKey = 'mindscroll_onboarding_done';

  /// Key that stores the generated device UUID.
  static const String deviceIdKey = 'mindscroll_device_id';

  /// Key that stores the user's preferred language code.
  static const String langKey = 'mindscroll_lang';

  /// Key that stores whether the user has unlocked premium.
  static const String premiumKey = 'mindscroll_premium';

  /// Key that stores the serialised profile JSON string.
  static const String profileKey = 'mindscroll_profile';

  // ------------------------------------------------------------------
  // Localisation
  // ------------------------------------------------------------------

  /// Default language code.
  static const String defaultLang = 'en';

  /// All supported language codes.
  static const List<String> supportedLangs = ['en', 'es'];

  // ------------------------------------------------------------------
  // Feed
  // ------------------------------------------------------------------

  /// Number of quotes to request per feed page.
  static const int feedPageSize = 20;

  /// After this many seen quote IDs have accumulated in the local set,
  /// reset it to avoid unbounded growth.
  static const int seenQuotesResetThreshold = 500;

  // ------------------------------------------------------------------
  // Streak
  // ------------------------------------------------------------------

  /// Minimum number of swipes in a session to count toward the streak.
  static const int streakThreshold = 5;
}
