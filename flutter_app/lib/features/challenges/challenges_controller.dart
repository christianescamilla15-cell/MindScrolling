import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../core/storage/local_storage.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../data/datasources/remote/challenge_remote_ds.dart';
import '../../data/models/challenge_model.dart';
import '../../data/repositories/challenge_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final challengeRepositoryProvider =
    FutureProvider<ChallengeRepository>((ref) async {
  final api = await ref.watch(apiClientProvider.future);
  final storage = await ref.watch(localStorageProvider.future);
  return ChallengeRepository(
    remote: ChallengeRemoteDataSource(api),
    storage: storage,
  );
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ChallengeState {
  final ChallengeModel? challenge;
  final int progress;
  final int target;
  final bool completed;
  final bool isLoading;
  final String? error;

  const ChallengeState({
    this.challenge,
    this.progress = 0,
    this.target = 8,
    this.completed = false,
    this.isLoading = false,
    this.error,
  });

  double get ratio =>
      target > 0 ? (progress / target).clamp(0.0, 1.0) : 0.0;

  ChallengeState copyWith({
    ChallengeModel? challenge,
    int? progress,
    int? target,
    bool? completed,
    bool? isLoading,
    String? error,
  }) {
    return ChallengeState(
      challenge: challenge ?? this.challenge,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      completed: completed ?? this.completed,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class ChallengesController extends AsyncNotifier<ChallengeState> {
  late ChallengeRepository _repo;

  @override
  Future<ChallengeState> build() async {
    _repo = await ref.watch(challengeRepositoryProvider.future);
    return const ChallengeState();
  }

  /// Loads today's challenge and its current progress from the repository.
  Future<void> load() async {
    state = const AsyncLoading();

    final challengeResult = await _repo.getTodayChallenge();

    challengeResult.when(
      success: (challenge) async {
        final progressResult =
            await _repo.getChallengeProgress(challenge.id);

        progressResult.when(
          success: (progressModel) {
            state = AsyncData(
              ChallengeState(
                challenge: challenge,
                progress: progressModel.progress,
                target: progressModel.target,
                completed: progressModel.completed,
              ),
            );
          },
          failure: (message, _) {
            state = AsyncData(
              ChallengeState(
                challenge: challenge,
                error: message,
              ),
            );
          },
        );
      },
      failure: (message, _) {
        state = AsyncData(
          ChallengeState(
            challenge: ChallengeModel(
              id: 'offline',
              code: 'offline_reflection',
              title: 'Daily Reflection',
              description: 'Reflect on one Stoic principle today.',
              activeDate:
                  DateTime.now().toIso8601String().substring(0, 10),
            ),
            error: message,
          ),
        );
      },
    );
  }

  /// Increments progress by one and persists it.
  Future<void> incrementProgress() async {
    final current = state.valueOrNull;
    if (current == null || current.completed) return;

    final newProgress = current.progress + 1;
    final nowCompleted = newProgress >= current.target;

    state = AsyncData(
      current.copyWith(
        progress: newProgress,
        completed: nowCompleted,
      ),
    );

    if (current.challenge != null) {
      await _repo.updateProgress(
        current.challenge!.id,
        newProgress,
        nowCompleted,
      );
    }
  }

  /// Marks the challenge as manually completed.
  Future<void> complete() async {
    final current = state.valueOrNull;
    if (current == null || current.completed || current.challenge == null) {
      return;
    }

    state = AsyncData(
      current.copyWith(
        progress: current.target,
        completed: true,
      ),
    );

    await _repo.updateProgress(
      current.challenge!.id,
      current.target,
      true,
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final challengesControllerProvider =
    AsyncNotifierProvider<ChallengesController, ChallengeState>(
  ChallengesController.new,
);

/// Synchronous convenience provider — screens use this to avoid handling
/// AsyncValue directly.
final challengeStateProvider = Provider<ChallengeState>((ref) {
  return ref.watch(challengesControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const ChallengeState(isLoading: true),
      );
});
