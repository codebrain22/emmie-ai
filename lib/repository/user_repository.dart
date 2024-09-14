import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmie/models/control_model.dart';
import 'package:emmie/providers/chats_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/settings_model.dart';
import '../providers/auth_providers.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/firebase_exceptions.dart';
import '../utils/helpers.dart';

class UserRepository {
  final FirebaseFirestore _firestore;
  final Ref _ref;

  UserRepository({required FirebaseFirestore firestore, required Ref ref})
      : _firestore = firestore,
        _ref = ref;

  /// Returns an instance of CollectionReference of chats.
  /// Used to access a collection and interact with it (i.e get, save document).
  CollectionReference get _users {
    return _firestore.collection(Constants.users);
  }

  /// Returns an instance of CollectionReference
  CollectionReference get _settings {
    return _firestore.collection(Constants.appControl);
  }

  Stream<ControlModel> getAppControls() {
    return _settings.doc(Constants.appControlDocumentId).snapshots().map((event) {
      return ControlModel.fromMap(event.data() as Map<String, dynamic>);
    });
  }

  /// Updates user subscription status.
  Future<void> updateUserSubscriptionStatus({required bool userSubscriptionStatus}) async {
    try {
      final user = _ref.read(userModelStateProvider);
      if (user != null) {
        _users.doc(user.id).update({Constants.subscribed: userSubscriptionStatus});
      }
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Updates user free message count.
  Future<void> updateUserFreeMessageCount({bool increaseCount = false, int increaseBy = 0}) async {
    try {
      final user = _ref.read(userModelStateProvider);
      if (user != null) {
        final int messageCount;
        if (increaseCount && user.freeMessages < 10) {
          messageCount = user.freeMessages + increaseBy;
          _users.doc(user.id).update({Constants.freeMessages: messageCount});
        } else {
          messageCount = user.freeMessages - 1;
          _users.doc(user.id).update({Constants.freeMessages: messageCount});
        }
      }
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Updates user settings.
  Future<void> updateSettings({
    required SettingsOptions settingOption,
    required bool value,
    required String language,
  }) async {
    try {
      SettingsModel settingsModel = _ref.read(settingsModelStateProvider);

      switch (settingOption) {
        case SettingsOptions.themeMode:
          settingsModel = settingsModel.copyWith(darkModeEnabled: value);
          break;
        case SettingsOptions.voiceAssistance:
          settingsModel = settingsModel.copyWith(voiceAssistanceEnabled: value);
          break;
        case SettingsOptions.notificationsMute:
          settingsModel = settingsModel.copyWith(notifictionsMuted: value);
          break;
        case SettingsOptions.notificationsPause:
          settingsModel = settingsModel.copyWith(notificationsPaused: value);
          break;
        case SettingsOptions.language:
          settingsModel = settingsModel.copyWith(language: language);
          break;
        default:
      }

      // Save changes
      String json = jsonEncode(settingsModel.toMap());
      SharedPreference(key: Constants.appSettings, valueType: ValueType.string, value: json).setSharedPreferenceData();
      _ref.read(settingsModelStateProvider.notifier).update((state) => settingsModel);
      _ref.read(themeModeProvider.notifier).update((state) => settingsModel.darkModeEnabled ? ThemeModeOptions.dark : ThemeModeOptions.light);
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Reactivate user account when it was previously deactivated.
  Future<void> activateUserAccount() async {
    try {
      final user = _ref.read(userModelStateProvider);
      if (!user!.active) {
        _users.doc(user.id).update({Constants.active: true});
      }
    } on FirebaseException catch (e) {
      final exception = getFirestoreException(e);
      throw Exception(exception.message);
    }
  }

  /// Deletes user data permanently.
  Future<void> deleteUserData({required BuildContext context}) async {
    try {
      final user = _ref.read(userModelStateProvider);
      final contactsCollection = _ref.read(contactsFutureProvider).value;

      if (user != null && contactsCollection != null) {
        await _users.doc(user.id).update({Constants.active: false});
        SharedPreference(key: Constants.appSettings).clearSharedPreferenceData();

        _ref.read(authRepositoryProvider).signOut(user: user);
      }
    } on FirebaseException catch (e) {
      throw Exception(e);
    }
  }
}
