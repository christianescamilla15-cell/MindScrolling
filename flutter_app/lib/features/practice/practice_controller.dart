import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../core/network/api_client.dart';
import '../settings/settings_controller.dart';
import 'exercise_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PracticeState {
  const PracticeState({
    this.exercises = const [],
    this.selectedLanguage = 'all',
    this.selectedDifficulty = 0,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.totalCompleted = 0,
    this.totalPoints = 0,
    this.hasMore = true,
    this.nextCursor,
  });

  final List<ExerciseModel> exercises;
  final String selectedLanguage;
  final int selectedDifficulty;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int totalCompleted;
  final int totalPoints;
  final bool hasMore;
  final String? nextCursor;

  PracticeState copyWith({
    List<ExerciseModel>? exercises,
    String? selectedLanguage,
    int? selectedDifficulty,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? totalCompleted,
    int? totalPoints,
    bool? hasMore,
    String? nextCursor,
  }) {
    return PracticeState(
      exercises: exercises ?? this.exercises,
      selectedLanguage: selectedLanguage ?? this.selectedLanguage,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      totalCompleted: totalCompleted ?? this.totalCompleted,
      totalPoints: totalPoints ?? this.totalPoints,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: nextCursor ?? this.nextCursor,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class PracticeController extends StateNotifier<PracticeState> {
  PracticeController(this._api, this._lang) : super(const PracticeState());

  final ApiClient _api;
  final String _lang;

  static const int _pageSize = 20;

  /// Initial load — clears previous list, fetches exercises + stats in parallel.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null, exercises: [], nextCursor: null);

    try {
      final params = _buildParams(limit: _pageSize);

      // CRIT-03 fix: Fetch exercises list AND stats in parallel
      final results = await Future.wait([
        _api.get('/exercises/list', queryParams: params),
        _api.get('/exercises/stats'),
      ]);

      final listData = results[0];
      final statsData = results[1];

      // CRIT-01 fix: Backend returns 'data', not 'exercises'
      final rawList = listData['data'] as List<dynamic>? ?? [];
      final list = rawList
          .whereType<Map<String, dynamic>>()
          .map(ExerciseModel.fromJson)
          .toList();

      // CRIT-02 fix: Use cursor-based pagination from backend
      final nextCursor = listData['next_cursor'] as String?;
      final hasMore = listData['has_more'] as bool? ?? false;

      // CRIT-03 fix: Read correct stat field names
      state = state.copyWith(
        exercises: list,
        isLoading: false,
        hasMore: hasMore,
        nextCursor: nextCursor,
        totalCompleted: (statsData['total_completed'] as int?) ?? 0,
        totalPoints: (statsData['total_points'] as int?) ?? 0,
        error: null,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Load next page — appends to existing list using cursor pagination.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    if (state.nextCursor == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      // CRIT-02 fix: Use cursor, not offset
      final params = _buildParams(limit: _pageSize);
      params['cursor'] = state.nextCursor!;

      final data = await _api.get('/exercises/list', queryParams: params);

      final rawList = data['data'] as List<dynamic>? ?? [];
      final list = rawList
          .whereType<Map<String, dynamic>>()
          .map(ExerciseModel.fromJson)
          .toList();

      final nextCursor = data['next_cursor'] as String?;
      final hasMore = data['has_more'] as bool? ?? false;

      state = state.copyWith(
        exercises: [...state.exercises, ...list],
        isLoadingMore: false,
        hasMore: hasMore,
        nextCursor: nextCursor,
      );
    } on ApiException catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  /// Change language filter and reload.
  Future<void> setLanguage(String language) async {
    if (state.selectedLanguage == language) return;
    state = state.copyWith(selectedLanguage: language);
    await load();
  }

  /// Change difficulty filter and reload.
  Future<void> setDifficulty(int difficulty) async {
    if (state.selectedDifficulty == difficulty) return;
    state = state.copyWith(selectedDifficulty: difficulty);
    await load();
  }

  /// Update a single exercise in the local list after a submit.
  /// HIGH-02 fix: Uses pointsEarned (actual) instead of base points.
  void updateExercise(ExerciseModel updated, {int? pointsEarned}) {
    final idx = state.exercises.indexWhere((e) => e.id == updated.id);
    if (idx == -1) return;
    final newList = List<ExerciseModel>.from(state.exercises);
    newList[idx] = updated;

    int completedDelta = 0;
    int pointsDelta = 0;
    final prev = state.exercises[idx];
    if (prev.status != 'completed' && updated.status == 'completed') {
      completedDelta = 1;
      pointsDelta = pointsEarned ?? updated.points;
    }

    state = state.copyWith(
      exercises: newList,
      totalCompleted: state.totalCompleted + completedDelta,
      totalPoints: state.totalPoints + pointsDelta,
    );
  }

  Map<String, String> _buildParams({required int limit}) {
    final params = <String, String>{
      'lang': _lang,
      'limit': limit.toString(),
    };
    if (state.selectedLanguage != 'all') {
      params['language'] = state.selectedLanguage;
    }
    if (state.selectedDifficulty > 0) {
      params['difficulty'] = state.selectedDifficulty.toString();
    }
    return params;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final practiceControllerProvider =
    StateNotifierProvider<PracticeController, PracticeState>((ref) {
  final api = ref.watch(apiClientProvider);
  final lang = ref.watch(settingsStateProvider).lang;
  return PracticeController(api, lang);
});
