import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../core/providers/core_providers.dart';
import '../premium/premium_purchase_service.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _kPackProductPrefix = 'com.mindscrolling.pack.';

/// Returns the store product ID for a given [packId].
/// Example: 'stoicism_deep' → 'com.mindscrolling.pack.stoicism_deep'
String packProductId(String packId) => '$_kPackProductPrefix$packId';

// ---------------------------------------------------------------------------
// Service
// ---------------------------------------------------------------------------

/// Handles in-app purchases for individual philosophy packs.
///
/// Listens to the same [InAppPurchase] stream as [PremiumPurchaseService] but
/// only processes events whose product ID starts with [_kPackProductPrefix].
/// On success, calls POST /packs/:id/purchase/verify to record the purchase.
class PackPurchaseService {
  PackPurchaseService({required this.ref});

  final Ref ref;

  StreamSubscription<List<PurchaseDetails>>? _subscription;
  final Map<String, ProductDetails> _productCache = {};
  Completer<PurchaseResult>? _pendingCompleter;
  String? _pendingPackId;

  Future<void> initialize() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return;
    _subscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription?.cancel(),
      onError: (_) {},
    );
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
  }

  // ── Purchase flow ─────────────────────────────────────────────────────────

  Future<PurchaseResult> purchase({
    required String packId,
    String? productIdOverride,
  }) async {
    if (_pendingCompleter != null && !_pendingCompleter!.isCompleted) {
      return const PurchaseResult(
        PurchaseOutcome.pending,
        errorMessage: 'A purchase is already in progress.',
      );
    }

    final productId = productIdOverride ?? packProductId(packId);

    // Load from cache or query the store.
    ProductDetails? product = _productCache[productId];
    if (product == null) {
      final response =
          await InAppPurchase.instance.queryProductDetails({productId});
      if (response.productDetails.isEmpty) {
        return const PurchaseResult(
          PurchaseOutcome.failed,
          errorMessage: 'Product not available in store.',
        );
      }
      product = response.productDetails.first;
      _productCache[productId] = product;
    }

    _pendingCompleter = Completer<PurchaseResult>();
    _pendingPackId = packId;

    final purchaseParam = PurchaseParam(productDetails: product);
    await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);

    return _pendingCompleter!.future;
  }

  // ── Stream handler ────────────────────────────────────────────────────────

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      // Only handle pack product IDs — ignore Inside premium events.
      if (!purchase.productID.startsWith(_kPackProductPrefix)) continue;

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
    // Resolve packId from pending state or derive from product ID.
    final packId = _pendingPackId ??
        (purchase.productID.startsWith(_kPackProductPrefix)
            ? purchase.productID.replaceFirst(_kPackProductPrefix, '')
            : null);

    if (packId == null) {
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
      _resolve(const PurchaseResult(
        PurchaseOutcome.failed,
        errorMessage: 'Unknown pack product.',
      ));
      return;
    }

    try {
      final api = ref.read(apiClientProvider);
      final store = Platform.isIOS ? 'ios' : 'android';

      await api.post('/packs/$packId/purchase/verify', body: {
        'store': store,
        'product_id': purchase.productID,
        if (purchase.verificationData.serverVerificationData.isNotEmpty)
          'purchase_token': purchase.verificationData.serverVerificationData,
        if (purchase.purchaseID != null) 'transaction_id': purchase.purchaseID,
        'amount': 2.99,
        'currency': 'USD',
      });

      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }

      _resolve(const PurchaseResult(PurchaseOutcome.success));
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
    }
    _pendingCompleter = null;
    _pendingPackId = null;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final packPurchaseServiceProvider =
    Provider.autoDispose<PackPurchaseService>((ref) {
  final service = PackPurchaseService(ref: ref);
  service.initialize();
  ref.onDispose(service.dispose);
  return service;
});
