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
  String get loadingReflections => 'Loading reflections…';

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
  @override
  String get categories => 'Categories';

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

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileEdit => 'Edit';

  @override
  String get profileInfo => 'Profile Info';

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
  String get premiumUnlock => 'Unlock MindScrolling Inside';

  @override
  String get premiumPrice => r'$4.99 once — forever yours';

  @override
  String get premiumFeature => 'MindScrolling Inside feature';
  @override
  String get premiumPacks => 'Content Packs';
  @override
  String get noPacks => 'No packs available yet';
  @override
  String get explorePacks => 'Explore Packs';

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
  String get or => 'or';

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
  String get premium => 'MindScrolling Inside';

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

  @override
  String get insightPremiumTitle => 'Unlock Your Weekly Insight';

  @override
  String get insightPremiumBody =>
      'AI-powered philosophical insights are a MindScrolling Inside feature. Upgrade to receive your personalised weekly reflection.';

  @override
  String get upgradeToPremium => 'Upgrade to Inside';

  @override
  String hoursAgo(int hours) => '${hours}h ago';

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
  String get challengeAutoComplete => 'Daily Challenge Complete!';
  @override
  String challengeProgress(int count, int target) => '$count/$target quotes today';

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
  String get alreadyPremium => 'MindScrolling Inside Active';

  @override
  String get featureColumn => 'Feature';

  @override
  String get freeColumn => 'Free';

  @override
  String get premiumColumn => 'Inside';

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
  @override
  String get aiWeeklyInsight => 'AI Weekly Insight';
  @override
  String get notIncluded => 'Not included';
  @override
  String get included => 'Included';

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

  // Premium purchase flow
  @override
  String get restorePurchases => 'Restore Purchases';
  @override
  String get purchaseSuccess => 'Welcome to MindScrolling Inside!';
  @override
  String get purchaseFailed => 'Purchase could not be completed. Please try again.';
  @override
  String get restoreSuccess => 'Your purchase has been restored!';
  @override
  String get restoreFailed => 'Could not restore purchases. Please try again.';
  @override
  String get noPurchasesFound => 'No previous purchases found.';
  @override
  String get premiumActive => 'MindScrolling Inside is active';
  @override
  String get premiumRequired => 'This feature requires MindScrolling Inside';
  @override
  String get purchasing => 'Processing purchase...';

  // Vault limit
  @override
  String get vaultLimitReached => 'Vault limit reached. Upgrade to MindScrolling Inside for unlimited storage.';

  // Reset experience
  @override
  String get resetExperience => 'Reset Experience';
  @override
  String get resetExperienceTitle => 'Reset Experience?';
  @override
  String get resetExperienceMsg => 'This will clear all your data including vault, likes, preferences, and philosophical map. This action cannot be undone.';
  @override
  String get resetExperienceDone => 'Experience reset. Restart the app.';

  // Feed limit
  @override
  String get feedLimitReached => "You've reached today's free limit. Upgrade for unlimited quotes.";

  // Ambient audio
  @override String get ambientAudio    => 'Ambient Audio';
  @override String get soundscapes     => 'Soundscapes';
  @override String get nowPlaying      => 'Now Playing';
  @override String get audioComingSoon => 'Audio tracks coming soon';
  @override String get play            => 'Play';
  @override String get pause           => 'Pause';
  @override String get volume          => 'Volume';

  // Trial
  @override String get trialActive        => 'Free Trial';
  @override String trialDaysLeft(int d)   => '$d days left in your free trial';
  @override String get trialExpiredTitle   => 'Your Free Trial Has Ended';
  @override String get trialExpiredMsg     => 'Premium features are now disabled.\nUnlock full access with a one-time payment.';
  @override String get trialExpiredButton  => 'Unlock MindScrolling Inside — \$4.99';
  @override String get continueReading     => 'Continue free';

  // Author detail
  @override String get authorLoadError => 'Could not load author';
  @override String get topQuotes       => 'Top Quotes';
  @override String nQuotes(int n)      => '$n quotes';

  // Notifications
  @override String get notifications        => 'Notifications';
  @override String get dailyReminder        => 'Your reflection awaits';
  @override String get dailyReminderBody    => 'Take a moment to explore a new philosophical perspective.';
  @override String get weeklyMapTitle       => 'Your philosophy map is ready';
  @override String get weeklyMapBody        => 'See how your philosophical journey evolved this week.';
  @override String get reminderTime         => 'Reminder time';
  @override String get notificationsEnabled => 'Daily reminders enabled';
  @override String get notificationsDisabled => 'Reminders disabled';

  // Streak milestones
  @override String get milestone7Title  => '7 Days of Wisdom';
  @override String get milestone7Msg    => 'A week of philosophical reflection. The unexamined life is not worth living. — Socrates';
  @override String get milestone30Title => '30 Days of Growth';
  @override String get milestone30Msg   => 'A month of consistent reflection. You are becoming who you were meant to be.';
  @override String get milestoneClose   => 'Continue';

  // Vault export
  @override String get exportVault      => 'Export Vault';
  @override String get exportVaultEmpty => 'No quotes to export yet.';
  @override String get myVault          => 'My Vault';
  @override String get exportedFrom     => 'Exported from MindScrolling';

  // Philosophy Map tabs
  @override String get today      => 'Today';
  @override String get evolution  => 'Evolution';
  @override String get comparedTo => 'Compared to';

  // Redeem code
  @override String get redeemCode         => 'Redeem Code';
  @override String get redeemCodeTitle    => 'Activate MindScrolling Inside';
  @override String get redeemCodeSubtitle => 'If you received an activation code, enter it here to unlock lifetime premium access.';
  @override String get activateCode       => 'Activate Code';
  @override String get redeemSuccess      => 'Premium access activated for life. Enjoy the full experience.';
  @override String get redeemFailed       => 'Could not activate code. Please try again.';
  @override String get codeNotFound       => 'Code not found. Please check and try again.';
  @override String get codeAlreadyUsed    => 'This code has already been used.';
  @override String get codeExpired        => 'This code has expired.';
  @override String get invalidCodeFormat  => 'Please enter a valid activation code.';
  @override String get haveActivationCode => 'Have an activation code?';

  // Reflection card
  @override String get takeABreath    => 'Take a breath.';
  @override String get doingWell      => "You're doing well.";
  @override String get swipeContinue  => 'Swipe to continue your journey.';

  // Soft paywall dismiss hint
  @override String get swipeToContinue => 'Swipe to continue';
  @override String get swipeUp => 'Swipe up';

  // Pack monetization (Block B)
  @override String get packIncluded            => 'Included';
  @override String get packUnlocked            => 'Unlocked';
  @override String get packPreview             => 'Preview';
  @override String get packLocked              => 'Locked';
  @override String packUnlockCta(int quotesCount) => 'Unlock $quotesCount quotes — \$2.99';
  @override String get packInsideCta           => 'Or get all 3 packs with Inside (\$4.99)';
  @override String get packPreviewUnavailable  => 'Preview not available in this language';
  @override String get packComingSoon          => 'Purchase coming soon';
  @override String get trialSoftPaywall        => 'Enjoying MindScrolling? Go Inside for \$4.99';

  // API Contract keys
  @override String get packIncludedInInside    => 'Included in Inside';
  @override String get packGetFor              => 'Get for \$2.99';
  @override String packPaywallPrimary(String packName) => 'Get $packName — \$2.99';
  @override String get packPaywallSecondaryInside => 'Or unlock everything with Inside — \$4.99';
  @override String packTrialPaywallPrimary(int count) => '$count more quotes — \$2.99';
  @override String get packTrialPaywallSecondary => 'Or get all 3 packs with Inside — \$4.99';
  @override String packConfirmationUnlocked(String packName, int count) => '$packName unlocked. $count quotes ready.';
  @override String get packNewNotIncluded      => 'New — not included in existing Inside';
  @override String get insideValueProp         => '3 packs (\$8.97 value) + premium features — \$4.99';
  @override String get insideValuePropOwn1     => 'You already own 1 pack. Get the other 2 + premium features for \$4.99.';
  @override String get insideValuePropOwn2     => 'You own 2 packs. Complete your library + premium features for \$4.99.';
}
