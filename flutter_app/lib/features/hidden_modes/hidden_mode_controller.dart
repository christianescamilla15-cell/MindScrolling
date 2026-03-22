import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class HiddenModeState {
  final bool scienceUnlocked;
  final bool codingUnlocked;
  final int? scienceQuizScore;
  final int? codingQuizScore;
  final bool isLoaded;

  const HiddenModeState({
    this.scienceUnlocked = false,
    this.codingUnlocked = false,
    this.scienceQuizScore,
    this.codingQuizScore,
    this.isLoaded = false,
  });

  HiddenModeState copyWith({
    bool? scienceUnlocked,
    bool? codingUnlocked,
    int? scienceQuizScore,
    int? codingQuizScore,
    bool? isLoaded,
  }) {
    return HiddenModeState(
      scienceUnlocked: scienceUnlocked ?? this.scienceUnlocked,
      codingUnlocked: codingUnlocked ?? this.codingUnlocked,
      scienceQuizScore: scienceQuizScore ?? this.scienceQuizScore,
      codingQuizScore: codingQuizScore ?? this.codingQuizScore,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }

  bool isModeUnlocked(String mode) {
    switch (mode) {
      case 'science': return scienceUnlocked;
      case 'coding': return codingUnlocked;
      default: return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class HiddenModeController extends StateNotifier<HiddenModeState> {
  HiddenModeController() : super(const HiddenModeState()) {
    _loadState();
  }

  static const _kScienceKey = 'mindscroll_hidden_science_unlocked';
  static const _kCodingKey = 'mindscroll_hidden_coding_unlocked';
  static const _kScienceScoreKey = 'mindscroll_science_quiz_score';
  static const _kCodingScoreKey = 'mindscroll_coding_quiz_score';

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = HiddenModeState(
      scienceUnlocked: prefs.getBool(_kScienceKey) ?? false,
      codingUnlocked: prefs.getBool(_kCodingKey) ?? false,
      scienceQuizScore: prefs.getInt(_kScienceScoreKey),
      codingQuizScore: prefs.getInt(_kCodingScoreKey),
      isLoaded: true,
    );
  }

  /// Unlock a hidden mode after passing the quiz.
  Future<void> unlockMode(String mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case 'science':
        await prefs.setBool(_kScienceKey, true);
        await prefs.setInt(_kScienceScoreKey, score);
        state = state.copyWith(
          scienceUnlocked: true,
          scienceQuizScore: score,
        );
      case 'coding':
        await prefs.setBool(_kCodingKey, true);
        await prefs.setInt(_kCodingScoreKey, score);
        state = state.copyWith(
          codingUnlocked: true,
          codingQuizScore: score,
        );
    }
  }

  /// Record quiz attempt without unlocking.
  Future<void> recordQuizAttempt(String mode, int score) async {
    final prefs = await SharedPreferences.getInstance();
    switch (mode) {
      case 'science':
        await prefs.setInt(_kScienceScoreKey, score);
        state = state.copyWith(scienceQuizScore: score);
      case 'coding':
        await prefs.setInt(_kCodingScoreKey, score);
        state = state.copyWith(codingQuizScore: score);
    }
  }

  /// Reset all hidden modes (dev only).
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kScienceKey);
    await prefs.remove(_kCodingKey);
    await prefs.remove(_kScienceScoreKey);
    await prefs.remove(_kCodingScoreKey);
    state = const HiddenModeState(isLoaded: true);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final hiddenModeControllerProvider =
    StateNotifierProvider<HiddenModeController, HiddenModeState>((ref) {
  return HiddenModeController();
});
