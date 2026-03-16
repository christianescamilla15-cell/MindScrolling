import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';

enum SwipeDirection { up, down, left, right }

extension SwipeDirectionX on SwipeDirection {
  String get value => name;

  String get category => const {
        'up': 'stoicism',
        'right': 'discipline',
        'left': 'reflection',
        'down': 'philosophy',
      }[name]!;

  String get label => const {
        'up': 'Wisdom',
        'right': 'Discipline',
        'left': 'Reflection',
        'down': 'Philosophy',
      }[name]!;

  Color get color {
    switch (this) {
      case SwipeDirection.up:
        return AppColors.stoicism;
      case SwipeDirection.right:
        return AppColors.discipline;
      case SwipeDirection.left:
        return AppColors.reflection;
      case SwipeDirection.down:
        return AppColors.philosophy;
    }
  }

  String get arrow => const {
        'up': '↑',
        'right': '→',
        'left': '←',
        'down': '↓',
      }[name]!;

  /// Returns the [SwipeDirection] for a raw direction string such as 'up'.
  static SwipeDirection fromString(String value) {
    return SwipeDirection.values.firstWhere(
      (d) => d.name == value.toLowerCase(),
      orElse: () => SwipeDirection.up,
    );
  }
}
