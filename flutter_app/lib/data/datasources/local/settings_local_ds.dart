import 'dart:convert';

import '../../../core/storage/local_storage.dart';

class SettingsLocalDataSource {
  final LocalStorage _storage;

  static const _langKey = 'mindscroll_lang';
  static const _onboardingKey = 'mindscroll_onboarding_done';
  static const _premiumKey = 'mindscroll_is_premium';
  static const _profileKey = 'mindscroll_profile';

  const SettingsLocalDataSource(this._storage);

  // ── Language ──────────────────────────────────────────────────────────────

  Future<String> getLang() async {
    return await _storage.getString(_langKey) ?? 'en';
  }

  Future<void> setLang(String lang) async {
    await _storage.setString(_langKey, lang);
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  Future<bool> isOnboardingDone() async {
    return await _storage.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    await _storage.setBool(_onboardingKey, true);
  }

  // ── Premium ───────────────────────────────────────────────────────────────

  Future<bool> isPremium() async {
    return await _storage.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremium(bool value) async {
    await _storage.setBool(_premiumKey, value);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile() async {
    final raw = await _storage.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> setProfile(Map<String, dynamic> data) async {
    await _storage.setString(_profileKey, jsonEncode(data));
  }
}
