import 'package:flutter/material.dart';
import 'colors.dart';

class AppTypography {
  AppTypography._();

  static const String _playfair = 'Playfair';
  static const String _dmSans = 'DMSans';

  // ------------------------------------------------------------------
  // Display styles — Playfair Display
  // ------------------------------------------------------------------

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _playfair,
    fontSize: 28,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _playfair,
    fontSize: 22,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _playfair,
    fontSize: 18,
    fontStyle: FontStyle.normal,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ------------------------------------------------------------------
  // Quote card text — Playfair italic, fluid size
  // The actual font size is clamped in the widget using MediaQuery
  // but we supply the base style here.
  // ------------------------------------------------------------------

  /// Base quote text style. Callers should copy and override fontSize
  /// using MediaQuery.textScalerOf for fluid sizing (18–24 sp).
  static const TextStyle quoteText = TextStyle(
    fontFamily: _playfair,
    fontSize: 21, // midpoint of 18–24 range
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.normal,
    color: Color(0xFFF5F0E8),
    height: 1.65,
    letterSpacing: 0.1,
  );

  /// Returns a quote style with a clamped fontSize between [min] and [max]
  /// based on a [base] logical pixel width (usually screen width).
  static TextStyle quoteTextScaled({
    required double screenWidth,
    double min = 18,
    double max = 24,
    double referenceWidth = 390,
  }) {
    final scale = screenWidth / referenceWidth;
    final size = (21 * scale).clamp(min, max);
    return quoteText.copyWith(fontSize: size);
  }

  // ------------------------------------------------------------------
  // Author / attribution
  // ------------------------------------------------------------------

  static const TextStyle authorText = TextStyle(
    fontFamily: _dmSans,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
    letterSpacing: 0.02,
  );

  // ------------------------------------------------------------------
  // Labels
  // ------------------------------------------------------------------

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _dmSans,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.12 * 11, // 0.12em → absolute pixels
    height: 1.2,
  );

  static TextStyle labelSmallColored(Color color) =>
      labelSmall.copyWith(color: color);

  // ------------------------------------------------------------------
  // Body
  // ------------------------------------------------------------------

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _dmSans,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _dmSans,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.45,
  );

  // ------------------------------------------------------------------
  // Utility
  // ------------------------------------------------------------------

  static const TextStyle buttonLabel = TextStyle(
    fontFamily: _dmSans,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.02,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _dmSans,
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.textMuted,
    height: 1.4,
  );
}
