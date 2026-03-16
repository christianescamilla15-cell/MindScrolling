import 'dart:io' show Platform;

import '../../app/localization/app_strings.dart';
import '../../app/localization/strings_en.dart';
import '../../app/localization/strings_es.dart';
import '../constants/app_constants.dart';

/// Utilities for resolving the user's locale and providing localised strings.
class LocaleUtils {
  LocaleUtils._();

  /// Detects the device language from [Platform.localeName].
  ///
  /// Returns `'es'` if the locale starts with `'es'`, otherwise returns
  /// the default language (`'en'`).
  static String detectLanguage() {
    try {
      final localeName = Platform.localeName; // e.g. "es_MX", "en_US"
      if (localeName.toLowerCase().startsWith('es')) {
        return 'es';
      }
    } catch (_) {
      // Platform.localeName may throw on web; fall through to default.
    }
    return AppConstants.defaultLang;
  }

  /// Returns the [AppStrings] implementation for the given language code.
  ///
  /// Falls back to [StringsEn] for any unsupported language.
  static AppStrings stringsForLang(String lang) {
    switch (lang) {
      case 'es':
        return const StringsEs();
      case 'en':
      default:
        return const StringsEn();
    }
  }
}
