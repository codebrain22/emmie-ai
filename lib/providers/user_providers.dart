import 'dart:async';

import 'package:emmie/models/control_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/user_controller.dart';
import '../models/user_model.dart';
import '../repository/user_repository.dart';
import 'emmie_providers.dart';
import 'firebase_providers.dart';

/// app firestore Settings model stream provider.
final appControlStreamProvider = StreamProvider.autoDispose((ref) {
  final appControlsStream = ref.read(userControllerStateNotifierProvider.notifier).getAppControls();
  StreamSubscription<ControlModel>? subscription;

  subscription = appControlsStream.listen((controlModel) {
    ref.read(appControlStateProvider.notifier).update((state) => controlModel);
  });

  ref.onDispose(() => subscription?.cancel());

  return appControlsStream;
});

/// User model state provider.
final userModelStateProvider = StateProvider<UserModel?>((ref) => null);

// On exploration state provider
final onExplorationStateProvider = StateProvider<bool>((ref) {
  final user = ref.read(userModelStateProvider)!;

  final now = DateTime.now().toLocal();
  final today = DateTime(now.year, now.month, now.day, now.hour, now.minute, now.second, now.millisecond, now.microsecond);

  if (kDebugMode) {
    print('1) EXP DATE: ${user.explorationEndDate}');
    print('2) EXP DATE: $today');
    print('3) EXP RESULTS: ${user.explorationEndDate.isAfter(today)}');
    print('3) EXP RESULTS: ${user.explorationEndDate.isAtSameMomentAs(today)}');
  }

  return user.explorationEndDate.isAfter(today) || user.explorationEndDate.isAtSameMomentAs(today);
});

/// Previous user state provider.
final previousMessagesStateProvider = StateProvider<List<Map<String, String>>>((ref) => []);

/// Authentication repository provider.
final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(
    firestore: ref.read(firestoreProvider),
    ref: ref,
  ),
);

/// Authentication controller provider.
final userControllerStateNotifierProvider = StateNotifierProvider<UserController, UserState>(
  ((ref) => UserController(userRepo: ref.read(userRepositoryProvider), ref: ref)),
);
