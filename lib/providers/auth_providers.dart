import 'dart:async';
import 'dart:convert';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../controllers/auth_controller.dart';
import '../models/user_model.dart';
import '../repository/auth_repository.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/helpers.dart';
import 'firebase_providers.dart';
import 'user_providers.dart';

final googleSignInProvider = Provider(((ref) => GoogleSignIn()));
final facebookSignInProvider = Provider(((ref) => FacebookAuth.instance));

/// Authentication repository provider.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    firestore: ref.read(firestoreProvider),
    firebaseAuth: ref.read(authenticationProvider),
    googleSignIn: ref.read(googleSignInProvider),
    facebookSignIn: ref.read(facebookSignInProvider),
    ref: ref,
  ),
);

/// Authentication controller provider.
final authControllerStateNotifierProvider = StateNotifierProvider<AuthController, AuthState>(
  ((ref) => AuthController(authRepo: ref.watch(authRepositoryProvider), ref: ref)),
);

/// Authentication state changes stream provider.
final authStateChangeStramProvider = StreamProvider((ref) {
  final authController = ref.read(authControllerStateNotifierProvider.notifier);
  final authStateChange = authController.authStateChange;
  StreamSubscription<UserModel>? userModelListener;

  // Subscribe to the auth state change stream.
  final authStateChangeListener = authStateChange.listen((user) {
    if (user != null) {
      final userModel = authController.getUserData(userId: user.uid);
      userModelListener = userModel.listen((result) {
        ref.read(userModelStateProvider.notifier).update((state) => result);
        String json = jsonEncode(result.toMap());
        SharedPreference(key: Constants.appUser, valueType: ValueType.string, value: json).setSharedPreferenceData();
      });
    }
  });

  // Unsubscribe to the stream listeners when this provider is disposed.
  ref.onDispose(() {
    userModelListener?.cancel();
    authStateChangeListener.cancel();
  });

  return authStateChange;
});
