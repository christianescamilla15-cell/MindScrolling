import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../core/storage/local_storage.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../data/datasources/remote/profile_remote_ds.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/repositories/profile_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return ProfileRepository(
    remote: ProfileRemoteDataSource(api),
    local: const SettingsLocalDataSource(),
  );
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class ProfileState {
  final UserProfileModel? profile;
  final bool isLoading;
  final bool isSaving;
  final bool isEditing;
  final String? error;
  final int streak;
  final int totalReflections;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.isSaving = false,
    this.isEditing = false,
    this.error,
    this.streak = 0,
    this.totalReflections = 0,
  });

  ProfileState copyWith({
    UserProfileModel? profile,
    bool? isLoading,
    bool? isSaving,
    bool? isEditing,
    String? error,
    int? streak,
    int? totalReflections,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isEditing: isEditing ?? this.isEditing,
      error: error,
      streak: streak ?? this.streak,
      totalReflections: totalReflections ?? this.totalReflections,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class ProfileController extends AsyncNotifier<ProfileState> {
  late ProfileRepository _repo;

  @override
  ProfileState build() {
    _repo = ref.watch(profileRepositoryProvider);
    return const ProfileState();
  }

  /// Load profile and local stats (streak, reflections).
  Future<void> load() async {
    state = const AsyncLoading();
    final result = await _repo.getProfile();
    final streak = (await LocalStorage.getInt('mindscroll_streak')) ?? 0;
    final reflections =
        (await LocalStorage.getInt('mindscroll_reflections')) ?? 0;

    result.when(
      success: (profile) {
        state = AsyncData(
          ProfileState(
            profile: profile,
            streak: streak,
            totalReflections: reflections,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          ProfileState(
            error: message,
            streak: streak,
            totalReflections: reflections,
          ),
        );
      },
    );
  }

  /// Toggle editing mode.
  void setEditing(bool editing) {
    final current = state.valueOrNull ?? const ProfileState();
    state = AsyncData(current.copyWith(isEditing: editing));
  }

  /// Save an updated profile and exit editing mode on success.
  Future<void> save(UserProfileModel updated) async {
    final current = state.valueOrNull ?? const ProfileState();
    state = AsyncData(current.copyWith(isSaving: true, error: null));

    final result = await _repo.saveProfile(updated);
    result.when(
      success: (_) {
        state = AsyncData(
          current.copyWith(
            profile: updated,
            isSaving: false,
            isEditing: false,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          current.copyWith(isSaving: false, error: message),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, ProfileState>(
  ProfileController.new,
);

/// Sync convenience — screens read this instead of handling AsyncValue.
final profileStateProvider = Provider<ProfileState>((ref) {
  return ref.watch(profileControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const ProfileState(isLoading: true),
      );
});

