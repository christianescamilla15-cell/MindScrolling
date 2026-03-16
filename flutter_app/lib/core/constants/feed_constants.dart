import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

/// Constants related to the quote feed, swipe mechanics, and category weights.
class FeedConstants {
  FeedConstants._();

  // ------------------------------------------------------------------
  // Category accent colors (mirrors AppColors for convenience)
  // ------------------------------------------------------------------

  static const Map<String, Color> categoryColors = {
    'stoicism': AppColors.stoicism,
    'philosophy': AppColors.philosophy,
    'discipline': AppColors.discipline,
    'reflection': AppColors.reflection,
  };

  // ------------------------------------------------------------------
  // Category labels
  // ------------------------------------------------------------------

  static const Map<String, String> categoryLabelsEn = {
    'stoicism': 'Stoicism',
    'philosophy': 'Philosophy',
    'discipline': 'Discipline',
    'reflection': 'Reflection',
  };

  static const Map<String, String> categoryLabelsEs = {
    'stoicism': 'Estoicismo',
    'philosophy': 'Filosofía',
    'discipline': 'Disciplina',
    'reflection': 'Reflexión',
  };

  // ------------------------------------------------------------------
  // Swipe directions
  // ------------------------------------------------------------------

  static const String swipeUp = 'up';
  static const String swipeDown = 'down';
  static const String swipeLeft = 'left';
  static const String swipeRight = 'right';

  static const List<String> swipeDirections = [
    swipeUp,
    swipeDown,
    swipeLeft,
    swipeRight,
  ];

  // ------------------------------------------------------------------
  // Direction ↔ category mappings
  // ------------------------------------------------------------------

  /// Maps swipe direction to the category it surfaces.
  static const Map<String, String> directionToCategory = {
    swipeUp: 'stoicism',
    swipeRight: 'discipline',
    swipeLeft: 'reflection',
    swipeDown: 'philosophy',
  };

  /// Maps category to its corresponding swipe direction.
  static const Map<String, String> categoryToDirection = {
    'stoicism': swipeUp,
    'discipline': swipeRight,
    'reflection': swipeLeft,
    'philosophy': swipeDown,
  };

  // ------------------------------------------------------------------
  // Feed weighting
  // ------------------------------------------------------------------

  /// Default weight applied to each category when computing a weighted feed.
  static const int baseWeight = 5;

  /// Multiplier applied to a category's weight when the user has liked
  /// at least one quote from it (signals affinity).
  static const int likeWeightMultiplier = 3;
}
