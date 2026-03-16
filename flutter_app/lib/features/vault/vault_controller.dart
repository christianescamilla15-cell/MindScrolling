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
// Controller
// ---------------------------------------------------------------------------

class VaultController extends StateNotifier<VaultState> {
  final VaultRepository _repository;

  VaultController(this._repository) : super(const VaultState());

  /// Load saved quotes from the vault.
  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repository.getVault();
    result.when(
      success: (items) {
        state = state.copyWith(
          items: List<QuoteModel>.from(items),
          isLoading: false,
        );
      },
      failure: (message, _) {
        state = state.copyWith(isLoading: false, error: message);
      },
    );
  }

  /// Remove a quote from the vault by its ID.
  Future<void> remove(String quoteId) async {
    // Optimistic update
    final before = List<QuoteModel>.from(state.items);
    state = state.copyWith(
      items: state.items.where((q) => q.id != quoteId).toList(),
    );
    final result = await _repository.removeFromVault(quoteId);
    if (result.isError) {
      // Revert on failure
      state = state.copyWith(items: before);
    }
  }

  /// Returns true if a quote with [id] is currently in the vault state.
  bool isInVault(String id) => state.items.any((q) => q.id == id);
}

// ---------------------------------------------------------------------------
// AsyncNotifier wrapper so the repository can be awaited before first use
// ---------------------------------------------------------------------------

class VaultNotifier extends AsyncNotifier<VaultState> {
  late VaultController _ctrl;

  @override
  VaultState build() {
    final repo = ref.watch(vaultRepositoryProvider);
    _ctrl = VaultController(repo);
    return _ctrl.state;
  }

  Future<void> load() async {
    await _ctrl.load();
    state = AsyncData(_ctrl.state);
  }

  Future<void> remove(String quoteId) async {
    await _ctrl.remove(quoteId);
    state = AsyncData(_ctrl.state);
  }

  bool isInVault(String id) => _ctrl.isInVault(id);
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

