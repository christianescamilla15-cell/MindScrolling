import 'dart:convert';

import '../../../core/storage/local_storage.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  static const _langKey = 'mindscroll_lang';
  static const _onboardingKey = 'mindscroll_onboarding_done';
  static const _premiumKey = 'mindscroll_is_premium';
  static const _profileKey = 'mindscroll_profile';

  // ── Language ──────────────────────────────────────────────────────────────

  Future<String> getLang() async {
    return await LocalStorage.getString(_langKey) ?? 'en';
  }

  Future<void> setLang(String lang) async {
    await LocalStorage.setString(_langKey, lang);
  }

  // ── Onboarding ────────────────────────────────────────────────────────────

  Future<bool> isOnboardingDone() async {
    return await LocalStorage.getBool(_onboardingKey);
  }

  Future<void> setOnboardingDone() async {
    await LocalStorage.setBool(_onboardingKey, true);
  }

  // ── Premium ───────────────────────────────────────────────────────────────

  Future<bool> isPremium() async {
    return await LocalStorage.getBool(_premiumKey);
  }

  Future<void> setPremium(bool value) async {
    await LocalStorage.setBool(_premiumKey, value);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getProfile() async {
    final raw = await LocalStorage.getString(_profileKey);
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
    await LocalStorage.setString(_profileKey, jsonEncode(data));
  }
}
