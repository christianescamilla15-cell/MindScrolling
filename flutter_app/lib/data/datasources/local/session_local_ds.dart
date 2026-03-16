import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SessionLocalDataSource {
  static const _deviceIdKey = 'mindscroll_device_id';
  static const _likedIdsKey = 'mindscroll_liked_ids';
  static const _vaultIdsKey = 'mindscroll_vault_ids';

  static const _uuid = Uuid();

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  // ── Device ID ─────────────────────────────────────────────────────────────

  /// Returns the stored device ID, or generates and persists a new UUID v4.
  Future<String> getOrCreateDeviceId() async {
    final prefs = await _prefs;
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final newId = _uuid.v4();
    await prefs.setString(_deviceIdKey, newId);
    return newId;
  }

  // ── Liked Quote IDs ───────────────────────────────────────────────────────

  Future<Set<String>> getLikedIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_likedIdsKey);
    return list?.toSet() ?? {};
  }

  Future<void> setLikedIds(Set<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_likedIdsKey, ids.toList());
  }

  // ── Vault Quote IDs ───────────────────────────────────────────────────────

  Future<Set<String>> getVaultIds() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_vaultIdsKey);
    return list?.toSet() ?? {};
  }

  Future<void> setVaultIds(Set<String> ids) async {
    final prefs = await _prefs;
    await prefs.setStringList(_vaultIdsKey, ids.toList());
  }
}
