import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/locale_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class SettingsState {
  /// Current language code — either 'en' or 'es'.
  final String lang;

  const SettingsState({
    this.lang = AppConstants.defaultLang,
  });

  SettingsState copyWith({String? lang}) {
    return SettingsState(lang: lang ?? this.lang);
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------

class SettingsNotifier extends AsyncNotifier<SettingsState> {
  @override
  Future<SettingsState> build() async {
    final saved = await LocalStorage.getString(AppConstants.langKey);
    if (saved != null && AppConstants.supportedLangs.contains(saved)) {
      return SettingsState(lang: saved);
    }
    // No preference saved — detect device locale and default to it if supported.
    final lang = LocaleUtils.detectLanguage();
    return SettingsState(lang: lang);
  }

  /// Persists the selected language code to SharedPreferences.
  Future<void> setLang(String lang) async {
    if (!AppConstants.supportedLangs.contains(lang)) return;
    await LocalStorage.setString(AppConstants.langKey, lang);
    final current = state.valueOrNull ?? const SettingsState();
    state = AsyncData(current.copyWith(lang: lang));
  }

  /// Clears ALL MindScroll data (vault, likes, preferences, map, onboarding, premium cache).
  Future<void> resetExperience() async {
    final prefs = await SharedPreferences.getInstance();

    // Preserve trial start date — user can't restart trial by resetting
    final trialStart = prefs.getString('mindscroll_trial_start');

    // Clear all local mindscroll keys
    final keys = prefs.getKeys().where((k) => k.startsWith('mindscroll')).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }

    // Restore trial date so it can't be exploited
    if (trialStart != null) {
      await prefs.setString('mindscroll_trial_start', trialStart);
    }
  }

  /// Legacy alias — delegates to resetExperience.
  Future<void> resetOnboarding() async {
    await resetExperience();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// Convenience sync provider — returns current settings with defaults fallback.
final settingsStateProvider = Provider<SettingsState>((ref) {
  return ref.watch(settingsControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const SettingsState(),
      );
});
