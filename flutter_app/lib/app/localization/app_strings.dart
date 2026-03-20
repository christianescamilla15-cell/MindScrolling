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
  String get loadingReflections;
  String get vault;
  String get settings;
  String get streak;
  String get reflections;
  String get save;
  String get close;
  String get error;
  String get retry;
  String get categories;

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
  String get profileTitle;
  String get profileEdit;
  String get profileInfo;

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
  String get premiumPacks;
  String get noPacks;
  String get explorePacks;

  // ------------------------------------------------------------------
  // Donations
  // ------------------------------------------------------------------
  String get donateTitle;
  String get donateBody;
  String get donateBtn;

  // ------------------------------------------------------------------
  // Actions / toasts
  // ------------------------------------------------------------------
  String get or;
  String get shareVia;
  String get savedVault;
  String get removedLike;
  String get liked;
  String get alreadyVault;
  String get streakExtended;
  String get copied;
  String get doubleTapToLike;
  String get exportImage;
  String get imageReadyToShare;

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

  // ------------------------------------------------------------------
  // Navigation bottom bar
  // ------------------------------------------------------------------
  String get feed;
  String get map;
  String get insight;

  // ------------------------------------------------------------------
  // Settings screen
  // ------------------------------------------------------------------
  String get navigateTo;
  String get about;
  String get reset;
  String get philosophyMap;
  String get dailyChallenge;
  String get premium;
  String get donations;
  String get appVersion;
  String get privacyPolicy;
  String get resetOnboarding;
  String get resetOnboardingTitle;
  String get resetOnboardingMsg;
  String get cancel;
  String get onboardingResetDone;
  String get couldNotOpenPrivacy;

  // ------------------------------------------------------------------
  // Feed screen
  // ------------------------------------------------------------------
  String get couldNotLoadQuotes;
  String get noQuotesAvailable;
  String get noMoreQuotes;
  String get tryAgain;

  // ------------------------------------------------------------------
  // Onboarding screen
  // ------------------------------------------------------------------
  String get tellUsAboutYourself;
  String get allFieldsOptional;
  String get beginScrolling;
  String get youreAllSet;
  String get wisdomAwaits;
  String get starting;
  String get startScrolling;
  String get welcomeTitle;
  String get welcomeSubtitle;
  String get swipeToExplore;
  String get primaryInterest;
  String get yourGoal;

  // ------------------------------------------------------------------
  // Onboarding options
  // ------------------------------------------------------------------
  String get optPhilosophy;
  String get optStoicism;
  String get optPersonalGrowth;
  String get optMindfulness;
  String get optCuriosity;
  String get optCalmMind;
  String get optDiscipline;
  String get optFindingMeaning;
  String get optEmotionalClarity;

  // ------------------------------------------------------------------
  // Insights screen
  // ------------------------------------------------------------------
  String get weeklyInsight;
  String get aiBadge;
  String get refreshInsight;
  String get insightForming;
  String get insightFormingBody;
  String get insightTip1;
  String get insightTip2;
  String get insightTip3;
  String get generatedByAI;
  String get couldNotRefresh;
  String get justGenerated;
  String get yesterday;
  String get daysAgo;
  String get insightPremiumTitle;
  String get insightPremiumBody;
  String get upgradeToPremium;
  String hoursAgo(int hours);

  // ------------------------------------------------------------------
  // Vault screen
  // ------------------------------------------------------------------
  String get emptyVaultMsg;

  // ------------------------------------------------------------------
  // Challenges screen
  // ------------------------------------------------------------------
  String get dailyReflection;
  String get defaultChallengeDesc;
  String get offlineChallenge;
  String get logOneStep;
  String get completeChallenge;
  String get challengeCompleted;
  String get challengeAutoComplete;
  String challengeProgress(int count, int target);
  String get complete;
  String get progress;
  String get dailyChallengeLabel;
  String get percentComplete;
  String get trackThis;

  // ------------------------------------------------------------------
  // Premium screen
  // ------------------------------------------------------------------
  String get unlockFullExperience;
  String get premiumSubtitle;
  String get alreadyPremium;
  String get featureColumn;
  String get freeColumn;
  String get premiumColumn;
  String get dailyFeed;
  String get limitedQuotes;
  String get unlimited;
  String get ads;
  String get occasional;
  String get none;
  String get vaultSize;
  String get savedQuotes20;
  String get dailyChallenges;
  String get viewOnly;
  String get fullAccess;
  String get basic;
  String get fullPlusHistory;
  String get oneTime;
  String get oneTimePurchase;
  String get aiWeeklyInsight;
  String get notIncluded;
  String get included;

  // ------------------------------------------------------------------
  // Philosophy Map screen
  // ------------------------------------------------------------------
  String get mapSubtitle;
  String get saveSnapshot;
  String get snapshotSaved;
  String get snapshotError;

  // ------------------------------------------------------------------
  // Donations screen
  // ------------------------------------------------------------------
  String get supportMindScroll;
  String get donationDescription;
  String get everyContribution;
  String get buyMeCoffee;
  String get couldNotOpenDonation;

  // ------------------------------------------------------------------
  // Premium purchase flow
  // ------------------------------------------------------------------
  String get restorePurchases;
  String get purchaseSuccess;
  String get purchaseFailed;
  String get restoreSuccess;
  String get restoreFailed;
  String get noPurchasesFound;
  String get premiumActive;
  String get premiumRequired;
  String get purchasing;

  // ------------------------------------------------------------------
  // Swipe hint overlay
  // ------------------------------------------------------------------
  String get hintPhilosophy;
  String get hintStoicism;
  String get hintDiscipline;
  String get hintReflection;

  // ------------------------------------------------------------------
  // Vault limit
  // ------------------------------------------------------------------
  String get vaultLimitReached;

  // ------------------------------------------------------------------
  // Reset experience
  // ------------------------------------------------------------------
  String get resetExperience;
  String get resetExperienceTitle;
  String get resetExperienceMsg;
  String get resetExperienceDone;

  // ------------------------------------------------------------------
  // Feed session limit
  // ------------------------------------------------------------------
  String get feedLimitReached;

  // ------------------------------------------------------------------
  // Ambient audio
  // ------------------------------------------------------------------
  String get ambientAudio;
  String get soundscapes;
  String get nowPlaying;
  String get audioComingSoon;
  String get play;
  String get pause;
  String get volume;

  // ------------------------------------------------------------------
  // Trial
  // ------------------------------------------------------------------
  String get trialActive;
  String trialDaysLeft(int days);
  String get trialExpiredTitle;
  String get trialExpiredMsg;
  String get trialExpiredButton;
  String get continueReading;

  // ------------------------------------------------------------------
  // Reflection card
  // ------------------------------------------------------------------
  // ------------------------------------------------------------------
  // Author detail
  // ------------------------------------------------------------------
  String get authorLoadError;
  String get topQuotes;
  String nQuotes(int n);

  // ------------------------------------------------------------------
  // Notifications
  // ------------------------------------------------------------------
  String get notifications;
  String get dailyReminder;
  String get dailyReminderBody;
  String get weeklyMapTitle;
  String get weeklyMapBody;
  String get reminderTime;
  String get notificationsEnabled;
  String get notificationsDisabled;

  // ------------------------------------------------------------------
  // Streak milestones
  // ------------------------------------------------------------------
  String get milestone7Title;
  String get milestone7Msg;
  String get milestone30Title;
  String get milestone30Msg;
  String get milestoneClose;

  // ------------------------------------------------------------------
  // Vault export
  // ------------------------------------------------------------------
  String get exportVault;
  String get exportVaultEmpty;
  String get myVault;
  String get exportedFrom;

  // ------------------------------------------------------------------
  // Philosophy Map tabs
  // ------------------------------------------------------------------
  String get today;
  String get evolution;
  String get comparedTo;

  // ------------------------------------------------------------------
  // Redeem code
  // ------------------------------------------------------------------
  String get redeemCode;
  String get redeemCodeTitle;
  String get redeemCodeSubtitle;
  String get activateCode;
  String get redeemSuccess;
  String get redeemFailed;
  String get codeNotFound;
  String get codeAlreadyUsed;
  String get codeExpired;
  String get invalidCodeFormat;
  String get haveActivationCode;

  // ------------------------------------------------------------------
  // Reflection card
  // ------------------------------------------------------------------
  String get takeABreath;
  String get doingWell;
  String get swipeContinue;

  // ------------------------------------------------------------------
  // Soft paywall dismiss hint
  // ------------------------------------------------------------------
  String get swipeToContinue;
  String get swipeUp;

  // ------------------------------------------------------------------
  // Pack monetization (Block B)
  // ------------------------------------------------------------------
  String get packIncluded;
  String get packUnlocked;
  String get packPreview;
  String get packLocked;
  String packUnlockCta(int quotesCount);
  String get packInsideCta;
  String get packPreviewUnavailable;
  String get packComingSoon;
  String get trialSoftPaywall;

  // API Contract keys (from contract section 7)
  String get packIncludedInInside;
  String get packGetFor;
  String packPaywallPrimary(String packName);
  String get packPaywallSecondaryInside;
  String packTrialPaywallPrimary(int count);
  String get packTrialPaywallSecondary;
  String packConfirmationUnlocked(String packName, int count);
  String get packNewNotIncluded;
  String get insideValueProp;
  String get insideValuePropOwn1;
  String get insideValuePropOwn2;

}

/// Resolves controller-emitted toast key strings to localized display text.
extension AppStringsToastResolver on AppStrings {
  String? resolveToastKey(String key) {
    switch (key) {
      case 'liked':             return liked;
      case 'removedLike':       return removedLike;
      case 'savedVault':        return savedVault;
      case 'alreadyVault':      return alreadyVault;
      case 'streakExtended':    return streakExtended;
      case 'vaultLimitReached': return vaultLimitReached;
      case 'feedLimitReached':  return feedLimitReached;
      case 'challengeAutoComplete': return challengeAutoComplete;
      default:                  return null;
    }
  }
}
