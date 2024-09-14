import 'dart:io';

import 'package:emmie/providers/emmie_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../utils/theme.dart';
import 'bottom_sheet_bar.dart';
import 'unavailable_sub_service.dart';

class SubscriptionSummary extends ConsumerWidget {
  const SubscriptionSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitlement = ref.watch(emmieAiEntitlements);
    final activeProduct = ref.watch(emmieAiActiveProducts);

    if (entitlement.isEmpty || activeProduct.isEmpty) {
      return const UnavailableSubService();
    }

    final packageTitle = activeProduct.first.title;
    final productTitle = packageTitle.contains('(') ? packageTitle.split('(')[0] : packageTitle;

    final nextPaymentDate = DateTime.parse(entitlement.first.expirationDate!);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetBar(),
          Center(
            child: Text(
              AppLocalizations.of(context)!.subscriptionSummary,
              style: const TextStyle(fontSize: 16, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 25),
          Text(
            AppLocalizations.of(context)!.youAreOnPremium,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Column(
            children: [
              _subscriptionInfoTile(
                label: AppLocalizations.of(context)!.subscription,
                value: productTitle,
              ),
              const SizedBox(height: 10),
              _subscriptionInfoTile(
                label: AppLocalizations.of(context)!.amountPaid,
                value: activeProduct.first.priceString,
              ),
              const SizedBox(height: 10),
              _subscriptionInfoTile(
                label: AppLocalizations.of(context)!.nextPayment,
                value: DateFormat('dd/MM/yyyy').format(nextPaymentDate),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () async {
                Navigator.of(context).pop();
                if (Platform.isAndroid) {
                  CommonHelpers().launchApp(
                    context: context,
                    appUrl: Constants.playstoreSubscriptionsUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  CommonHelpers().launchApp(
                    context: context,
                    appUrl: '',
                  );
                }
              },
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.cancelSubscriptionText,
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              AppLocalizations.of(context)!.cancelSubscriptionMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textFaded, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Subscription info tile.
  Row _subscriptionInfoTile({required String label, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value),
      ],
    );
  }
}
