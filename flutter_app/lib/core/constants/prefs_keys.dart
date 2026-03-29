/// Centralized SharedPreferences keys.
///
/// Prevents magic-string sprawl across the codebase. When adding a new
/// persisted value, define its key here first, then reference it from
/// the relevant controller / data source.
///
/// Migration note: existing call-sites still use local `const` strings.
/// Migrate incrementally — new code should always import from here.
abstract class PrefsKeys {
  // ── Onboarding & First-Run ───────────────────────────────────────────────
  static const onboardingDone = 'mindscroll_onboarding_done';
  static const featureTourDone = 'mindscroll_feature_tour_done';
  static const hintShown = 'mindscroll_hint_shown';
  static const audioAutostart = 'mindscroll_audio_autostart';

  // ── Device & Session ─────────────────────────────────────────────────────
  static const deviceId = 'mindscroll_device_id';
  static const deviceLockStatus = 'device_lock_status';

  // ── Language & Profile ───────────────────────────────────────────────────
  static const lang = 'mindscroll_lang';
  static const profile = 'mindscroll_profile';

  // ── Premium & Monetization ───────────────────────────────────────────────
  static const premium = 'mindscroll_premium';
  static const isPremium = 'mindscroll_is_premium';
  static const ownedPacks = 'mindscroll_owned_packs';
  static const userState = 'mindscroll_user_state';
  static const trialStart = 'mindscroll_trial_start';
  static const devStateOverride = 'mindscroll_dev_state_override';
  static const devSimulatedPacks = 'mindscroll_dev_simulated_packs';
  static const devSimulatedInside = 'mindscroll_dev_simulated_inside';

  // ── Feed ─────────────────────────────────────────────────────────────────
  static const swipeCount = 'mindscroll_swipe_count';
  static const swipeDate = 'mindscroll_swipe_date';
  static const streak = 'mindscroll_streak';
  static const feedCache = 'mindscroll_feed_cache';
  static const refinementShown = 'mindscroll_refinement_shown';
  static const softPaywallShown = 'mindscroll_soft_paywall_shown';

  // ── Vault & Likes ────────────────────────────────────────────────────────
  static const likedIds = 'mindscroll_liked_ids';
  static const vaultIds = 'mindscroll_vault_ids';

  // ── Notifications ────────────────────────────────────────────────────────
  static const notifEnabled = 'mindscroll_notif_enabled';
  static const notifHour = 'mindscroll_notif_hour';
  static const notifMinute = 'mindscroll_notif_minute';

  // ── Ambient Audio ────────────────────────────────────────────────────────
  static const ambientEnabled = 'mindscroll.ambient.enabled';
  static const ambientTrackId = 'mindscroll.ambient.trackId';
  static const ambientVolume = 'mindscroll.ambient.volume';

  // ── Challenges ───────────────────────────────────────────────────────────
  static const challengeCache = 'mindscroll_challenge_cache';
  /// Dynamic key: `mindscroll_challenge_progress_YYYY-MM-DD`
  static String challengeProgress(String date) =>
      'mindscroll_challenge_progress_$date';

  // ── Streak Milestones ────────────────────────────────────────────────────
  /// Dynamic key: `mindscroll_milestone_{n}`
  static String milestone(int streak) => 'mindscroll_milestone_$streak';

  // ── Author Affinity ──────────────────────────────────────────────────────
  static const authorAffinity = 'mindscroll_author_affinity';

  // ── Hidden Modes ─────────────────────────────────────────────────────────
  static const hiddenScienceUnlocked = 'mindscroll_hidden_science_unlocked';
  static const hiddenCodingUnlocked = 'mindscroll_hidden_coding_unlocked';
  static const scienceQuizScore = 'mindscroll_science_quiz_score';
  static const codingQuizScore = 'mindscroll_coding_quiz_score';

  // ── Insights ─────────────────────────────────────────────────────────────
  static const moodHistory = 'mindscroll_mood_history';
}
