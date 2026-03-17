import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers/core_providers.dart';
import '../../data/datasources/local/settings_local_ds.dart';
import '../../data/datasources/remote/stats_remote_ds.dart';
import '../../data/models/premium_state_model.dart';
import '../../core/utils/haptics_service.dart';
import '../../data/repositories/premium_repository.dart';
import 'premium_purchase_service.dart';

// ---------------------------------------------------------------------------
// Trial constants
// ---------------------------------------------------------------------------

const _kTrialStartKey = 'mindscroll_trial_start';
const _kTrialDurationDays = 7;

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
  final bool isTrial;
  final int trialDaysLeft;
  final bool trialExpired;
  final String? error;
  final String? successMessage;

  const PremiumUiState({
    this.premiumState = const PremiumStateModel(),
    this.isLoading = false,
    this.isPurchasing = false,
    this.isRestoring = false,
    this.isTrial = false,
    this.trialDaysLeft = 0,
    this.trialExpired = false,
    this.error,
    this.successMessage,
  });

  /// User has premium access — either paid or active trial.
  bool get isPremium => premiumState.isPremium || isTrial;

  PremiumUiState copyWith({
    PremiumStateModel? premiumState,
    bool? isLoading,
    bool? isPurchasing,
    bool? isRestoring,
    bool? isTrial,
    int? trialDaysLeft,
    bool? trialExpired,
    String? error,
    String? successMessage,
  }) {
    return PremiumUiState(
      premiumState: premiumState ?? this.premiumState,
      isLoading: isLoading ?? this.isLoading,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      isTrial: isTrial ?? this.isTrial,
      trialDaysLeft: trialDaysLeft ?? this.trialDaysLeft,
      trialExpired: trialExpired ?? this.trialExpired,
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
    // Check trial on startup
    _initTrial();
    return const PremiumUiState();
  }

  // ── Trial system (backend-driven) ─────────────────────────────────────

  Future<void> _initTrial() async {
    try {
      final api = ref.read(apiClientProvider);

      // Check premium status from backend (includes trial info)
      final response = await api.get('/premium/status');

      final trialActive = response['trial_active'] == true;
      final trialDaysLeft = (response['trial_days_left'] as num?)?.toInt() ?? 0;
      final trialExpired = response['trial_expired'] == true;
      final isPaidPremium = response['is_paid_premium'] == true;

      // Persist trial info locally for offline fallback
      final prefs = await SharedPreferences.getInstance();

      if (isPaidPremium) {
        await prefs.setString(_kTrialStartKey, 'paid');
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            premiumState: const PremiumStateModel(isPremium: true),
            isTrial: false,
            trialExpired: false,
          ),
        );
        return;
      }

      if (trialActive) {
        // Save trial start locally so offline fallback works
        final trialEnd = DateTime.now().add(Duration(days: trialDaysLeft));
        await prefs.setString(_kTrialStartKey,
            trialEnd.subtract(const Duration(days: _kTrialDurationDays)).toIso8601String());
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: true,
            trialDaysLeft: trialDaysLeft,
            trialExpired: false,
          ),
        );
        return;
      }

      if (trialExpired) {
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: false,
            trialDaysLeft: 0,
            trialExpired: true,
          ),
        );
        return;
      }

      // No trial started yet — start one via backend
      final startResponse = await api.post('/premium/start-trial', body: {});
      if (startResponse['started'] == true) {
        await prefs.setString(_kTrialStartKey, DateTime.now().toIso8601String());
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: true,
            trialDaysLeft: startResponse['trial_days_left'] ?? 7,
            trialExpired: false,
          ),
        );
      } else if (startResponse['already_used'] == true) {
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: false,
            trialDaysLeft: 0,
            trialExpired: true,
          ),
        );
      }
    } catch (_) {
      // Fallback to local trial if backend unreachable or fails
      final prefs = await SharedPreferences.getInstance();
      var trialStartStr = prefs.getString(_kTrialStartKey);

      // First time + backend failed → start trial locally
      if (trialStartStr == null || trialStartStr == 'paid') {
        if (trialStartStr != 'paid') {
          trialStartStr = DateTime.now().toIso8601String();
          await prefs.setString(_kTrialStartKey, trialStartStr);
        }
      }

      if (trialStartStr == 'paid') {
        // User already paid
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            premiumState: const PremiumStateModel(isPremium: true),
            isTrial: false,
          ),
        );
      } else {
        final start = DateTime.parse(trialStartStr!);
        final daysLeft = _kTrialDurationDays - DateTime.now().difference(start).inDays;
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: daysLeft > 0,
            trialDaysLeft: daysLeft > 0 ? daysLeft : 0,
            trialExpired: daysLeft <= 0,
          ),
        );
      }
    }
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
        HapticsService.heavyImpact();
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
        HapticsService.mediumImpact();
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

