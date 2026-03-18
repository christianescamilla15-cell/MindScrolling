import 'dart:convert';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';

/// Centralised event logger for user interactions.
///
/// Fires key funnel events to POST /analytics/event (fire-and-forget,
/// no throw on failure). All events also print to the debug console.
/// Replace the backend call with any SDK (Firebase, Mixpanel, PostHog)
/// without changing call sites.
class EventLogger {
  EventLogger._();

  static const String _appVersion = '1.1.0';

  // ------------------------------------------------------------------
  // Internal HTTP sender — fire-and-forget, never throws
  // ------------------------------------------------------------------

  static String? _deviceId;

  /// Set once from [DeviceIdService] at app startup so events include device_id.
  static void setDeviceId(String id) => _deviceId = id;

  static void _send(String eventType, [Map<String, dynamic>? properties]) {
    final body = jsonEncode({
      'event_type': eventType,
      'app_version': _appVersion,
      if (properties != null && properties.isNotEmpty) 'properties': properties,
    });
    final headers = {
      'Content-Type': 'application/json',
      if (_deviceId != null) 'X-Device-ID': _deviceId!,
    };
    http
        .post(
          Uri.parse('${ApiConstants.baseUrl}/analytics/event'),
          headers: headers,
          body: body,
        )
        .ignore(); // fire-and-forget
  }

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
    _send('onboarding_completed');
  }

  // ------------------------------------------------------------------
  // App lifecycle
  // ------------------------------------------------------------------

  /// Fires once per cold launch. Call after device ID is available.
  static void logAppOpen() {
    _log('app_opened', {'app_version': _appVersion});
    _send('app_opened');
  }

  // ------------------------------------------------------------------
  // Internal
  // ------------------------------------------------------------------

  static void _log(String event, Map<String, dynamic> params) {
    // ignore: avoid_print
    print('[Analytics] $event ${params.isNotEmpty ? params : ''}');
  }
}
