import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/analytics/event_logger.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/feed_repository.dart';
import '../settings/settings_controller.dart';
import '../../core/utils/locale_utils.dart';

/// Manages onboarding page navigation and profile collection.
///
/// This is a lightweight ChangeNotifier controller — no Riverpod needed
/// for the onboarding flow which is linear and single-use.
class OnboardingController extends ChangeNotifier {
  final FeedRepository? _repository;

  OnboardingController({FeedRepository? repository})
      : _repository = repository;

  // ------------------------------------------------------------------
  // Page state
  // ------------------------------------------------------------------

  int _currentPage = 0;
  int get currentPage => _currentPage;

  static const int totalPages = 3;

  // ------------------------------------------------------------------
  // Profile form values
  // ------------------------------------------------------------------

  String? _ageRange;
  final Set<String> _interests = {};
  final Set<String> _goals = {};
  String _lang = _detectDeviceLang();

  static String _detectDeviceLang() {
    return LocaleUtils.detectLanguage();
  }

  String? get ageRange => _ageRange;
  Set<String> get interests => Set.unmodifiable(_interests);
  /// Legacy getter for backward compatibility
  String? get interest => _interests.isNotEmpty ? _interests.first : null;
  Set<String> get goals => Set.unmodifiable(_goals);
  /// Legacy getter — returns first goal or null
  String? get goal => _goals.isNotEmpty ? _goals.first : null;
  String get lang => _lang;

  UserProfileModel get profileSnapshot => UserProfileModel(
        ageRange: _ageRange,
        interest: _interests.isNotEmpty ? _interests.join(',') : null,
        goal: _goals.isNotEmpty ? _goals.join(',') : null,
        preferredLanguage: _lang,
      );

  // ------------------------------------------------------------------
  // Setters — each notifies listeners so the UI rebuilds.
  // ------------------------------------------------------------------

  void setAgeRange(String value) {
    _ageRange = _ageRange == value ? null : value; // toggle off if re-tapped
    notifyListeners();
  }

  void toggleInterest(String value) {
    if (_interests.contains(value)) {
      _interests.remove(value);
    } else if (_interests.length < 3) {
      _interests.add(value);
    }
    notifyListeners();
  }

  /// Legacy setter for backward compatibility
  void setInterest(String value) => toggleInterest(value);

  void toggleGoal(String value) {
    if (_goals.contains(value)) {
      _goals.remove(value);
    } else if (_goals.length < 2) {
      _goals.add(value);
    }
    notifyListeners();
  }

  /// Legacy setter
  void setGoal(String value) => toggleGoal(value);

  void setLang(String value) {
    if (_lang == value) return;
    _lang = value;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Navigation
  // ------------------------------------------------------------------

  void nextPage(PageController pageController) {
    if (_currentPage >= totalPages - 1) return;
    _currentPage++;
    pageController.animateToPage(
      _currentPage,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
    notifyListeners();
  }

  void onPageChanged(int page) {
    _currentPage = page;
    notifyListeners();
  }

  // ------------------------------------------------------------------
  // Completion
  // ------------------------------------------------------------------

  bool _completing = false;
  bool get isCompleting => _completing;

  /// Saves onboarding done flag, fires profile POST (fire-and-forget),
  /// then navigates to '/feed'.
  Future<void> complete(BuildContext context, WidgetRef ref) async {
    if (_completing) return;
    _completing = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.onboardingKey, true);
      await prefs.setString(AppConstants.langKey, _lang);

      // Sync the live settings provider so FeedScreen picks up the new lang
      // immediately without requiring an app restart.
      await ref.read(settingsControllerProvider.notifier).setLang(_lang);

      // Fire-and-forget profile submission.
      _repository?.postProfile(profileSnapshot).ignore();

      // Analytics: funnel event
      EventLogger.logOnboardingComplete();

      // Mark that audio should auto-start on first feed load
      await prefs.setBool('mindscroll_audio_autostart', true);
    } catch (_) {
      // Non-fatal; proceed regardless.
    }

    if (!context.mounted) return;
    context.go('/feed');
  }
}
