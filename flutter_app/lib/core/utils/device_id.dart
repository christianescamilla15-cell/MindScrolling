import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';

/// Service that provides a stable, randomly-generated device identifier.
///
/// The ID is created once on first launch and persisted in
/// [SharedPreferences] so it survives app restarts but is reset on
/// a fresh install.
class DeviceIdService {
  DeviceIdService._();

  static const _uuid = Uuid();

  /// Returns the existing device ID from storage, or generates a new
  /// UUID v4, saves it, and returns it.
  static Future<String> getOrCreate() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(AppConstants.deviceIdKey);
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }
    final newId = _uuid.v4();
    await prefs.setString(AppConstants.deviceIdKey, newId);
    return newId;
  }

  /// Clears the stored device ID. Useful during testing or on sign-out.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.deviceIdKey);
  }
}
