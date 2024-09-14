import 'package:emmie/providers/emmie_providers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/control_model.dart';
import '../repository/user_repository.dart';
import '../services/subscription_service.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../services/purchases_service.dart';
import '../utils/theme.dart';

class UserController extends StateNotifier<UserState> {
  final UserRepository _userRepo;
  final Ref _ref;

  UserController({required UserRepository userRepo, required Ref ref})
      : _userRepo = userRepo,
        _ref = ref,
        super(const UserStateInitial());

  Stream<ControlModel> getAppControls() {
    try {
      return _userRepo.getAppControls();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Gets premium offers.
  Future<List<Offering>> getOffers() async {
    try {
      return await PurchaseService.getOffers();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Get app premium offers.
  void getAppOffers() async {
    final appOffers = await PurchaseService.getOffers();
    _ref.read(emmieAiPremiumOffers.notifier).state = appOffers;
    final entitlements = await getActiveEntiveEntitlement();
    _ref.read(emmieAiEntitlements.notifier).state = entitlements;
    if (entitlements.isNotEmpty) {
      final products = await getProducts(productIdentifiers: [entitlements.first.productIdentifier]);
      _ref.read(emmieAiActiveProducts.notifier).update((state) => state = products);
    }
  }

  /// Makes in-app purchases.
  Future<void> makePurchase({required BuildContext context, required Package package}) async {
    try {
      await PurchaseService.purchasePackage(package: package);
      // update user subscription status.
      final purchases = await PurchaseService.getPurchaseStatus();
      final hasSubscribed = purchases.isNotEmpty;
      await _userRepo.updateUserSubscriptionStatus(userSubscriptionStatus: hasSubscribed);
    } catch (e) {
      if (kDebugMode) {
        print("IN USER CONTROLLER: $e");
      }
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Gets current user entitlements, if any.
  Future<List<EntitlementInfo>> getActiveEntiveEntitlement() async {
    try {
      return await PurchaseService.getPurchaseStatus();
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Checks if the user is still subscribed.
  Future<void> checkSubscription() async {
    try {
      final entitlements = await SubscriptionService.updatePurchaserStatus();

      if (entitlements.isNotEmpty) {
        await _userRepo.updateUserSubscriptionStatus(userSubscriptionStatus: true);
      } else {
        await _userRepo.updateUserSubscriptionStatus(userSubscriptionStatus: false);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Updates user free message count.
  Future<void> updateUserFreeMessageCount({bool increaseCount = false, int increaseBy = 0}) async {
    try {
      await _userRepo.updateUserFreeMessageCount(increaseCount: increaseCount, increaseBy: increaseBy);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Updates user free message count.
  Future<void> awardFreeMessages({required DateTime userLastMessageDate}) async {
    try {
      final now = DateTime.now().toLocal();
      final today = DateTime(now.year, now.month, now.day);

      if (userLastMessageDate.isBefore(today)) {
        final appControls = _ref.read(appControlStateProvider);
        _userRepo.updateUserFreeMessageCount(increaseCount: true, increaseBy: appControls.freeMessages);
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Get store products.
  Future<List<StoreProduct>> getProducts({required List<String> productIdentifiers}) async {
    try {
      return await PurchaseService.getProducts(productIdentifiers: productIdentifiers);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Updates user settings.
  void updateSettings({
    required BuildContext context,
    required SettingsOptions settingOption,
    bool value = false,
    String language = Constants.appDefaultLanguage,
  }) async {
    try {
      final appLocalizations = AppLocalizations.of(context);
      await _userRepo.updateSettings(
        settingOption: settingOption,
        value: value,
        language: language,
      );
      // ignore: prefer_const_constructors
      state = UserStateSuccess(appLocalizations!.changesUpdatedAlert);
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Reactivate user account when it was previously deactivated.
  Future<void> activateUserAccount({required BuildContext context}) async {
    try {
      await _userRepo.activateUserAccount();
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Deletes user data permanently.
  Future<void> deleteUserData({required BuildContext context}) async {
    try {
      await _userRepo.deleteUserData(context: context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }
}

/// Authentication state.
class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

// States
class UserStateInitial extends UserState {
  const UserStateInitial();

  @override
  List<Object> get props => [];
}

class UserStateLoading extends UserState {
  const UserStateLoading();

  @override
  List<Object> get props => [];
}

class UserStateSuccess extends UserState {
  final String message;

  const UserStateSuccess(this.message);

  @override
  List<Object> get props => [];
}

class UserStateError extends UserState {
  final String error;

  const UserStateError(this.error);

  @override
  List<Object> get props => [error];
}
