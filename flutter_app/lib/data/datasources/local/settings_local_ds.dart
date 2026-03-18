import 'dart:convert';

import '../../../core/storage/local_storage.dart';

class SettingsLocalDataSource {
  const SettingsLocalDataSource();

  static const _langKey = 'mindscroll_lang';
  static const _onboardingKey = 'mindscroll_onboarding_done';
  static const _premiumKey = 'mindscroll_is_premium';
  static const _ownedPacksKey = 'mindscroll_owned_packs';
  static const _userStateKey = 'mindscroll_user_state';
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

  Future<List<String>> getOwnedPacks() async {
    final raw = await LocalStorage.getString(_ownedPacksKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded.whereType<String>().toList();
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<void> setOwnedPacks(List<String> packs) async {
    await LocalStorage.setString(_ownedPacksKey, jsonEncode(packs));
  }

  Future<String?> getUserState() async {
    return LocalStorage.getString(_userStateKey);
  }

  Future<void> setUserState(String? state) async {
    if (state != null) {
      await LocalStorage.setString(_userStateKey, state);
    }
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
