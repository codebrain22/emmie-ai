import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmie/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/message_model.dart';
import '../models/settings_model.dart';
import '../models/user_model.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import 'enums.dart';
import 'theme.dart';

/// A Data transformer class that contains data tranformer methods.
class DataTransformer<T> {
  final QuerySnapshot<Object?> collection;
  final T Function(Map<String, dynamic> dataMap) fromMap;

  const DataTransformer({required this.collection, required this.fromMap});

  /// Transforms data to relevant objects.
  List<T> transformData() {
    // List of contacts to render.
    final List<T> data = [];
    // Store all the contacts in list.
    for (var doc in collection.docs) {
      Map<String, dynamic> dataMap = {...doc.data() as Map<String, dynamic>, 'id': doc.id};
      T contact = fromMap(dataMap);
      data.add(contact);
    }
    return data;
  }
}

/// A notification handler class that conatins a method that shows UI notifiers.
class NotificationHandler {
  final BuildContext context;
  final IconData? icon;
  final Color color;
  final String? message;

  const NotificationHandler({
    Key? key,
    required this.context,
    this.icon,
    required this.color,
    this.message,
  });

  Widget showLoader() {
    return SpinKitThreeBounce(
      duration: const Duration(seconds: 1),
      color: color,
      size: 25.0,
    );
  }

  /// Displays a snackbar. Hides current snack bar if already showing.
  void showSnackBar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: color,
              ),
              const SizedBox(
                width: 10,
              ),
              Flexible(
                child: Text(
                  message!,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/// DateFormatter class that contains date formatting methods.
class DateFormatter {
  /// Formats previous dates dispalyed on some widgets.
  static String formatDate(DateTime dateTime) {
    final now = DateTime.now().toLocal();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (dateTime.isAfter(today)) {
      return DateFormat.Hm().format(dateTime);
    } else if (dateTime.isAfter(yesterday)) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM/yyyy').format(dateTime);
    }
  }

  static String getMessageDateLabel(DateTime messageDate) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (messageDate.year == now.year && messageDate.month == now.month && messageDate.day == now.day) {
      return 'Today';
    } else if (messageDate.year == yesterday.year && messageDate.month == yesterday.month && messageDate.day == yesterday.day) {
      return 'Yesterday';
    } else {
      final format = DateFormat('dd MMMM, yyyy', 'en_US');
      return format.format(messageDate);
    }
  }
}

/// Shared Preference class containing shared preferance related methods.
class SharedPreference {
  WidgetRef? ref;
  String? key;
  ValueType? valueType;
  dynamic value;

  SharedPreference({this.ref, this.key, this.valueType, this.value});

  /// Saves data into the device local storage
  void setSharedPreferenceData() async {
    // Shared preferences
    final container = ProviderContainer();
    final sharedPreferences = await container.read(sharedPreferencesProvider);

    switch (valueType) {
      case ValueType.integer:
        value = value as int;
        await sharedPreferences.setInt(key!, value);
        break;
      case ValueType.double:
        value = value as double;
        await sharedPreferences.setDouble(key!, value);
        break;
      case ValueType.boolean:
        value = value as bool;
        sharedPreferences.setBool(key!, value);
        break;
      case ValueType.stringList:
        value = value as List<String>;
        sharedPreferences.setStringList(key!, value);
        break;
      default: // String
        await sharedPreferences.setString(key!, value);
        break;
    }
    container.dispose();
  }

  /// Loads user settings
  void getSharedPreferenceData() async {
    final container = ProviderContainer();
    final sharedPreferences = await container.read(sharedPreferencesProvider);

    // Check if user must be onboarded
    bool? userOnboarded = sharedPreferences.getBool(Constants.userOnboarded);
    if (userOnboarded != null) {
      ref!.read(userOnboardedStateProvider.notifier).update((state) => userOnboarded);
    }

    // Get user details
    String? userJson = sharedPreferences.getString(Constants.appUser);
    if (userJson != null) {
      Map<String, dynamic> userMap = jsonDecode(userJson);
      final userModel = UserModel.fromMap(userMap);
      ref!.read(userModelStateProvider.notifier).state = userModel;
    }

    // Get settings Shared preferences
    String? appSettingsJson = sharedPreferences.getString(Constants.appSettings);
    if (appSettingsJson != null) {
      Map<String, dynamic> settingsMap = jsonDecode(appSettingsJson);
      final settingsModel = SettingsModel.fromMap(settingsMap);
      ref!.read(settingsModelStateProvider.notifier).update((state) => settingsModel);
      final userSettings = ref!.read(settingsModelStateProvider);
      ref!.read(themeModeProvider.notifier).update((state) => userSettings.darkModeEnabled ? ThemeModeOptions.dark : ThemeModeOptions.light);
    }
    container.dispose();
  }

  /// Saves data into the device local storage
  void clearSharedPreferenceData() async {
    // Shared preferences
    final container = ProviderContainer();
    final sharedPreferences = await container.read(sharedPreferencesProvider);

    await sharedPreferences.remove(key!);
  }
}

/// A common helper class containing all the common methods.
class CommonHelpers {
  WidgetRef? ref;
  String? username;
  String? exception;

  CommonHelpers({this.ref, this.username, this.exception});

  /// Loads all the previous or old user messages.
  static List<Map<String, String>> getPreviousMessages({
    required String userId,
    required List<Map<String, String>> chatbotInstructions,
    required List<MessageModel> messages,
  }) {
    List<Map<String, String>> prevMessages = chatbotInstructions;

    if (messages.isNotEmpty) {
      for (var message in messages) {
        Map<String, String> temp;
        if (message.senderId == userId) {
          temp = {
            'role': 'user',
            'content': message.message,
          };
        } else {
          temp = {
            'role': 'assistant',
            'content': message.message,
          };
        }
        prevMessages.add(temp);
      }
    }
    return prevMessages;
  }

  String getUserPreferredName() {
    final String name;
    if (username!.contains(' ')) {
      final userNames = username!.split(' ');
      name = userNames.first;
    } else {
      name = username!;
    }
    return name;
  }

  /// Cleans exception messages in readable format for the user.
  String getExceptionMessage() {
    if (exception != null) {
      if (exception!.contains('Null check')) {
        return 'Unknow error occured.';
      }

      if (exception!.contains('7')) {
        return 'Sign-in failed. Please verify your internet settings.';
      }

      final splittedMessage = exception!.split(':');
      if (splittedMessage.isNotEmpty) {
        return splittedMessage.length >= 2 ? splittedMessage[1] : splittedMessage.first;
      }
    }
    return "It seems you've encountered a hiccup. Let's try one more time!";
  }

  Future<void> launchApp({
    required BuildContext context,
    required appUrl,
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    try {
      final url = Uri.parse(appUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: mode);
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: 'Oh! Looks like something went wrong').getExceptionMessage(),
      ).showSnackBar();
    }
  }
}
