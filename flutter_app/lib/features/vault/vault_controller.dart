import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/datasources/remote/vault_remote_ds.dart';
import '../../data/models/quote_model.dart';
import '../../data/repositories/vault_repository.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return VaultRepository(remote: VaultRemoteDataSource(api));
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class VaultState {
  final List<QuoteModel> items;
  final bool isLoading;
  final String? error;

  const VaultState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  VaultState copyWith({
    List<QuoteModel>? items,
    bool? isLoading,
    String? error,
  }) {
    return VaultState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier — single class, eliminates VaultController intermediary
//
// The previous two-class pattern (VaultController + VaultNotifier) broke
// optimistic updates: VaultController mutated its own StateNotifier state
// but VaultNotifier only synced manually after each await, so interim state
// changes (e.g., the optimistic removal) never reached the UI.
// ---------------------------------------------------------------------------

class VaultNotifier extends AsyncNotifier<VaultState> {
  @override
  VaultState build() => const VaultState();

  VaultRepository get _repo => ref.read(vaultRepositoryProvider);

  VaultState get _current => state.valueOrNull ?? const VaultState();

  /// Load saved quotes from the vault.
  Future<void> load() async {
    state = AsyncData(_current.copyWith(isLoading: true, error: null));
    final result = await _repo.getVault();
    result.when(
      success: (items) {
        state = AsyncData(
          _current.copyWith(
            items: List<QuoteModel>.from(items),
            isLoading: false,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(_current.copyWith(isLoading: false, error: message));
      },
    );
  }

  /// Remove a quote from the vault by its ID.
  /// Optimistic update: UI reflects removal immediately; reverts on failure.
  Future<void> remove(String quoteId) async {
    final before = _current;
    // Optimistic update — triggers immediate UI rebuild
    state = AsyncData(
      before.copyWith(
        items: before.items.where((q) => q.id != quoteId).toList(),
      ),
    );
    final result = await _repo.removeFromVault(quoteId);
    if (result.isError) {
      state = AsyncData(before); // revert on failure
    }
  }

  /// Returns true if a quote with [id] is currently in the vault state.
  bool isInVault(String id) => _current.items.any((q) => q.id == id);
}

final vaultControllerProvider =
    AsyncNotifierProvider<VaultNotifier, VaultState>(VaultNotifier.new);

/// Convenience synchronous read — exposes current [VaultState] with a
/// loading fallback so screens don't need to handle AsyncValue directly.
final vaultStateProvider = Provider<VaultState>((ref) {
  return ref.watch(vaultControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const VaultState(isLoading: true),
      );
});
