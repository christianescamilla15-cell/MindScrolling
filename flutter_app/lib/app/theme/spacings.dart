/// Centralised spacing tokens for MindScrolling.
///
/// Use these instead of literal integers in [EdgeInsets], [SizedBox], etc.
/// This ensures visual consistency and makes global adjustments trivial.
class AppSpacings {
  AppSpacings._();

  static const double xxs = 2;
  static const double xs  = 4;
  static const double sm  = 8;
  static const double md  = 16;
  static const double lg  = 24;
  static const double xl  = 32;
  static const double xxl = 48;

  /// Standard horizontal page padding.
  static const double pagePadding = 20;

  /// Card internal padding.
  static const double cardPadding = 20;

  /// Section gap between major UI blocks.
  static const double sectionGap = 28;
}
