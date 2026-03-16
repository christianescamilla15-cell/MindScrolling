import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/storage/local_storage.dart';

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
    final deviceLang =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final lang = AppConstants.supportedLangs.contains(deviceLang)
        ? deviceLang
        : AppConstants.defaultLang;
    return SettingsState(lang: lang);
  }

  /// Persists the selected language code to SharedPreferences.
  Future<void> setLang(String lang) async {
    if (!AppConstants.supportedLangs.contains(lang)) return;
    await LocalStorage.setString(AppConstants.langKey, lang);
    final current = state.valueOrNull ?? const SettingsState();
    state = AsyncData(current.copyWith(lang: lang));
  }

  /// Clears the onboarding completion flag so the onboarding flow is
  /// shown again on next app start.
  Future<void> resetOnboarding() async {
    await LocalStorage.remove(AppConstants.onboardingKey);
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
