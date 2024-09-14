import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/enums.dart';

class SubscriptionService {
  final Entitlement _entitlement = Entitlement.free;

  SubscriptionService() {
    init();
    updatePurchaserStatus();
  }

  Entitlement get entitlement => _entitlement;

  Future<void> init() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) async {
      updatePurchaserStatus();
    });
  }

  static Future<List<EntitlementInfo>> updatePurchaserStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();
    final entitlements = customerInfo.entitlements.active.values.toList();
    return entitlements;
  }
}
