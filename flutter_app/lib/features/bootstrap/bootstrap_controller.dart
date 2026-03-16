import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

/// Checks local state and returns the initial route to display.
///
/// This is a plain async class — no Riverpod state needed because the
/// decision is made once during splash and the result drives a GoRouter
/// navigation.
class BootstrapController {
  const BootstrapController();

  /// Returns '/feed' when onboarding has already been completed,
  /// otherwise '/onboarding'.
  Future<String> initialRoute() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final done = prefs.getBool(AppConstants.onboardingKey) ?? false;
      return done ? '/feed' : '/onboarding';
    } catch (_) {
      return '/onboarding';
    }
  }

  /// Ensures a device ID exists in prefs. Returns the existing or freshly
  /// created ID. Callers can use this as a fire-and-forget side-effect
  /// during bootstrap.
  Future<String> ensureDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString(AppConstants.deviceIdKey);
    if (id == null || id.isEmpty) {
      // Build a simple UUID-like identifier from timestamp + random bits.
      final ms = DateTime.now().millisecondsSinceEpoch;
      id = 'dev-$ms';
      await prefs.setString(AppConstants.deviceIdKey, id);
    }
    return id;
  }
}
