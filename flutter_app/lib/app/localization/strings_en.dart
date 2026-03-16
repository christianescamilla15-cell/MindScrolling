import 'app_strings.dart';

/// English string implementations.
class StringsEn implements AppStrings {
  const StringsEn();

  // ------------------------------------------------------------------
  // General
  // ------------------------------------------------------------------
  @override
  String get appName => 'MindScroll';

  @override
  String get loading => 'Loading…';

  @override
  String get vault => 'Vault';

  @override
  String get settings => 'Settings';

  @override
  String get streak => 'Streak';

  @override
  String get reflections => 'Reflections';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Retry';

  // ------------------------------------------------------------------
  // Onboarding
  // ------------------------------------------------------------------
  @override
  String get onboardingTitle => 'Scroll with intention.';

  @override
  String get onboardingSubtitle =>
      'Replace mindless scrolling with wisdom that lasts.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Begin your journey';

  @override
  String get onboardingProfile => 'Personalise';

  // ------------------------------------------------------------------
  // Swipe direction labels
  // ------------------------------------------------------------------
  @override
  String get swipeUpLabel => 'Wisdom';

  @override
  String get swipeRightLabel => 'Discipline';

  @override
  String get swipeLeftLabel => 'Reflection';

  @override
  String get swipeDownLabel => 'Philosophy';

  // ------------------------------------------------------------------
  // Profile form
  // ------------------------------------------------------------------
  @override
  String get ageRange => 'Age range';

  @override
  String get interest => 'Main interest';

  @override
  String get goal => 'Personal goal';

  @override
  String get language => 'Language';

  // ------------------------------------------------------------------
  // Features
  // ------------------------------------------------------------------
  @override
  String get challengeTitle => "Today's Challenge";

  @override
  String get mapTitle => 'Philosophy Map';

  // ------------------------------------------------------------------
  // Premium / monetisation
  // ------------------------------------------------------------------
  @override
  String get premiumUnlock => 'Unlock Premium';

  @override
  String get premiumPrice => '\$2.99 once — forever yours';

  @override
  String get premiumFeature => 'Premium feature';

  // ------------------------------------------------------------------
  // Donations
  // ------------------------------------------------------------------
  @override
  String get donateTitle => 'Support MindScroll';

  @override
  String get donateBody =>
      'MindScroll is free and ad-free. If it has brought you '
      'value, consider buying me a coffee — it keeps the lights on.';

  @override
  String get donateBtn => 'Buy me a coffee ☕';

  // ------------------------------------------------------------------
  // Actions / toasts
  // ------------------------------------------------------------------
  @override
  String get shareVia => 'Share via…';

  @override
  String get savedVault => 'Saved to vault';

  @override
  String get removedLike => 'Removed from likes';

  @override
  String get liked => 'Liked!';

  @override
  String get alreadyVault => 'Already in your vault';

  @override
  String get streakExtended => 'Streak extended 🔥';

  @override
  String get copied => 'Copied to clipboard';

  @override
  String get doubleTapToLike => 'Double-tap to like';

  @override
  String get exportImage => 'Export as image';

  // ------------------------------------------------------------------
  // Category names
  // ------------------------------------------------------------------
  @override
  String get philosophy => 'Philosophy';

  @override
  String get stoicism => 'Stoicism';

  @override
  String get discipline => 'Discipline';

  @override
  String get reflection => 'Reflection';

  // ------------------------------------------------------------------
  // Category labels map
  // ------------------------------------------------------------------
  @override
  Map<String, String> get categoryLabels => const {
        'stoicism': 'Stoicism',
        'philosophy': 'Philosophy',
        'discipline': 'Discipline',
        'reflection': 'Reflection',
      };
}
