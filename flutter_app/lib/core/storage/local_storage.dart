import 'package:shared_preferences/shared_preferences.dart';

/// Thin static wrapper around [SharedPreferences] for typed key/value access.
///
/// All methods are static so callers can use `LocalStorage.getString(key)`
/// without managing an instance. [SharedPreferences] is already a singleton
/// internally, so there is no additional overhead.
class LocalStorage {
  LocalStorage._();

  // ------------------------------------------------------------------
  // String
  // ------------------------------------------------------------------

  static Future<void> setString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // ------------------------------------------------------------------
  // Bool
  // ------------------------------------------------------------------

  static Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getBool(
    String key, {
    bool defaultValue = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }

  // ------------------------------------------------------------------
  // Int
  // ------------------------------------------------------------------

  static Future<void> setInt(String key, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key);
  }

  // ------------------------------------------------------------------
  // String list
  // ------------------------------------------------------------------

  static Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }

  static Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  // ------------------------------------------------------------------
  // Removal / clearing
  // ------------------------------------------------------------------

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> containsKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(key);
  }
}
