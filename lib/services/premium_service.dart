import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls access to premium features.
///
/// Usage:
/// ```dart
/// await PremiumService.instance.init();      // call once in main()
/// final ok = await PremiumService.instance.isPremium();
/// await PremiumService.instance.purchase();  // starts the store flow
/// ```
class PremiumService {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  // ── Store product ID ───────────────────────────────────────────────────────
  /// The non-consumable product ID as configured in App Store Connect /
  /// Google Play Console.
  static const String productId = 'buildhome_premium_lifetime';

  static const _premiumKey = 'is_premium_unlocked';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;

  // ── Initialisation ────────────────────────────────────────────────────────

  /// Call once at app start to listen for deferred/restored purchases.
  Future<void> init() async {
    final available = await _iap.isAvailable();
    if (!available) return;

    _sub = _iap.purchaseStream.listen(
      _handlePurchases,
      onDone: () => _sub?.cancel(),
      onError: (_) {},
    );

    // Restore previous purchases so returning users are recognised.
    await _iap.restorePurchases();
  }

  void dispose() {
    _sub?.cancel();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns true if the user has an active premium unlock.
  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) == true;
  }

  /// Initiates the in-app purchase flow.
  /// Returns true if the purchase was successfully queued to the store.
  Future<bool> purchase() async {
    final available = await _iap.isAvailable();
    if (!available) return false;

    final response = await _iap.queryProductDetails({productId});
    if (response.productDetails.isEmpty) return false;

    final purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);
    return _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Re-queries the store for previous purchases and unlocks locally if found.
  Future<void> restorePurchases() async {
    final available = await _iap.isAvailable();
    if (!available) return;
    await _iap.restorePurchases();
  }

  // ── Internal ──────────────────────────────────────────────────────────────

  Future<void> _handlePurchases(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != productId) continue;

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _unlockLocally();
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _unlockLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, true);
  }

  /// For testing only — resets the local premium flag.
  Future<void> debugRevoke() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumKey);
  }
}
