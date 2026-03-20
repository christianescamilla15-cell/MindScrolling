import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';

/// Manages single-device lock.
///
/// On first launch the real Android hardware ID is sent to the backend.
/// The backend allows only ONE hardware ID ever. If a second device tries
/// to register, the backend returns { allowed: false } and we block the app.
class DeviceLockService {
  DeviceLockService._();

  static const _lockStatusKey = 'device_lock_status';

  /// Returns `true` if this device is allowed to run the app.
  static Future<bool> checkOrRegister(ApiClient apiClient) async {
    final prefs = await SharedPreferences.getInstance();

    // If already verified in a previous session, skip network call
    final cached = prefs.getString(_lockStatusKey);
    if (cached == 'allowed') return true;
    if (cached == 'blocked') return false;

    // Get real hardware Android ID
    final hardwareId = await _getHardwareId();
    if (hardwareId == null || hardwareId.length < 8) {
      // Can't determine hardware — block to be safe
      return false;
    }

    try {
      final response = await apiClient.post(
        '/device-lock/register',
        body: {'hardware_id': hardwareId},
      );

      final allowed = response['allowed'] == true;
      await prefs.setString(_lockStatusKey, allowed ? 'allowed' : 'blocked');
      return allowed;
    } catch (_) {
      // Network error on first launch — allow temporarily (will re-check next launch)
      // Don't cache so it re-checks next time
      return true;
    }
  }

  /// Clears cached lock status (useful for testing).
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockStatusKey);
  }

  static Future<String?> _getHardwareId() async {
    try {
      final info = DeviceInfoPlugin();
      final android = await info.androidInfo;
      // android.id is the ANDROID_ID (Settings.Secure)
      // Unique per device + app signing key combo, persists across reinstalls
      return android.id;
    } catch (_) {
      return null;
    }
  }
}
