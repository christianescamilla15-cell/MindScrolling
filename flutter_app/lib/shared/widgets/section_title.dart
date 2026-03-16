import 'package:flutter/material.dart';

import '../../app/theme/colors.dart';

/// A small uppercase section heading used as a divider between content groups.
///
/// Renders its [label] in DM Sans SemiBold at 13 sp with 60 % white opacity,
/// uppercased via [String.toUpperCase].
///
/// Usage:
/// ```dart
/// const SectionTitle(label: 'Saved quotes')
/// SectionTitle(label: 'Daily challenge', color: AppColors.streak)
/// ```
class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.label,
    this.color,
    this.trailing,
  });

  /// The section heading text. Always displayed in uppercase.
  final String label;

  /// Optional colour override. Defaults to [AppColors.textSecondary]
  /// (white at 50 % opacity), which is the closest constant to white60.
  /// Pass a custom colour when the section belongs to a specific category.
  final Color? color;

  /// Optional trailing widget (e.g. a "See all" link).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // white60 = Colors.white with 60 % opacity = 0x99FFFFFF
    const white60 = Color(0x99FFFFFF);

    final style = TextStyle(
      fontFamily: 'DMSans',
      fontSize: 13,
      fontWeight: FontWeight.w600, // SemiBold
      color: color ?? white60,
      letterSpacing: 0.08 * 13, // ~1 px tracking for uppercase labels
      height: 1.2,
    );

    final text = Text(label.toUpperCase(), style: style);

    if (trailing != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [text, trailing!],
      );
    }

    return text;
  }
}
