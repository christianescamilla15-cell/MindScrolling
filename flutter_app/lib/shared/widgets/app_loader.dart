import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';

/// A centered, teal-coloured circular progress indicator used throughout
/// MindScroll as the default loading state.
///
/// Usage:
/// ```dart
/// // Full-screen loading
/// const AppLoader()
///
/// // Inline loading with a fixed size
/// const AppLoader(size: 24)
/// ```
class AppLoader extends StatelessWidget {
  const AppLoader({
    super.key,
    this.size,
    this.color,
    this.strokeWidth = 2.5,
  });

  /// Optional fixed size for the indicator container.
  /// When null the indicator takes its natural size.
  final double? size;

  /// Indicator colour. Defaults to [AppColors.stoicism].
  final Color? color;

  /// Stroke width of the progress indicator arc.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final indicator = CircularProgressIndicator(
      strokeWidth: strokeWidth,
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? AppColors.stoicism,
      ),
    );

    if (size != null) {
      return Center(
        child: SizedBox(
          width: size,
          height: size,
          child: indicator,
        ),
      );
    }

    return Center(child: indicator);
  }
}
