import 'dart:async';
import 'package:emmie/providers/chats_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'l10n/l10n.dart';

import 'models/user_model.dart';
import 'providers/auth_providers.dart';
import 'providers/emmie_providers.dart';
import 'providers/firebase_providers.dart';
import 'providers/user_providers.dart';
import 'utils/enums.dart';
import 'utils/helpers.dart';
import 'services/purchases_service.dart';
import 'utils/notifications_config.dart';
import 'utils/theme.dart';
import 'views/auth_screen.dart';
import 'views/chat_screen.dart';
import 'views/onboarding_screen.dart';

/// Handles firebase notifications in background mode.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print('---New Background Notification Message: $message---');
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Start the native splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize services and setup
  await Firebase.initializeApp();

  await PurchaseService.initPlatformState();
  await FirebaseMessaging.instance.getInitialMessage();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  // Initialize mobile ads
  MobileAds.instance.initialize();

  // Remove the native splash screen just before runApp()
  FlutterNativeSplash.remove();

  runApp(const ProviderScope(child: EmmieAI()));
}

class EmmieAI extends ConsumerStatefulWidget {
  const EmmieAI({Key? key}) : super(key: key);

  @override
  EmmieAIState createState() => EmmieAIState();
}

class EmmieAIState extends ConsumerState<EmmieAI> {
  /// Returns the app initial screen.
  Widget _determineCurrentScreen(
      {required UserModel? user, required bool userOnboarded}) {
    if (userOnboarded) {
      if (user == null) {
        return const AuthScreen();
      } else {
        return const ChatScreen();
      }
    } else {
      return const OnboardingScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialized local data
    SharedPreference(ref: ref).getSharedPreferenceData();
    // Firebase cloud messaging configuration
    NotificationsConfiguration.checkNotificationPermission(ref: ref);
    NotificationsConfiguration.getUserFcmToken(ref);
    NotificationsConfiguration.initializeInfo(context: context, ref: ref);
  }

  /// Invokes providers that initialize state providers.
  void _invokeProviders() {
    // Invoke contacts future provider to set contacts future provider.
    ref.watch(contactsFutureProvider);
    // Invoke app controls stream provider to set app controls state provider.
    ref.watch(appControlStreamProvider);
    // Invoke auth state stream provider to set user state provider.
    ref.watch(authStateChangeStramProvider);
  }

  @override
  Widget build(BuildContext context) {
    // ref.watch(authStateChangeStramProvider);
    _invokeProviders();

    // Read the user onboarding state from the provider.
    final userOnboarded = ref.read(userOnboardedStateProvider);
    // Read the user state from the provider.
    final user = ref.watch(userModelStateProvider);

    // Device token might changed not because of onTokenRefresh stream but user signing in on a different
    // device. Check for this scenario becuase onTokenRefresh will not catch this.
    if (user != null) {
      final currentDeviceToken = ref.read(fcmTokenStateProvider);
      ref
          .watch(authControllerStateNotifierProvider.notifier)
          .deviceTokenDifferent(
            user.deviceToken,
            currentDeviceToken,
          );
      // Set RevenueCat user id
      PurchaseService.setPurchasesAppUserId(appUserID: user.id);
      // Invoke to get premium offers
      ref.read(userControllerStateNotifierProvider.notifier).getAppOffers();

      // Check user subscription status.
      ref
          .read(userControllerStateNotifierProvider.notifier)
          .checkSubscription();
    }

    // Determine the theme mode based on the provider value.
    final themeMode = ref.watch(themeModeProvider) == ThemeModeOptions.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    // Get current language code.
    final languageCode = ref.watch(settingsModelStateProvider).language;
    // Set current screen
    final currentScreen =
        _determineCurrentScreen(user: user, userOnboarded: userOnboarded);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Emmie AI',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routes: ref.read(routesProvider),
      supportedLocales: L10n.all,
      locale: Locale(languageCode),
      home: currentScreen,
    );
  }
}
