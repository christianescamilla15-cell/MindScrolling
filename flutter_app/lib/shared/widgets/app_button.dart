import 'package:flutter/material.dart';
import '../../app/theme/colors.dart';
import '../../app/theme/typography.dart';

/// A styled button used throughout MindScroll.
///
/// Supports filled (default), outlined, and loading states. Adapts its
/// background and foreground colours based on the provided [color].
///
/// Usage:
/// ```dart
/// AppButton(label: 'Begin', onPressed: _start)
/// AppButton.outlined(label: 'Skip', onPressed: _skip)
/// AppButton(label: 'Saving…', onPressed: null, isLoading: true)
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.outlined = false,
    this.icon,
    this.fullWidth = true,
  });

  /// Creates an outlined variant of [AppButton].
  const AppButton.outlined({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.isLoading = false,
    this.icon,
    this.fullWidth = true,
  }) : outlined = true;

  /// Button label text.
  final String label;

  /// Callback for tap events. Pass `null` to disable the button.
  final VoidCallback? onPressed;

  /// Accent colour. Defaults to [AppColors.stoicism] for filled buttons and
  /// [AppColors.textPrimary] for outlined buttons.
  final Color? color;

  /// When `true`, replaces the label with a small [CircularProgressIndicator].
  final bool isLoading;

  /// When `true`, renders an outlined style instead of filled.
  final bool outlined;

  /// Optional leading icon.
  final Widget? icon;

  /// When `true` (default), stretches the button to fill its parent's width.
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ??
        (outlined ? AppColors.textPrimary : AppColors.stoicism);

    final bool disabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                outlined ? effectiveColor : AppColors.background,
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                icon!,
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: AppTypography.buttonLabel.copyWith(
                  color: outlined ? effectiveColor : AppColors.background,
                ),
              ),
            ],
          );

    final borderRadius = BorderRadius.circular(24);

    if (outlined) {
      return SizedBox(
        width: fullWidth ? double.infinity : null,
        child: OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            side: BorderSide(
              color: disabled
                  ? effectiveColor.withOpacity(0.3)
                  : effectiveColor,
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            splashFactory: NoSplash.splashFactory,
          ),
          child: child,
        ),
      );
    }

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              disabled ? effectiveColor.withOpacity(0.4) : effectiveColor,
          foregroundColor: AppColors.background,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding:
              const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: borderRadius),
          splashFactory: NoSplash.splashFactory,
        ),
        child: child,
      ),
    );
  }
}
