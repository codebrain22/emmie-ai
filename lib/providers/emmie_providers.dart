import 'package:flag/flag_enum.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/chatbot_model.dart';
import '../models/control_model.dart';
import '../models/settings_model.dart';
import '../utils/helpers.dart';
import '../utils/enums.dart';
import '../views/account_activation_screen.dart';
import '../views/auth_screen.dart';
import '../views/chat_screen.dart';
import '../views/error_screen.dart';
import '../views/languages_screen.dart';
import '../views/settings_screen.dart';
import 'user_providers.dart';

// Routes provider.
final routesProvider = Provider<Map<String, Widget Function(BuildContext)>>(
  (ref) => {
    AuthScreen.routeName: (_) => const AuthScreen(),
    ChatScreen.routeName: (_) => const ChatScreen(),
    SettingsScreen.routeName: (_) => const SettingsScreen(),
    LanguageScreen.routeName: (_) => LanguageScreen(),
    AccountActivationScreen.routeName: (_) => const AccountActivationScreen(),
    ErrorScreen.routeName: (_) => const ErrorScreen(),
  },
);

/// Page Index state provider,
/// Replaces the currentPageIndex Hook used in the HomeScreen
/// This is needed to control bottom bar navigation outside the homescreen.
final pageIndexStateProvider = StateProvider<int>((ref) => 0);

// Theme mode state provider -> provides current application theme.
final themeModeProvider = StateProvider<ThemeModeOptions>(
  (ref) => ThemeModeOptions.light,
);

/// Shared preferences provider
final sharedPreferencesProvider = Provider((ref) async => await SharedPreferences.getInstance());

/// Emmie AI premium offers state provider.
final emmieAiPremiumOffers = StateProvider<List<Offering>>((ref) => []);

/// Emmie AI entitlement state provider.
final emmieAiEntitlements = StateProvider<List<EntitlementInfo>>((ref) => []);

/// Emmie AI products state provider.
final emmieAiActiveProducts = StateProvider<List<StoreProduct>>((ref) => []);

/// Internet connection state provider.
final internetStateProvider = StateProvider((ref) => false);

/// Contacts (chatbots) stateprovider for Emmie v1.0.0
/// Used to preload one chatbot.
/// In future the contacts screen will be used instead (When we have 2 or more chatbots serving unique purposes) and this might be removed.
final contactsStateProvider = StateProvider<List<ChatbotModel>>((ref) => []);

/// Onboarding state provider
final userOnboardedStateProvider = StateProvider((ref) => false);

/// app firestore Settings model state provider
final appControlStateProvider = StateProvider<ControlModel>((ref) => const ControlModel(freeMessages: 3, stopService: false));

class Language {
  final FlagsCode code;
  final String title;

  const Language({
    required this.code,
    required this.title,
  });
}

/// App language
final languageCodesProvider = Provider((ref) {
  Map<String, Language> languageMap = {
    'ar': const Language(code: FlagsCode.SA, title: 'Arabic'),
    'de': const Language(code: FlagsCode.DE, title: 'Deutsch'),
    'en': const Language(code: FlagsCode.GB, title: 'English'),
    'es': const Language(code: FlagsCode.ES, title: 'Spanish'),
    'fr': const Language(code: FlagsCode.FR, title: 'French'),
    'it': const Language(code: FlagsCode.IT, title: 'Italian'),
    'nl': const Language(code: FlagsCode.NL, title: 'Dutch'),
    'pt': const Language(code: FlagsCode.PT, title: 'Portuguese'),
    'ru': const Language(code: FlagsCode.RU, title: 'Russian'),
    'zh': const Language(code: FlagsCode.CN, title: 'Chinese'),
    'zu': const Language(code: FlagsCode.ZA, title: 'isiZulu'),
  };
  return languageMap;
});

/// Emmie AI Languages state provider
final settingsModelStateProvider = StateProvider<SettingsModel>(
  ((ref) => const SettingsModel(
        darkModeEnabled: false,
        voiceAssistanceEnabled: false,
        notifictionsMuted: false,
        notificationsPaused: false,
        language: 'en',
      )),
);

final chatbotInstructions = Provider((ref) {
  final user = ref.read(userModelStateProvider);
  final name = CommonHelpers(username: user!.username).getUserPreferredName();

  return [
    {"role": "system", "content": "Your name is Emmie AI, a personal chatbot friend developed by Enactify."},
    {"role": "system", "content": "You are a female and can talk in different languages"},
    {"role": "system", "content": "According to the app, user's name is $name. From now on, you'll refer to them as $name in your responses."},
    {"role": "system", "content": "As an AI friend, You have been programmed to simulate emotions and provide more human-like interactions."},
  ];
});

