import 'package:flutter/services.dart';

/// Lightweight haptic feedback utility for MindScrolling.
///
/// Provides premium-feeling microinteractions:
/// - [lightImpact] — swipe, like
/// - [mediumImpact] — vault save, restore success
/// - [heavyImpact] — challenge complete, premium unlock
/// - [selectionClick] — track select, toggle
/// - [warningFeedback] — limit reached, error
///
/// Future: add user setting to disable haptics.
class HapticsService {
  HapticsService._();

  /// Light tap — for swipes, likes, minor interactions.
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium tap — for vault saves, successful actions.
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy tap — for major milestones (challenge complete, premium unlock).
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Subtle click — for selection changes (toggles, track picker).
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Warning vibration — for limits reached, errors.
  static Future<void> warningFeedback() async {
    await HapticFeedback.vibrate();
  }
}
