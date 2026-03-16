/// Centralised event logger for user interactions.
///
/// All methods currently print to the debug console. Replace the
/// `debugPrint` calls with a real analytics SDK (e.g., Firebase Analytics,
/// Mixpanel, PostHog) without changing any call sites.
class EventLogger {
  EventLogger._();

  // ------------------------------------------------------------------
  // Feed / swipe
  // ------------------------------------------------------------------

  /// Logs that the user swiped a card.
  ///
  /// [category] — quote category (e.g. `'stoicism'`)
  /// [direction] — swipe direction (`'up'`, `'down'`, `'left'`, `'right'`)
  /// [dwellMs]   — milliseconds the card was visible before the swipe
  static void logSwipe(String category, String direction, int dwellMs) {
    _log('swipe', {
      'category': category,
      'direction': direction,
      'dwell_ms': dwellMs,
    });
  }

  // ------------------------------------------------------------------
  // Likes
  // ------------------------------------------------------------------

  /// Logs that the user liked a quote.
  static void logLike(String quoteId) {
    _log('like', {'quote_id': quoteId});
  }

  // ------------------------------------------------------------------
  // Vault
  // ------------------------------------------------------------------

  /// Logs that the user saved a quote to their vault.
  static void logVaultSave(String quoteId) {
    _log('vault_save', {'quote_id': quoteId});
  }

  // ------------------------------------------------------------------
  // Share
  // ------------------------------------------------------------------

  /// Logs that the user shared a quote.
  static void logShare(String quoteId) {
    _log('share', {'quote_id': quoteId});
  }

  // ------------------------------------------------------------------
  // Challenges
  // ------------------------------------------------------------------

  /// Logs that the user completed a daily challenge.
  static void logChallengeComplete(String code) {
    _log('challenge_complete', {'code': code});
  }

  // ------------------------------------------------------------------
  // Premium
  // ------------------------------------------------------------------

  /// Logs that the user viewed the premium paywall.
  static void logPremiumView() {
    _log('premium_view', {});
  }

  /// Logs that the user initiated a premium unlock.
  static void logPremiumUnlock() {
    _log('premium_unlock', {});
  }

  // ------------------------------------------------------------------
  // Onboarding
  // ------------------------------------------------------------------

  /// Logs that the user completed onboarding.
  static void logOnboardingComplete() {
    _log('onboarding_complete', {});
  }

  // ------------------------------------------------------------------
  // Internal
  // ------------------------------------------------------------------

  static void _log(String event, Map<String, dynamic> params) {
    // ignore: avoid_print
    print('[Analytics] $event ${params.isNotEmpty ? params : ''}');
  }
}
