import 'package:flutter/material.dart';

import '../../app/localization/app_strings.dart';
import '../../app/localization/strings_en.dart';
import '../../app/localization/strings_es.dart';
import '../../app/theme/colors.dart';

/// Convenience extensions on [BuildContext] for frequently used lookups.
///
/// Usage:
/// ```dart
/// final bg = context.colors.background;
/// final isDark = context.isDark;
/// final size = context.screenSize;
/// Text(context.tr.appName, style: context.textTheme.displayLarge)
/// ```
extension ContextExtensions on BuildContext {
  // ---------------------------------------------------------------------------
  // Theme helpers
  // ---------------------------------------------------------------------------

  /// Returns the [_AppColorsProxy] proxy which exposes all [AppColors]
  /// static constants as instance getters so call sites can write
  /// `context.colors.background` without a direct [AppColors] import.
  _AppColorsProxy get colors => const _AppColorsProxy();

  /// Shortcut for [Theme.of(this).textTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns `true` when the active [ThemeData] uses [Brightness.dark].
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  // ---------------------------------------------------------------------------
  // Layout helpers
  // ---------------------------------------------------------------------------

  /// The logical size of the screen. Alias for [MediaQuery.sizeOf].
  Size get screenSize => MediaQuery.sizeOf(this);

  // ---------------------------------------------------------------------------
  // Localization helper
  // ---------------------------------------------------------------------------

  /// Returns the [AppStrings] implementation matching the active locale.
  ///
  /// Falls back to English for any unsupported locale code.
  AppStrings get tr {
    final languageCode = Localizations.localeOf(this).languageCode;
    switch (languageCode) {
      case 'es':
        return const StringsEs();
      case 'en':
      default:
        return const StringsEn();
    }
  }
}

// ---------------------------------------------------------------------------
// Proxy — mirrors every [AppColors] static constant as an instance getter.
// This avoids requiring callers to import [AppColors] directly.
// ---------------------------------------------------------------------------

/// A thin const proxy around [AppColors] static constants.
class _AppColorsProxy {
  const _AppColorsProxy();

  Color get background => AppColors.background;
  Color get surface => AppColors.surface;
  Color get surfaceVariant => AppColors.surfaceVariant;

  Color get stoicism => AppColors.stoicism;
  Color get philosophy => AppColors.philosophy;
  Color get discipline => AppColors.discipline;
  Color get reflection => AppColors.reflection;

  Color get textPrimary => AppColors.textPrimary;
  Color get textSecondary => AppColors.textSecondary;
  Color get textMuted => AppColors.textMuted;

  Color get like => AppColors.like;
  Color get vault => AppColors.vault;
  Color get streak => AppColors.streak;

  Color get border => AppColors.border;
  Color get borderStrong => AppColors.borderStrong;

  Color get transparent => AppColors.transparent;
  Color get white => AppColors.white;
  Color get black => AppColors.black;

  /// Delegates to [AppColors.categoryColor].
  Color categoryColor(String category) => AppColors.categoryColor(category);

  /// Delegates to [AppColors.categoryColorSubtle].
  Color categoryColorSubtle(String category) =>
      AppColors.categoryColorSubtle(category);
}
