import 'package:emmie/l10n/l10n.dart';
import 'package:flag/flag_enum.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../controllers/user_controller.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'widgets/banner_ads_widget.dart';
import 'widgets/purchases_widget.dart';

// ignore: must_be_immutable
class LanguageScreen extends ConsumerWidget {
  static const routeName = 'language';
  List<Package> packages = [];
  bool showLanguagesPayWall = false;
  LanguageScreen({super.key});

  List<Widget> _getlanguageTiles({
    required BuildContext context,
    required WidgetRef ref,
    required String currentLanguageCode,
    required Map<String, Language> languageCodes,
  }) {
    return List<Widget>.generate(L10n.all.length, (index) {
      final locale = L10n.all[index];
      final flagCode = languageCodes[locale.languageCode]!.code;
      final title = languageCodes[locale.languageCode]!.title;
      return _languageTile(
        context: context,
        ref: ref,
        languageCode: locale.languageCode,
        currentLanguageCode: currentLanguageCode,
        flagCode: flagCode,
        title: title,
      );
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userModelStateProvider);
    final onExploration = ref.watch(onExplorationStateProvider);
    final currentLanguageCode = ref.watch(settingsModelStateProvider).language;
    final languageCodes = ref.watch(languageCodesProvider);

    final languageTiles = _getlanguageTiles(context: context, ref: ref, currentLanguageCode: currentLanguageCode, languageCodes: languageCodes);

    final offers = ref.watch(emmieAiPremiumOffers);
    packages = offers.map((offer) => offer.availablePackages).expand((package) => package).toList();

    // Listen to UserController State to show effects.
    ref.listen(userControllerStateNotifierProvider, (previousState, currentState) {
      if (currentState is UserStateSuccess) {
        NotificationHandler(
          context: context,
          icon: Icons.check_circle_outline_rounded,
          color: AppColors.successGreen,
          message: currentState.message,
        ).showSnackBar();
      } else if (currentState is UserStateError) {
        NotificationHandler(
          context: context,
          icon: Icons.error_outline_rounded,
          color: AppColors.errorRed,
          message: currentState.error,
        ).showSnackBar();
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(CupertinoIcons.back),
        ),
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.language),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flag.fromCode(
                          languageCodes[currentLanguageCode]?.code ?? FlagsCode.GB,
                          height: 50,
                          width: 50,
                          fit: BoxFit.fill,
                          flagSize: FlagSize.size_1x1,
                          borderRadius: 25,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.currentLanguage,
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                languageCodes[currentLanguageCode]?.title ?? "English",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: AppColors.textFaded),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (!currentUser!.subscribed && !onExploration) const SizedBox(height: 10),
              if (!currentUser.subscribed && !onExploration) const Center(child: BannerAds()),
              const SizedBox(height: 15),
              Text(
                AppLocalizations.of(context)!.changeLanguage,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.textFaded,
                ),
              ),
              const SizedBox(height: 15),
              Expanded(
                child: ListView.builder(
                  itemCount: languageTiles.length,
                  itemBuilder: (context, index) => languageTiles[index],
                ),
              ),
            ].animate().fadeIn(duration: 500.milliseconds),
          ),
        ),
      ),
    );
  }

  Widget _languageTile({
    required BuildContext context,
    required WidgetRef ref,
    required String languageCode,
    required String currentLanguageCode,
    required FlagsCode flagCode,
    required String title,
  }) {
    return ListTileTheme(
      contentPadding: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: () {
          if (languageCode == currentLanguageCode) {
            NotificationHandler(
              context: context,
              icon: CupertinoIcons.info_circle,
              color: AppColors.primary,
              message: AppLocalizations.of(context)!.languageAlreadySelected(title),
            ).showSnackBar();
          } else {
            final user = ref.read(userModelStateProvider);
            final onExploration = ref.watch(onExplorationStateProvider);

            if ((user!.subscribed || onExploration) || languageCode == 'en') {
              final userController = ref.read(userControllerStateNotifierProvider.notifier);
              userController.updateSettings(
                context: context,
                settingOption: SettingsOptions.language,
                language: languageCode,
              );
            } else {
              if (showLanguagesPayWall) {
                _subscriptionPaywallBottomSheet(context: context, packages: packages);
              } else {
                NotificationHandler(
                  context: context,
                  icon: CupertinoIcons.info_circle,
                  color: AppColors.primary,
                  message: AppLocalizations.of(context)!.languagesArePremiumFeature,
                ).showSnackBar();
                showLanguagesPayWall = true;
              }
            }
          }
        },
        leading: Flag.fromCode(
          flagCode,
          width: 40,
          height: 40,
          fit: BoxFit.fill,
          flagSize: FlagSize.size_1x1,
          borderRadius: 50,
        ),
        title: Text(title),
        subtitle: languageCode == 'en'
            ? Text(
                AppLocalizations.of(context)!.defaultLanguage,
                style: const TextStyle(
                  color: AppColors.textFaded,
                ),
              )
            : null,
      ),
    );
  }

  /// Subscription paywall bottom sheet.
  Future<dynamic> _subscriptionPaywallBottomSheet({required BuildContext context, required List<Package> packages}) {
    return showModalBottomSheet(
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      backgroundColor: Theme.of(context).cardColor,
      context: context,
      builder: (_) => SizedBox(
        child: SingleChildScrollView(
          child: PremiumOffers(packages: packages),
        ),
      ),
    );
  }
}
