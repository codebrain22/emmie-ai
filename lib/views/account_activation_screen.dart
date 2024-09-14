import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../providers/user_providers.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';
import 'chat_screen.dart';

class AccountActivationScreen extends ConsumerStatefulWidget {
  static const routeName = 'account-activation-screen';

  const AccountActivationScreen({
    Key? key,
  }) : super(key: key);

  @override
  AccountActivationScreenState createState() => AccountActivationScreenState();
}

class AccountActivationScreenState extends ConsumerState<AccountActivationScreen> {
  late Image image;

  @override
  void initState() {
    super.initState();
    image = Image.asset(Constants.accountActivationImage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(image.image, context);
  }

  void activateUserAccount() {
    try {
      ref.read(userControllerStateNotifierProvider.notifier).activateUserAccount(context: context);
      final user = ref.watch(userModelStateProvider);
      if (user!.active) {
        // ignore: use_build_context_synchronously
        NotificationHandler(
          context: context,
          icon: CupertinoIcons.checkmark_circle,
          color: AppColors.primary,
          message: AppLocalizations.of(context)!.accountActivatedMessage,
        ).showSnackBar();
      }
      Navigator.of(context).pushReplacementNamed(ChatScreen.routeName);
    } catch (e) {
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: AppLocalizations.of(context)!.accountNotActivatedMessage,
      ).showSnackBar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pushReplacementNamed(ChatScreen.routeName);
          },
          icon: const Icon(CupertinoIcons.back),
        ),
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.accountActivation),
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
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: mediaQuery.height * 0.45,
                      decoration: BoxDecoration(
                        image: DecorationImage(image: image.image),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      AppLocalizations.of(context)!.activateAccount,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        AppLocalizations.of(context)!.activateAccountMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: AppColors.textFaded),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.textLight,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      onPressed: activateUserAccount,
                      child: Text(AppLocalizations.of(context)!.activateAccount),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
