import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/providers/core_providers.dart';
import '../../data/datasources/local/settings_local_ds.dart';

// ---------------------------------------------------------------------------
// Product identifiers
// ---------------------------------------------------------------------------

const kProductIdAndroid = 'com.mindscrolling.inside';
const kProductIdIos = 'com.mindscrolling.inside';

String get _productId => Platform.isIOS ? kProductIdIos : kProductIdAndroid;

// ---------------------------------------------------------------------------
// Purchase result
// ---------------------------------------------------------------------------

enum PurchaseOutcome { success, failed, cancelled, restored, pending }

class PurchaseResult {
  final PurchaseOutcome outcome;
  final String? errorMessage;

  const PurchaseResult(this.outcome, {this.errorMessage});
}

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

class PremiumPurchaseService {
  PremiumPurchaseService({required this.ref});

  final Ref ref;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;
  Completer<PurchaseResult>? _pendingCompleter;

  Future<void> initialize() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;

    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );

    await _loadProduct();
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _loadProduct() async {
    final response =
        await InAppPurchase.instance.queryProductDetails({_productId});
    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
    }
  }

  String get localizedPrice => _productDetails?.price ?? r'$4.99';

  bool get isProductLoaded => _productDetails != null;

  // ── Purchase flow ─────────────────────────────────────────────────────────

  Future<PurchaseResult> purchase() async {
    if (_productDetails == null) {
      await _loadProduct();
      if (_productDetails == null) {
        return const PurchaseResult(
          PurchaseOutcome.failed,
          errorMessage: 'Product not available in the store.',
        );
      }
    }

    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      return const PurchaseResult(
        PurchaseOutcome.pending,
        errorMessage: 'A purchase is already in progress.',
      );
    }

    _pendingCompleter = Completer<PurchaseResult>();
    final future = _pendingCompleter!.future;

    final purchaseParam = PurchaseParam(productDetails: _productDetails!);
    try {
      await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _resolve(PurchaseResult(PurchaseOutcome.failed, errorMessage: e.toString()));
    }

    return future;
  }

  // ── Restore flow ──────────────────────────────────────────────────────────

  Future<PurchaseResult> restore() async {
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      return const PurchaseResult(
        PurchaseOutcome.pending,
        errorMessage: 'A purchase operation is already in progress.',
      );
    }

    _pendingCompleter = Completer<PurchaseResult>();
    final future = _pendingCompleter!.future;

    try {
      await InAppPurchase.instance.restorePurchases();
    } catch (e) {
      _resolve(PurchaseResult(PurchaseOutcome.failed, errorMessage: e.toString()));
    }

    return Future.any([
      future,
      Future.delayed(
        const Duration(seconds: 10),
        () {
          _resolve(const PurchaseResult(
            PurchaseOutcome.failed,
            errorMessage: 'Restore timed out.',
          ));
          return const PurchaseResult(
            PurchaseOutcome.failed,
            errorMessage: 'Restore timed out.',
          );
        },
      ),
    ]);
  }

  // ── Purchase stream handler ───────────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // Ignore individual pack purchases — handled by PackPurchaseService.
      if (purchase.productID.startsWith('com.mindscrolling.pack.')) continue;

      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _completePurchase(purchase);
          break;
        case PurchaseStatus.error:
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          _resolve(PurchaseResult(
            PurchaseOutcome.failed,
            errorMessage: purchase.error?.message ?? 'Purchase failed.',
          ));
          break;
        case PurchaseStatus.canceled:
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
          _resolve(const PurchaseResult(PurchaseOutcome.cancelled));
          break;
      }
    }
  }

  Future<void> _completePurchase(PurchaseDetails purchase) async {
    final isRestore = purchase.status == PurchaseStatus.restored;

    try {
      final api = ref.read(apiClientProvider);
      final store = Platform.isIOS ? 'ios' : 'android';

      if (isRestore) {
        await api.post('/premium/restore', body: {
          'store': store,
          if (purchase.verificationData.serverVerificationData.isNotEmpty)
            'purchase_token':
                purchase.verificationData.serverVerificationData,
          if (purchase.purchaseID != null)
            'transaction_id': purchase.purchaseID,
        });
      } else {
        await api.post('/premium/purchase/verify', body: {
          'store': store,
          'product_id': purchase.productID,
          if (purchase.verificationData.serverVerificationData.isNotEmpty)
            'purchase_token':
                purchase.verificationData.serverVerificationData,
          if (purchase.purchaseID != null)
            'transaction_id': purchase.purchaseID,
        });
      }

      await const SettingsLocalDataSource().setPremium(true);

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      _resolve(PurchaseResult(
        isRestore ? PurchaseOutcome.restored : PurchaseOutcome.success,
      ));
    } catch (e) {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      _resolve(PurchaseResult(
        PurchaseOutcome.failed,
        errorMessage: e.toString(),
      ));
    }
  }

  void _resolve(PurchaseResult result) {
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      _pendingCompleter!.complete(result);
      _pendingCompleter = null;
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final premiumPurchaseServiceProvider =
    Provider.autoDispose<PremiumPurchaseService>((ref) {
  final service = PremiumPurchaseService(ref: ref);
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});
