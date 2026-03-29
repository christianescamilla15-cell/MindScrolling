import 'package:flutter_test/flutter_test.dart';
import 'package:mind_scrolling/core/constants/prefs_keys.dart';

void main() {
  group('PrefsKeys', () {
    test('all static keys are non-empty strings', () {
      final keys = [
        PrefsKeys.onboardingDone,
        PrefsKeys.featureTourDone,
        PrefsKeys.hintShown,
        PrefsKeys.audioAutostart,
        PrefsKeys.deviceId,
        PrefsKeys.deviceLockStatus,
        PrefsKeys.lang,
        PrefsKeys.profile,
        PrefsKeys.premium,
        PrefsKeys.isPremium,
        PrefsKeys.ownedPacks,
        PrefsKeys.userState,
        PrefsKeys.trialStart,
        PrefsKeys.devStateOverride,
        PrefsKeys.devSimulatedPacks,
        PrefsKeys.devSimulatedInside,
        PrefsKeys.swipeCount,
        PrefsKeys.swipeDate,
        PrefsKeys.streak,
        PrefsKeys.feedCache,
        PrefsKeys.refinementShown,
        PrefsKeys.softPaywallShown,
        PrefsKeys.likedIds,
        PrefsKeys.vaultIds,
        PrefsKeys.notifEnabled,
        PrefsKeys.notifHour,
        PrefsKeys.notifMinute,
        PrefsKeys.ambientEnabled,
        PrefsKeys.ambientTrackId,
        PrefsKeys.ambientVolume,
        PrefsKeys.challengeCache,
        PrefsKeys.authorAffinity,
        PrefsKeys.hiddenScienceUnlocked,
        PrefsKeys.hiddenCodingUnlocked,
        PrefsKeys.scienceQuizScore,
        PrefsKeys.codingQuizScore,
        PrefsKeys.moodHistory,
      ];

      for (final key in keys) {
        expect(key, isNotEmpty, reason: 'Key should not be empty: $key');
        expect(key, isA<String>());
      }
    });

    test('no duplicate key values', () {
      final keys = [
        PrefsKeys.onboardingDone,
        PrefsKeys.featureTourDone,
        PrefsKeys.hintShown,
        PrefsKeys.audioAutostart,
        PrefsKeys.deviceId,
        PrefsKeys.deviceLockStatus,
        PrefsKeys.lang,
        PrefsKeys.profile,
        PrefsKeys.premium,
        PrefsKeys.isPremium,
        PrefsKeys.ownedPacks,
        PrefsKeys.userState,
        PrefsKeys.trialStart,
        PrefsKeys.devStateOverride,
        PrefsKeys.devSimulatedPacks,
        PrefsKeys.devSimulatedInside,
        PrefsKeys.swipeCount,
        PrefsKeys.swipeDate,
        PrefsKeys.streak,
        PrefsKeys.feedCache,
        PrefsKeys.refinementShown,
        PrefsKeys.softPaywallShown,
        PrefsKeys.likedIds,
        PrefsKeys.vaultIds,
        PrefsKeys.notifEnabled,
        PrefsKeys.notifHour,
        PrefsKeys.notifMinute,
        PrefsKeys.ambientEnabled,
        PrefsKeys.ambientTrackId,
        PrefsKeys.ambientVolume,
        PrefsKeys.challengeCache,
        PrefsKeys.authorAffinity,
        PrefsKeys.hiddenScienceUnlocked,
        PrefsKeys.hiddenCodingUnlocked,
        PrefsKeys.scienceQuizScore,
        PrefsKeys.codingQuizScore,
        PrefsKeys.moodHistory,
      ];

      final unique = keys.toSet();
      expect(unique.length, keys.length,
          reason: 'All PrefsKeys values must be unique');
    });

    test('dynamic challengeProgress key includes date', () {
      final key = PrefsKeys.challengeProgress('2026-03-29');
      expect(key, 'mindscroll_challenge_progress_2026-03-29');
    });

    test('dynamic milestone key includes streak number', () {
      final key = PrefsKeys.milestone(10);
      expect(key, 'mindscroll_milestone_10');
    });

    test('keys match values used in existing code', () {
      // Verify critical keys match what the codebase expects
      expect(PrefsKeys.onboardingDone, 'mindscroll_onboarding_done');
      expect(PrefsKeys.deviceId, 'mindscroll_device_id');
      expect(PrefsKeys.lang, 'mindscroll_lang');
      expect(PrefsKeys.premium, 'mindscroll_premium');
      expect(PrefsKeys.swipeCount, 'mindscroll_swipe_count');
      expect(PrefsKeys.streak, 'mindscroll_streak');
      expect(PrefsKeys.notifEnabled, 'mindscroll_notif_enabled');
      expect(PrefsKeys.ambientEnabled, 'mindscroll.ambient.enabled');
      expect(PrefsKeys.trialStart, 'mindscroll_trial_start');
      expect(PrefsKeys.deviceLockStatus, 'device_lock_status');
    });
  });
}
