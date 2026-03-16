import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/datasources/remote/insights_remote_ds.dart';
import '../../data/models/insight_model.dart';
import '../../data/repositories/insights_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final insightsRepositoryProvider =
    FutureProvider<InsightsRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  return InsightsRepository(remote: InsightsRemoteDataSource(api));
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class InsightsState {
  final InsightModel? insight;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;

  const InsightsState({
    this.insight,
    this.isLoading = false,
    this.isRefreshing = false,
    this.error,
  });

  InsightsState copyWith({
    InsightModel? insight,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearInsight = false,
    bool clearError = false,
  }) {
    return InsightsState(
      insight: clearInsight ? null : (insight ?? this.insight),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class InsightsController extends AsyncNotifier<InsightsState> {
  late InsightsRepository _repo;

  @override
  Future<InsightsState> build() async {
    _repo = await ref.watch(insightsRepositoryProvider.future);
    return const InsightsState();
  }

  /// Load the weekly insight on screen mount.
  Future<void> load() async {
    final current = state.valueOrNull ?? const InsightsState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    final result = await _repo.getWeeklyInsight();
    result.when(
      success: (insight) {
        state = AsyncData(InsightsState(insight: insight));
      },
      failure: (message, _) {
        state = AsyncData(
          InsightsState(
            insight: current.insight, // keep stale data if any
            error: message,
          ),
        );
      },
    );
  }

  /// Pull-to-refresh — shows a lighter loading indicator.
  Future<void> refresh() async {
    final current = state.valueOrNull ?? const InsightsState();
    state = AsyncData(current.copyWith(isRefreshing: true, clearError: true));

    final result = await _repo.getWeeklyInsight();
    result.when(
      success: (insight) {
        state = AsyncData(InsightsState(insight: insight));
      },
      failure: (message, _) {
        state = AsyncData(
          current.copyWith(isRefreshing: false, error: message),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final insightsControllerProvider =
    AsyncNotifierProvider<InsightsController, InsightsState>(
  InsightsController.new,
);

/// Sync convenience — screens read this instead of handling AsyncValue.
final insightsStateProvider = Provider<InsightsState>((ref) {
  return ref.watch(insightsControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const InsightsState(isLoading: true),
      );
});
