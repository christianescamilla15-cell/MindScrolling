/// Abstract base class for all localised UI strings in MindScroll.
///
/// Add a new getter here whenever a new string is needed, then implement
/// it in [StringsEn] and [StringsEs].
abstract class AppStrings {
  // ------------------------------------------------------------------
  // General
  // ------------------------------------------------------------------
  String get appName;
  String get loading;
  String get vault;
  String get settings;
  String get streak;
  String get reflections;
  String get save;
  String get close;
  String get error;
  String get retry;

  // ------------------------------------------------------------------
  // Onboarding
  // ------------------------------------------------------------------
  String get onboardingTitle;
  String get onboardingSubtitle;
  String get onboardingNext;
  String get onboardingStart;
  String get onboardingProfile;

  // ------------------------------------------------------------------
  // Swipe direction labels
  // ------------------------------------------------------------------
  String get swipeUpLabel;    // → "Wisdom"
  String get swipeRightLabel; // → "Discipline"
  String get swipeLeftLabel;  // → "Reflection"
  String get swipeDownLabel;  // → "Philosophy"

  // ------------------------------------------------------------------
  // Profile form
  // ------------------------------------------------------------------
  String get ageRange;
  String get interest;
  String get goal;
  String get language;

  // ------------------------------------------------------------------
  // Features
  // ------------------------------------------------------------------
  String get challengeTitle;
  String get mapTitle;

  // ------------------------------------------------------------------
  // Premium / monetisation
  // ------------------------------------------------------------------
  String get premiumUnlock;
  String get premiumPrice;
  String get premiumFeature;

  // ------------------------------------------------------------------
  // Donations
  // ------------------------------------------------------------------
  String get donateTitle;
  String get donateBody;
  String get donateBtn;

  // ------------------------------------------------------------------
  // Actions / toasts
  // ------------------------------------------------------------------
  String get shareVia;
  String get savedVault;
  String get removedLike;
  String get liked;
  String get alreadyVault;
  String get streakExtended;
  String get copied;
  String get doubleTapToLike;
  String get exportImage;

  // ------------------------------------------------------------------
  // Category names
  // ------------------------------------------------------------------
  String get philosophy;
  String get stoicism;
  String get discipline;
  String get reflection;

  // ------------------------------------------------------------------
  // Category labels map — keyed by category slug
  // ------------------------------------------------------------------
  Map<String, String> get categoryLabels;
}
