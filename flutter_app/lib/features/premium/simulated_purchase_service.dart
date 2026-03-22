import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/local/settings_local_ds.dart';
import 'premium_purchase_service.dart';

/// Simulated purchase service for dev/testing mode.
///
/// Bypasses real IAP entirely — unlocks are stored locally via SharedPreferences.
/// Same [PurchaseResult] / [PurchaseOutcome] types as the real service.
/// Active only when [kDebugMode] is true.
class SimulatedPurchaseService {
  SimulatedPurchaseService({required this.ref});

  final Ref ref;

  static const _kSimulatedPacksKey = 'mindscroll_dev_simulated_packs';
  static const _kSimulatedInsideKey = 'mindscroll_dev_simulated_inside';

  // ── Inside (premium) ────────────────────────────────────────────────────

  Future<PurchaseResult> simulateInsidePurchase() async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate delay
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSimulatedInsideKey, true);
    await const SettingsLocalDataSource().setPremium(true);
    return const PurchaseResult(PurchaseOutcome.success);
  }

  Future<bool> isInsideSimulated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSimulatedInsideKey) ?? false;
  }

  // ── Individual packs ────────────────────────────────────────────────────

  Future<PurchaseResult> simulatePackPurchase(String packId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // simulate delay
    final packs = await getSimulatedPacks();
    if (!packs.contains(packId)) {
      packs.add(packId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_kSimulatedPacksKey, packs);
      // Also update the owned packs cache
      await const SettingsLocalDataSource().setOwnedPacks(packs);
    }
    return const PurchaseResult(PurchaseOutcome.success);
  }

  Future<List<String>> getSimulatedPacks() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_kSimulatedPacksKey) ?? [];
  }

  Future<bool> isPackSimulated(String packId) async {
    final packs = await getSimulatedPacks();
    return packs.contains(packId);
  }

  // ── Reset ───────────────────────────────────────────────────────────────

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSimulatedPacksKey);
    await prefs.remove(_kSimulatedInsideKey);
    await const SettingsLocalDataSource().setPremium(false);
    await const SettingsLocalDataSource().setOwnedPacks([]);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final simulatedPurchaseServiceProvider =
    Provider<SimulatedPurchaseService>((ref) {
  return SimulatedPurchaseService(ref: ref);
});
