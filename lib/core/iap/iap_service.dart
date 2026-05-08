// IAP disabled for v1.0 (Phase 1: free launch without monetisation).
// Will be re-enabled in v2.0 after transfer to Organisation account.

import 'dart:async';

const kPremiumProductId = 'koshyk_premium';

class IapService {
  IapService._();
  static final IapService instance = IapService._();

  final StreamController<bool> _premiumController =
      StreamController<bool>.broadcast();

  Stream<bool> get premiumStream => _premiumController.stream;

  bool get isAvailable => false;

  Future<void> initialize() async {}

  Future<void> restorePurchases() async {}

  Future<bool> buyPremium() async => false;

  void dispose() {
    _premiumController.close();
  }
}
