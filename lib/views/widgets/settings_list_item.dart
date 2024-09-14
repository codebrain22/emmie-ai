import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../providers/auth_providers.dart';
import '../../providers/emmie_providers.dart';
import '../../providers/user_providers.dart';
import '../../utils/constants.dart';
import '../../utils/enums.dart';
import '../../utils/theme.dart';
import '../auth_screen.dart';
import '../languages_screen.dart';
import 'bottom_sheet_bar.dart';

class ListViewItem extends ConsumerWidget {
  final IconData icon;
  final String label;
  final SettingsItems settingItem;

  ListViewItem({
    super.key,
    required this.icon,
    required this.label,
    required this.settingItem,
  });

  final RateMyApp _rateMyApp = RateMyApp(googlePlayIdentifier: Constants.playstoreAppIdentifier);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        switch (settingItem) {
          case SettingsItems.notifications:
            showModalBottomSheet(
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
                  child: _manageNotifications(
                    context: context,
                    ref: ref,
                  ),
                ),
              ),
            );
            break;
          case SettingsItems.appearance:
            showModalBottomSheet(
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
                  child: _changeAppAppearance(
                    context: context,
                    ref: ref,
                  ),
                ),
              ),
            );
            break;
          case SettingsItems.language:
            Navigator.of(context).pushNamed(LanguageScreen.routeName);
            break;
          case SettingsItems.share:
            Share.share(
              Constants.playstoreAppURL,
              subject: 'Hey there! Check out Emmie AI, your AI chat companion! 🤖 #EmmieAI',
            );
            break;
          case SettingsItems.rateApp:
            _showRateMyApp(context: context);
            break;
          default:
            await _showDialog(context: context, ref: ref);
        }
      },
      child: Column(
        children: [
          Material(
            elevation: 0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              height: 65,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _manageNotifications({required BuildContext context, required WidgetRef ref}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 20),
      child: Column(
        children: [
          const BottomSheetBar(bottom: 10),
          Text(
            AppLocalizations.of(context)!.manageNotifications,
            style: const TextStyle(fontSize: 15, color: AppColors.textFaded),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.muteNotifications),
                  Switch(
                    activeColor: AppColors.primary,
                    value: ref.watch(settingsModelStateProvider).notifictionsMuted,
                    onChanged: (value) {
                      final userController = ref.read(userControllerStateNotifierProvider.notifier);
                      userController.updateSettings(
                        context: context,
                        settingOption: SettingsOptions.notificationsMute,
                        value: value,
                      );
                    },
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.muteNotificationsDescription,
                style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(AppLocalizations.of(context)!.pauseNotifications),
                  Switch(
                    activeColor: AppColors.primary,
                    value: ref.watch(settingsModelStateProvider).notificationsPaused,
                    onChanged: (value) {
                      final userController = ref.read(userControllerStateNotifierProvider.notifier);
                      userController.updateSettings(
                        context: context,
                        settingOption: SettingsOptions.notificationsPause,
                        value: value,
                      );
                    },
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.pauseNotificationsDescription,
                style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _changeAppAppearance({required BuildContext context, required WidgetRef ref}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15).copyWith(top: 10, bottom: 20),
      child: Column(
        children: [
          const BottomSheetBar(bottom: 10),
          Text(
            AppLocalizations.of(context)!.changeAppAppearance,
            style: const TextStyle(fontSize: 15, color: AppColors.textFaded),
          ),
          const SizedBox(height: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ref.watch(settingsModelStateProvider).darkModeEnabled
                        ? AppLocalizations.of(context)!.backToLightMode
                        : AppLocalizations.of(context)!.switchToDarkMode,
                    style: const TextStyle(color: AppColors.textFaded),
                  ),
                  Switch(
                    activeColor: AppColors.primary,
                    value: ref.watch(settingsModelStateProvider).darkModeEnabled,
                    onChanged: (value) {
                      final userController = ref.read(userControllerStateNotifierProvider.notifier);
                      userController.updateSettings(
                        context: context,
                        settingOption: SettingsOptions.themeMode,
                        value: value,
                      );
                    },
                  ),
                ],
              ),
              Text(
                AppLocalizations.of(context)!.switchThemeModeDescription,
                style: const TextStyle(fontSize: 12, color: AppColors.textFaded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRateMyApp({required BuildContext context}) {
    _rateMyApp.init().then(
          (_) => _rateMyApp.showStarRateDialog(
            context,
            title: AppLocalizations.of(context)!.rateMyAppTitle,
            message: AppLocalizations.of(context)!.rateMyAppMessage2,
            starRatingOptions: const StarRatingOptions(
              initialRating: 4,
            ),
            actionsBuilder: (context, stars) {
              return [
                // Return a list of actions (that will be shown at the bottom of the dialog).
                TextButton(
                  child: Text(AppLocalizations.of(context)!.cancel.toUpperCase()),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                RateMyAppRateButton(
                  _rateMyApp,
                  text: AppLocalizations.of(context)!.okButtonText,
                  callback: () => Navigator.pop<RateMyAppDialogButton>(context, RateMyAppDialogButton.rate),
                ),
              ];
            },
            onDismissed: () => _rateMyApp.callEvent(RateMyAppEventType.noButtonPressed),
          ),
        );
  }

  Future<dynamic> _showDialog({required BuildContext context, required WidgetRef ref}) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.signOut),
        content: Text(AppLocalizations.of(context)!.signOutDialogMessage),
        actions: [
          TextButton(
            child: Text(AppLocalizations.of(context)!.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.errorRed),
            child: Text(AppLocalizations.of(context)!.signOut),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
              ref.read(authControllerStateNotifierProvider.notifier).signOut(context: context);
            },
          ),
        ],
      ),
    );
  }
}
