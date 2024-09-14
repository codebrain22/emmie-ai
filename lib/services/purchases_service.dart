import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../utils/api_keys.dart';

class PurchaseService {
  /// Initialize purchases platform.
  static Future<void> initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(ApiKeys.revenueCatApiKey));
  }

  /// Gets purchases platform offerings.
  static Future<List<Offering>> getOffers() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;

      return current == null ? [] : [current];
    } on PlatformException catch (e) {
      throw Exception(e.message);
    }
  }

  /// Purchases the given package.
  static Future<void> purchasePackage({required Package package}) async {
    try {
      await Purchases.purchasePackage(package);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('PAYMENT ERROR OCCURED: ${e.message}');
      }
      throw Exception(e.message);
    }
  }

  /// Sets purchases app user id.
  static void setPurchasesAppUserId({required String appUserID}) async {
    try {
      await Purchases.logIn(appUserID);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('SET APP USER IS ERROR OCCURED: ${e.message}');
      }
      throw Exception(e.message);
    }
  }

  /// Checks if user has entitlement.
  static Future<List<EntitlementInfo>> getPurchaseStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final entitlements = customerInfo.entitlements.active.values.toList();

      return entitlements;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('UPDATE PURCHASE STATUS ERROR OCCURED: ${e.message}');
      }
      throw Exception(e.message);
    }
  }

  /// Get store products.
  static Future<List<StoreProduct>> getProducts({required List<String> productIdentifiers}) async {
    try {
      final products = await Purchases.getProducts(productIdentifiers);

      return products;
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('GET PRODUCTS ERROR OCCURED: ${e.message}');
      }
      throw Exception(e.message);
    }
  }
}
