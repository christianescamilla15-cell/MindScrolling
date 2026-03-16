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
  String get premiumPrice => r'$2.99 once — forever yours';

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

  // ------------------------------------------------------------------
  // Navigation bottom bar
  // ------------------------------------------------------------------
  @override
  String get feed => 'Feed';

  @override
  String get map => 'Map';

  @override
  String get insight => 'Insight';

  // ------------------------------------------------------------------
  // Settings screen
  // ------------------------------------------------------------------
  @override
  String get navigateTo => 'Navigate to';

  @override
  String get about => 'About';

  @override
  String get reset => 'Reset';

  @override
  String get philosophyMap => 'Philosophy Map';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get premium => 'Premium';

  @override
  String get donations => 'Donations';

  @override
  String get appVersion => 'App Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get resetOnboarding => 'Reset Onboarding';

  @override
  String get resetOnboardingTitle => 'Reset Onboarding?';

  @override
  String get resetOnboardingMsg =>
      'The onboarding flow will be shown again on the next app restart.';

  @override
  String get cancel => 'Cancel';

  @override
  String get onboardingResetDone =>
      'Onboarding reset. Restart the app to re-run it.';

  @override
  String get couldNotOpenPrivacy => 'Could not open privacy policy';

  // ------------------------------------------------------------------
  // Feed screen
  // ------------------------------------------------------------------
  @override
  String get couldNotLoadQuotes => 'Could not load quotes.';

  @override
  String get noQuotesAvailable => 'No quotes available.';

  @override
  String get noMoreQuotes =>
      'No more quotes right now.\nCheck your connection or refresh to fetch more.';

  @override
  String get tryAgain => 'Try again';

  // ------------------------------------------------------------------
  // Onboarding screen
  // ------------------------------------------------------------------
  @override
  String get tellUsAboutYourself => 'Tell us about yourself';

  @override
  String get allFieldsOptional => 'All fields are optional.';

  @override
  String get beginScrolling => 'Begin Scrolling';

  @override
  String get youreAllSet => "You're all set.";

  @override
  String get wisdomAwaits => 'Wisdom awaits in every direction.';

  @override
  String get starting => 'Starting…';

  @override
  String get startScrolling => 'Start Scrolling';

  @override
  String get welcomeTitle => 'Welcome to MindScroll';

  @override
  String get welcomeSubtitle => 'Philosophical wisdom for your daily mind';

  @override
  String get swipeToExplore => 'Swipe any direction to explore.';

  @override
  String get primaryInterest => 'Primary interest';

  @override
  String get yourGoal => 'Your goal';

  // ------------------------------------------------------------------
  // Onboarding options
  // ------------------------------------------------------------------
  @override
  String get optPhilosophy => 'Philosophy';

  @override
  String get optStoicism => 'Stoicism';

  @override
  String get optPersonalGrowth => 'Personal Growth';

  @override
  String get optMindfulness => 'Mindfulness';

  @override
  String get optCuriosity => 'Curiosity';

  @override
  String get optCalmMind => 'Calm Mind';

  @override
  String get optDiscipline => 'Discipline';

  @override
  String get optFindingMeaning => 'Finding Meaning';

  @override
  String get optEmotionalClarity => 'Emotional Clarity';

  // ------------------------------------------------------------------
  // Insights screen
  // ------------------------------------------------------------------
  @override
  String get weeklyInsight => 'Weekly Insight';

  @override
  String get aiBadge => 'AI';

  @override
  String get refreshInsight => 'Refresh insight';

  @override
  String get insightForming => 'Your insight is forming';

  @override
  String get insightFormingBody =>
      'Keep exploring philosophical ideas and your weekly AI insight will appear here.';

  @override
  String get insightTip1 =>
      'Swipe through philosophical quotes to build your profile.';

  @override
  String get insightTip2 => 'Like quotes that resonate with you.';

  @override
  String get insightTip3 => 'Save your favourites to the Vault.';

  @override
  String get generatedByAI =>
      'Generated by Claude based on your philosophical journey this week.';

  @override
  String get couldNotRefresh =>
      'Could not refresh. Showing last known insight.';

  @override
  String get justGenerated => 'Just generated';

  @override
  String get yesterday => 'yesterday';

  @override
  String get daysAgo => 'days ago';

  // ------------------------------------------------------------------
  // Vault screen
  // ------------------------------------------------------------------
  @override
  String get emptyVaultMsg => 'Save quotes to build your vault';

  // ------------------------------------------------------------------
  // Challenges screen
  // ------------------------------------------------------------------
  @override
  String get dailyReflection => 'Daily Reflection';

  @override
  String get defaultChallengeDesc => 'Reflect on one Stoic principle today.';

  @override
  String get offlineChallenge => 'Showing offline challenge';

  @override
  String get logOneStep => 'Log one step (+1)';

  @override
  String get completeChallenge => 'Complete Challenge';

  @override
  String get challengeCompleted => 'Challenge Completed';

  @override
  String get complete => 'Complete!';

  @override
  String get progress => 'Progress';

  @override
  String get dailyChallengeLabel => 'DAILY CHALLENGE';

  @override
  String get percentComplete => '% complete';

  @override
  String get trackThis => 'Track this';

  // ------------------------------------------------------------------
  // Premium screen
  // ------------------------------------------------------------------
  @override
  String get unlockFullExperience => 'Unlock the Full Experience';

  @override
  String get premiumSubtitle =>
      'Remove all limits and distractions.\nOne small price, forever.';

  @override
  String get alreadyPremium => 'Already Premium';

  @override
  String get featureColumn => 'Feature';

  @override
  String get freeColumn => 'Free';

  @override
  String get premiumColumn => 'Premium';

  @override
  String get dailyFeed => 'Daily feed';

  @override
  String get limitedQuotes => 'Limited (20 quotes)';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get ads => 'Ads';

  @override
  String get occasional => 'Occasional';

  @override
  String get none => 'None';

  @override
  String get vaultSize => 'Vault size';

  @override
  String get savedQuotes20 => '20 saved quotes';

  @override
  String get dailyChallenges => 'Daily challenges';

  @override
  String get viewOnly => 'View only';

  @override
  String get fullAccess => 'Full access';

  @override
  String get basic => 'Basic';

  @override
  String get fullPlusHistory => 'Full + history';

  @override
  String get oneTime => 'one-time';

  @override
  String get oneTimePurchase => 'One-time purchase — no subscription, ever.';

  // ------------------------------------------------------------------
  // Philosophy Map screen
  // ------------------------------------------------------------------
  @override
  String get mapSubtitle =>
      'Your philosophical tendencies based on your swipe history.';

  @override
  String get saveSnapshot => 'Save Snapshot';

  @override
  String get snapshotSaved => 'Snapshot saved';

  @override
  String get snapshotError => 'Failed to save snapshot';

  // ------------------------------------------------------------------
  // Donations screen
  // ------------------------------------------------------------------
  @override
  String get supportMindScroll => 'Support MindScroll';

  @override
  String get donationDescription =>
      'MindScroll is a passion project built to bring timeless philosophy into everyday life. If it has brought you a moment of clarity or calm, consider buying a coffee — it keeps the project alive and growing.';

  @override
  String get everyContribution => 'Every contribution is deeply appreciated.';

  @override
  String get buyMeCoffee => 'Buy Me a Coffee';

  @override
  String get couldNotOpenDonation => 'Could not open donation page.';

  // ------------------------------------------------------------------
  // Swipe hint overlay
  // ------------------------------------------------------------------
  @override
  String get hintPhilosophy => 'PHILOSOPHY';

  @override
  String get hintStoicism => 'STOICISM';

  @override
  String get hintDiscipline => 'DISCIPLINE';

  @override
  String get hintReflection => 'REFLECTION';
}
