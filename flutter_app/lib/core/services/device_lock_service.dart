import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';

/// Device registration for analytics (multi-device mode — no blocking).
///
/// On first launch the hardware ID is sent to the backend for tracking.
/// All devices are allowed. No blocking occurs.
class DeviceLockService {
  DeviceLockService._();

  static const _lockStatusKey = 'device_lock_status';

  /// Always returns `true`. Registers device for analytics only.
  static Future<bool> checkOrRegister(ApiClient apiClient) async {
    final prefs = await SharedPreferences.getInstance();

    // Already registered — skip network call
    // Clear any old 'blocked' status from single-device era
    final cached = prefs.getString(_lockStatusKey);
    if (cached == 'blocked') await prefs.remove(_lockStatusKey);
    if (cached == 'allowed') return true;

    // Get hardware ID for analytics tracking
    final hardwareId = await _getHardwareId();
    if (hardwareId == null || hardwareId.length < 8) {
      // Can't determine hardware — allow anyway
      await prefs.setString(_lockStatusKey, 'allowed');
      return true;
    }

    try {
      await apiClient.post(
        '/device-lock/register',
        body: {'hardware_id': hardwareId},
      );
      await prefs.setString(_lockStatusKey, 'allowed');
    } catch (_) {
      // Network error — still allow, cache for next time
      await prefs.setString(_lockStatusKey, 'allowed');
    }
    return true;
  }

  /// Clears cached lock status (useful for testing).
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockStatusKey);
  }

  static Future<bool> _isEmulator() async {
    try {
      final info = DeviceInfoPlugin();
      final android = await info.androidInfo;
      return !android.isPhysicalDevice;
    } catch (_) {
      return false;
    }
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
