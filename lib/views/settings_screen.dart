import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'auth_screen.dart';
import 'error_screen.dart';
import 'widgets/avatar.dart';
import 'widgets/banner_ads_widget.dart';
import 'widgets/purchases_widget.dart';
import 'widgets/settings_list_item.dart';
import 'widgets/subscription_summary.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  static const routeName = 'settings';
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<dynamic> _showDialog({required BuildContext context, required WidgetRef ref}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.requestAccountDeletionTitle),
        content: Text(AppLocalizations.of(context)!.requestAccountDeletionMessage),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: Text(AppLocalizations.of(context)!.proceedButtonText),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
              ref.read(userControllerStateNotifierProvider.notifier).deleteUserData(context: context);
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Check user subscription status.
    ref.read(userControllerStateNotifierProvider.notifier).checkSubscription();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userModelStateProvider);
    final onExploration = ref.watch(onExplorationStateProvider);
    final hasInternet = ref.watch(internetStateProvider);
    const sizedBox = SizedBox(height: 15);

    final offers = ref.watch(emmieAiPremiumOffers);
    final packages = offers.map((offer) => offer.availablePackages).expand((package) => package).toList();

    // For some reason, should the user be null, show the error screen.
    // The loader will be shown by the Riverpod when method.
    // When you have reached here, it is assumed that the user should
    // have been set, therefore if not, then show error.
    if (currentUser == null) {
      return ErrorScreen(
        title: AppLocalizations.of(context)!.emmieAiUnavailableTitle,
        message: AppLocalizations.of(context)!.emmieAiUnavailableMessage,
        description: AppLocalizations.of(context)!.emmieAiUnavailableDesc,
      );
    }

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
        title: Text(AppLocalizations.of(context)!.settings),
        actions: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            onSelected: (AppUserActions selectedValue) {
              if (hasInternet) {
                _showDialog(context: context, ref: ref);
              } else {
                NotificationHandler(
                  context: context,
                  icon: CupertinoIcons.wifi_exclamationmark,
                  color: AppColors.errorRed,
                  message: AppLocalizations.of(context)!.noInternetConnection,
                ).showSnackBar();
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: AppUserActions.delete,
                child: Row(
                  children: [
                    const Icon(
                      CupertinoIcons.delete,
                      color: AppColors.iconRed,
                    ),
                    const SizedBox(width: 10),
                    Text(AppLocalizations.of(context)!.requestAccountDeletionTitle),
                  ],
                ),
              ),
            ],
            child: const Icon(CupertinoIcons.ellipsis_vertical),
          ),
        ],
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
          child: SingleChildScrollView(
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
                          Avatar.medium(
                            color: Theme.of(context).cardColor,
                            widget: CachedNetworkImageProvider(currentUser.photoURL),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentUser.username,
                                  style: const TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  currentUser.email,
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
                if (!currentUser.subscribed && !onExploration) const SizedBox(height: 10),
                if (!currentUser.subscribed && !onExploration) const Center(child: BannerAds()),
                sizedBox,
                _listItemsDividerLabel(AppLocalizations.of(context)!.subscriptionStatus),
                sizedBox,
                Stack(
                  children: [
                    Material(
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        onTap: () {
                          // Check user subscription status.
                          ref.read(userControllerStateNotifierProvider.notifier).checkSubscription();

                          showModalBottomSheet(
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
                                child: currentUser.subscribed ? const SubscriptionSummary() : PremiumOffers(packages: packages),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10).copyWith(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Avatar.medium(
                                  color: AppColors.primary,
                                  widget: AssetImage(currentUser.subscribed ? Constants.premiumImage : Constants.freeVersionImage),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        currentUser.subscribed
                                            ? AppLocalizations.of(context)!.youAreOnPremium
                                            : AppLocalizations.of(context)!.youAreOnFreeVersion,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        currentUser.subscribed
                                            ? AppLocalizations.of(context)!.viewSubscriptions
                                            : AppLocalizations.of(context)!.explorePremiumFeatures,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.textLight),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.cardLight,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                sizedBox,
                _listItemsDividerLabel(AppLocalizations.of(context)!.preferences),
                sizedBox,
                ListViewItem(
                  icon: CupertinoIcons.moon,
                  label: AppLocalizations.of(context)!.appearance,
                  settingItem: SettingsItems.appearance,
                ),
                sizedBox,
                ListViewItem(
                  icon: CupertinoIcons.globe,
                  label: AppLocalizations.of(context)!.language,
                  settingItem: SettingsItems.language,
                ),
                sizedBox,
                _listItemsDividerLabel(AppLocalizations.of(context)!.general),
                sizedBox,
                ListViewItem(
                  icon: CupertinoIcons.star,
                  label: AppLocalizations.of(context)!.rateApp,
                  settingItem: SettingsItems.rateApp,
                ),
                sizedBox,
                ListViewItem(
                  icon: Icons.share_outlined,
                  label: AppLocalizations.of(context)!.share,
                  settingItem: SettingsItems.share,
                ),
                sizedBox,
                ListViewItem(
                  icon: CupertinoIcons.square_arrow_left,
                  label: AppLocalizations.of(context)!.signOut,
                  settingItem: SettingsItems.signOut,
                ),
                sizedBox,
                Center(
                  child: Text(
                    'Emmie AI - ${AppLocalizations.of(context)!.poweredByChatGpt}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
                  ),
                ),
                const SizedBox(height: 2.0),
                Center(
                  child: Text(
                    '${AppLocalizations.of(context)!.appVersion} 1.1.4',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
                  ),
                ),
                const SizedBox(height: 2.0),
              ].animate().fadeIn(duration: 500.milliseconds),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listItemsDividerLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.textFaded,
      ),
    );
  }
}
