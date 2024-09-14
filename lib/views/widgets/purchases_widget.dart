import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/emmie_providers.dart';
import '../../providers/user_providers.dart';
import '../../utils/theme.dart';
import 'bottom_sheet_bar.dart';
import 'unavailable_sub_service.dart';

// ignore: must_be_immutable
class PremiumOffers extends HookConsumerWidget {
  List<Package> packages;

  PremiumOffers({Key? key, this.packages = const []}) : super(key: key);

  /// Premium benefit builderwidget.
  Widget _premiumBenefit({required String benefit}) {
    return Row(
      children: [
        const Icon(
          CupertinoIcons.check_mark,
          size: 16.0,
          color: AppColors.primary,
        ),
        const SizedBox(width: 6),
        Text(benefit),
      ],
    );
  }

  Future<void> subscribe({
    required BuildContext context,
    required WidgetRef ref,
    required ValueNotifier<Package> selectedPackage,
  }) async {
    Navigator.of(context).pop();
    await ref.read(userControllerStateNotifierProvider.notifier).makePurchase(
          context: context,
          package: selectedPackage.value,
        );

    // If user subscribed but usermodel not updated
    final user = ref.read(userModelStateProvider)!;
    if (!user.subscribed) {
      ref.read(userControllerStateNotifierProvider.notifier).checkSubscription();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (packages.isEmpty) {
      ref.read(userControllerStateNotifierProvider.notifier).getAppOffers();
      final offers = ref.read(emmieAiPremiumOffers);
      packages = offers.map((offer) => offer.availablePackages).expand((package) => package).toList();
    }

    if (packages.isEmpty) {
      return const UnavailableSubService();
    }

    final selectedPackage = useState(packages.first);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BottomSheetBar(bottom: 15),
          Text(
            AppLocalizations.of(context)!.goPremium,
            style: const TextStyle(fontSize: 22, color: AppColors.primary),
          ),
          Text(
            AppLocalizations.of(context)!.fullAccess,
            style: const TextStyle(fontSize: 22, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Column(
            children: [
              _premiumBenefit(benefit: AppLocalizations.of(context)!.unlimitedMessages),
              const SizedBox(height: 8),
              _premiumBenefit(benefit: AppLocalizations.of(context)!.multipleLanguages),
              const SizedBox(height: 8),
              _premiumBenefit(benefit: AppLocalizations.of(context)!.imageTextRecognition),
              const SizedBox(height: 8),
              _premiumBenefit(benefit: AppLocalizations.of(context)!.voiceAssistance),
              const SizedBox(height: 8),
              // _premiumBenefit(benefit: AppLocalizations.of(context)!.unlimitedResponses),
              // const SizedBox(height: 10),
              _premiumBenefit(benefit: AppLocalizations.of(context)!.chatWithoutAds),
            ],
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              AppLocalizations.of(context)!.chooseYourPlan,
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Column(
            children: packages.map(
              (package) {
                final packageTitle = package.storeProduct.title;
                final productTitle = packageTitle.contains('(') ? packageTitle.split('(')[0] : packageTitle;

                return Container(
                  height: 95,
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: selectedPackage.value == package ? Border.all(color: AppColors.primary, width: 2) : null,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: RadioListTile(
                      title: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(productTitle),
                        subtitle: Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: Text(
                            package.storeProduct.description,
                            style: const TextStyle(color: AppColors.textFaded, fontSize: 12),
                          ),
                        ),
                        trailing: Text(
                          package.storeProduct.priceString,
                          style: const TextStyle(),
                        ),
                      ),
                      activeColor: AppColors.primary,
                      value: package,
                      groupValue: selectedPackage.value,
                      onChanged: (value) => selectedPackage.value = value!,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
          const SizedBox(height: 10),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () => subscribe(context: context, ref: ref, selectedPackage: selectedPackage),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.creditcard,
                      color: Theme.of(context).iconTheme.copyWith(color: Colors.white).color,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      AppLocalizations.of(context)!.proceedButtonText,
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              AppLocalizations.of(context)!.cancelAnytime,
              style: const TextStyle(color: AppColors.textFaded, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
