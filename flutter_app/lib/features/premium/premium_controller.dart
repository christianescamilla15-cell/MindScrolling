import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/core_providers.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../data/datasources/remote/stats_remote_ds.dart';
import '../../data/models/premium_state_model.dart';
import '../../data/repositories/premium_repository.dart';
import 'premium_purchase_service.dart';

// ---------------------------------------------------------------------------
// Repository provider
// ---------------------------------------------------------------------------

final premiumRepositoryProvider =
    Provider<PremiumRepository>((ref) {
  final api = ref.watch(apiClientProvider);
  return PremiumRepository(
    remote: StatsRemoteDataSource(api),
    local: const SettingsLocalDataSource(),
  );
});

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PremiumUiState {
  final PremiumStateModel premiumState;
  final bool isLoading;
  final bool isPurchasing;
  final bool isRestoring;
  final String? error;
  final String? successMessage;

  const PremiumUiState({
    this.premiumState = const PremiumStateModel(),
    this.isLoading = false,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.error,
    this.successMessage,
  });

  bool get isPremium => premiumState.isPremium;

  PremiumUiState copyWith({
    PremiumStateModel? premiumState,
    bool? isLoading,
    bool? isPurchasing,
    bool? isRestoring,
    String? error,
    String? successMessage,
  }) {
    return PremiumUiState(
      premiumState: premiumState ?? this.premiumState,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      error: error,
      successMessage: successMessage,
    );
  }
}

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class PremiumController extends AsyncNotifier<PremiumUiState> {
  late PremiumRepository _repo;

  @override
  PremiumUiState build() {
    _repo = ref.watch(premiumRepositoryProvider);
    return const PremiumUiState();
  }

  /// Checks current premium status from the server (with local fallback).
  Future<void> checkStatus() async {
    final current = state.valueOrNull ?? const PremiumUiState();
    state = AsyncData(current.copyWith(isLoading: true, error: null));

    final result = await _repo.getStatus();

    result.when(
      success: (premiumState) {
        state = AsyncData(
          current.copyWith(
            premiumState: premiumState,
            isLoading: false,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          current.copyWith(isLoading: false, error: message),
        );
      },
    );
  }

  /// Initiates the premium unlock flow.
  ///
  /// [purchaseData] is an opaque map that may carry receipt or IAP payload
  /// data for server-side validation. For simple one-time purchases it can
  /// be empty.
  Future<void> unlock({Map<String, dynamic> purchaseData = const {}}) async {
    final current = state.valueOrNull ?? const PremiumUiState();
    if (current.isPremium || current.isPurchasing) return;

    state = AsyncData(
      current.copyWith(isPurchasing: true, error: null, successMessage: null),
    );

    final result = await _repo.unlock(
      amount: 2.99,
      currency: 'USD',
    );

    result.when(
      success: (_) {
        state = AsyncData(
          current.copyWith(
            premiumState: const PremiumStateModel(
              isPremium: true,
              purchaseType: 'premium_unlock',
              purchasedAt: null,
            ),
            isPurchasing: false,
            successMessage: 'Premium unlocked! Thank you.',
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          current.copyWith(isPurchasing: false, error: message),
        );
      },
    );
  }

  /// Initiates a real in-app purchase via [PremiumPurchaseService].
  Future<void> purchasePremium() async {
    final current = state.valueOrNull ?? const PremiumUiState();
    if (current.isPremium || current.isPurchasing) return;

    state = AsyncData(
      current.copyWith(isPurchasing: true, error: null, successMessage: null),
    );

    final service = ref.read(premiumPurchaseServiceProvider);
    final result = await service.purchase();
    final updated = state.valueOrNull ?? const PremiumUiState();

    switch (result.outcome) {
      case PurchaseOutcome.success:
        state = AsyncData(updated.copyWith(
          premiumState: const PremiumStateModel(isPremium: true, purchaseType: 'premium_unlock'),
          isPurchasing: false,
          successMessage: 'purchaseSuccess',
        ));
      case PurchaseOutcome.cancelled:
        state = AsyncData(updated.copyWith(isPurchasing: false));
      case PurchaseOutcome.failed:
      case PurchaseOutcome.pending:
        state = AsyncData(updated.copyWith(
          isPurchasing: false,
          error: result.errorMessage ?? 'purchaseFailed',
        ));
      case PurchaseOutcome.restored:
        state = AsyncData(updated.copyWith(
          premiumState: const PremiumStateModel(isPremium: true),
          isPurchasing: false,
          successMessage: 'restoreSuccess',
        ));
    }
  }

  /// Restores previous purchases via [PremiumPurchaseService].
  Future<void> restorePurchases() async {
    final current = state.valueOrNull ?? const PremiumUiState();
    if (current.isRestoring) return;

    state = AsyncData(
      current.copyWith(isRestoring: true, error: null, successMessage: null),
    );

    final service = ref.read(premiumPurchaseServiceProvider);
    final result = await service.restore();
    final updated = state.valueOrNull ?? const PremiumUiState();

    switch (result.outcome) {
      case PurchaseOutcome.restored:
        state = AsyncData(updated.copyWith(
          premiumState: const PremiumStateModel(isPremium: true),
          isRestoring: false,
          successMessage: 'restoreSuccess',
        ));
      case PurchaseOutcome.failed:
        state = AsyncData(updated.copyWith(
          isRestoring: false,
          error: result.errorMessage ?? 'restoreFailed',
        ));
      default:
        state = AsyncData(updated.copyWith(
          isRestoring: false,
          error: 'noPurchasesFound',
        ));
    }
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final premiumControllerProvider =
    AsyncNotifierProvider<PremiumController, PremiumUiState>(
  PremiumController.new,
);

/// Synchronous convenience — screens read this to avoid handling AsyncValue.
final premiumStateProvider = Provider<PremiumUiState>((ref) {
  return ref.watch(premiumControllerProvider).maybeWhen(
        data: (s) => s,
        orElse: () => const PremiumUiState(isLoading: true),
      );
});

