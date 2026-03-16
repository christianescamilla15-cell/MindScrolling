import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core backgrounds
  static const Color background = Color(0xFF0F0F13);
  static const Color surface = Color(0xFF1C1C22);
  static const Color surfaceVariant = Color(0xFF1E1E27);

  // Category accent colors
  static const Color stoicism = Color(0xFF14B8A6); // teal
  static const Color philosophy = Color(0xFFF59E0B); // amber
  static const Color discipline = Color(0xFFF97316); // orange
  static const Color reflection = Color(0xFFA78BFA); // purple

  // Text
  static const Color textPrimary = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0x80F5F0E8); // 50% opacity
  static const Color textMuted = Color(0x40F5F0E8); // 25% opacity

  // Action colors
  static const Color like = Color(0xFFF97316);
  static const Color vault = Color(0xFF14B8A6);
  static const Color streak = Color(0xFFF59E0B);

  // Borders
  static const Color border = Color(0x12FFFFFF);
  static const Color borderStrong = Color(0x20FFFFFF);

  // Utility
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  /// Returns the accent color for a given category slug.
  /// Defaults to [textMuted] for unknown categories.
  static Color categoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'stoicism':
        return stoicism;
      case 'philosophy':
        return philosophy;
      case 'discipline':
        return discipline;
      case 'reflection':
        return reflection;
      default:
        return textMuted;
    }
  }

  /// Returns a very subtle background tint for category cards.
  static Color categoryColorSubtle(String category) {
    return categoryColor(category).withOpacity(0.08);
  }
}
