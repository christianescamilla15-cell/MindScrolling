import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/philosophy_map_model.dart';
import '../challenges/challenges_controller.dart'
    show challengeRepositoryProvider;

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PhilosophyMapState {
  final PhilosophyMapModel? mapData;
  final bool isLoading;
  final bool snapshotSaved;
  final String? error;

  const PhilosophyMapState({
    this.mapData,
    this.isLoading = false,
    this.snapshotSaved = false,
    this.error,
  });

  PhilosophyMapState copyWith({
    PhilosophyMapModel? mapData,
    bool? isLoading,
    bool? snapshotSaved,
    String? error,
    bool clearError = false,
  }) {
    return PhilosophyMapState(
      mapData: mapData ?? this.mapData,
      isLoading: isLoading ?? this.isLoading,
      snapshotSaved: snapshotSaved ?? this.snapshotSaved,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class PhilosophyMapController extends AsyncNotifier<PhilosophyMapState> {
  late ChallengeRepository _repo;

  @override
  PhilosophyMapState build() {
    _repo = ref.watch(challengeRepositoryProvider);
    return const PhilosophyMapState();
  }

  /// Load the current philosophy map from the backend (GET /map).
  Future<void> load() async {
    final current = state.valueOrNull ?? const PhilosophyMapState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    final result = await _repo.getPhilosophyMap();
    result.when(
      success: (mapData) {
        state = AsyncData(
          (state.valueOrNull ?? const PhilosophyMapState())
              .copyWith(mapData: mapData, isLoading: false),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          (state.valueOrNull ?? const PhilosophyMapState())
              .copyWith(isLoading: false, error: message),
        );
      },
    );
  }

  /// Post a snapshot of the current map scores (POST /map/snapshot).
  /// Sets [snapshotSaved] to true on success and reloads map data.
  Future<void> saveSnapshot() async {
    final current = state.valueOrNull ?? const PhilosophyMapState();
    state = AsyncData(current.copyWith(isLoading: true, clearError: true));

    await _repo.saveMapSnapshot();

    // Reload to pick up the newly saved snapshot from the server.
    final result = await _repo.getPhilosophyMap();
    result.when(
      success: (mapData) {
        state = AsyncData(
          (state.valueOrNull ?? const PhilosophyMapState()).copyWith(
            mapData: mapData,
            isLoading: false,
            snapshotSaved: true,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          (state.valueOrNull ?? const PhilosophyMapState()).copyWith(
            isLoading: false,
            error: message,
          ),
        );
      },
    );
  }

  /// Returns the category name with the highest score, or 'stoicism' as fallback.
  String get dominantCategory {
    final scores =
        state.valueOrNull?.mapData?.current.toMap() ?? const {};
    if (scores.isEmpty) return 'stoicism';
    return scores.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final philosophyMapControllerProvider =
    AsyncNotifierProvider<PhilosophyMapController, PhilosophyMapState>(
  PhilosophyMapController.new,
);

/// Sync convenience provider — returns current state with a loading fallback.
final philosophyMapStateProvider = Provider<PhilosophyMapState>((ref) {
  return ref.watch(philosophyMapControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const PhilosophyMapState(isLoading: true),
      );
});

