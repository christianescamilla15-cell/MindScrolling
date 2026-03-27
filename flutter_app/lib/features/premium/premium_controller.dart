import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/monetization_constants.dart';
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
// Dev-only: hidden override key (tap version 5× in Settings to set)
const _kDevOverrideKey = 'mindscroll_dev_state_override';

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
    // ── Dev override (hidden dev panel in Settings — tap version 5x) ────────
    // Accessible in both debug and release builds for QA testing.
    // The override key is only written by the dev panel (requires 5 taps).
    final prefs = await SharedPreferences.getInstance();
    final devOverride = prefs.getString(_kDevOverrideKey);
    if (devOverride != null) {
      _applyDevOverride(devOverride);
      return;
    }

    try {
      final api = ref.read(apiClientProvider);

      // Check premium status from backend (includes trial info)
      final response = await api.get('/premium/status');

      final trialActive = response['trial_active'] == true;
      final trialDaysLeft = (response['trial_days_left'] as num?)?.toInt() ?? 0;
      final trialExpired = response['trial_expired'] == true;
      final isPaidPremium = response['is_paid_premium'] == true;

      // Parse Block B fields: owned_packs, user_state
      final rawPacks = response['owned_packs'];
      final ownedPacks = rawPacks is List
          ? rawPacks.whereType<String>().toList()
          : <String>[];
      final userState = response['user_state'] as String?;

      if (isPaidPremium) {
        await prefs.setString(_kTrialStartKey, 'paid');
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            premiumState: PremiumStateModel(
              isPremium: true,
              ownedPacks: ownedPacks,
              userState: userState,
            ),
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
            premiumState: PremiumStateModel(
              isPremium: false,
              ownedPacks: ownedPacks,
              userState: userState,
            ),
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
            premiumState: PremiumStateModel(
              isPremium: false,
              ownedPacks: ownedPacks,
              userState: userState,
            ),
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
            trialDaysLeft: (startResponse['trial_days_left'] as num?)?.toInt() ?? 7,
            trialExpired: false,
          ),
        );
      } else if (startResponse['already_active'] == true) {
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isTrial: true,
            trialDaysLeft: (startResponse['trial_days_left'] as num?)?.toInt() ?? 7,
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

      // Offline fallback — never overwrite an existing start date.
      // Bug fix: previously wrote DateTime.now() on every failed backend call,
      // resetting the trial counter to 7 each time Render had a cold start.
      if (trialStartStr == null) {
        trialStartStr = DateTime.now().toIso8601String();
        await prefs.setString(_kTrialStartKey, trialStartStr);
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
        final start = DateTime.parse(trialStartStr);
        // Use hours for precision — inDays truncates, causing day-0 to show 7
        final hoursElapsed = DateTime.now().difference(start).inHours;
        final daysLeft = _kTrialDurationDays - (hoursElapsed / 24).floor();
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
        final snap = state.valueOrNull ?? const PremiumUiState();
        state = AsyncData(
          snap.copyWith(
            premiumState: premiumState,
            isLoading: false,
            isTrial: premiumState.isPremium ? false : snap.isTrial,
            trialExpired: premiumState.isPremium ? false : snap.trialExpired,
          ),
        );
      },
      failure: (message, _) {
        state = AsyncData(
          (state.valueOrNull ?? const PremiumUiState()).copyWith(
            isLoading: false,
            error: message,
          ),
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
      amount: MonetizationConstants.basePriceUsd,
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
            successMessage: 'purchaseSuccess',
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
        // Refresh full server state (owned_packs, userState) after successful purchase
        await _initTrial();
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

  // ── Dev tools ─────────────────────────────────────────────────────────────

  /// Sets a local premium state override for testing.
  /// [devState] is 'free' | 'trial' | 'premium' | 'reset'.
  /// Tap the version number 5× in Settings to open the dev panel.
  Future<void> devSetState(String devState) async {
    final prefs = await SharedPreferences.getInstance();
    if (devState == 'reset') {
      await prefs.remove(_kDevOverrideKey);
      await prefs.remove(_kTrialStartKey);
    } else {
      await prefs.setString(_kDevOverrideKey, devState);
    }
    state = const AsyncLoading();
    await _initTrial();
  }

  void _applyDevOverride(String devState) {
    final current = state.valueOrNull ?? const PremiumUiState();
    switch (devState) {
      case 'free':
        state = AsyncData(current.copyWith(
          premiumState: const PremiumStateModel(isPremium: false),
          isTrial: false, trialDaysLeft: 0, trialExpired: true,
        ));
      case 'trial':
        state = AsyncData(current.copyWith(
          premiumState: const PremiumStateModel(isPremium: false),
          isTrial: true, trialDaysLeft: 6, trialExpired: false,
        ));
      case 'premium':
        state = AsyncData(current.copyWith(
          premiumState: const PremiumStateModel(isPremium: true),
          isTrial: false, trialDaysLeft: 0, trialExpired: false,
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
        // HIGH-04: Re-fetch /premium/status so owned_packs is populated from
        // the server. We set isRestoring: false + successMessage first so the
        // UI can react immediately, then let _initTrial refresh the full state.
        state = AsyncData(updated.copyWith(
          isRestoring: false,
          successMessage: 'restoreSuccess',
        ));
        await _initTrial();
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

