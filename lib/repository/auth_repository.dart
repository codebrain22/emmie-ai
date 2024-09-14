import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emmie/providers/firebase_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/user_model.dart';
import '../providers/emmie_providers.dart';
import '../providers/user_providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/firebase_exceptions.dart';
import '../utils/helpers.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  final FacebookAuth _facebookSignIn;
  final Ref _ref;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
    required GoogleSignIn googleSignIn,
    required FacebookAuth facebookSignIn,
    required Ref ref,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore,
        _googleSignIn = googleSignIn,
        _facebookSignIn = facebookSignIn,
        _ref = ref;

  /// Listerns and returns a user when the Auth State changes e.g. sign in/out.
  Stream<User?> get authStateChange {
    return _firebaseAuth.authStateChanges();
  }

  /// Returns an instance of CollectionReference
  CollectionReference get _users {
    return _firestore.collection(Constants.users);
  }

  /// Signs in a user with Google.
  Future<UserModel> signInWithGoogle() async {
    try {
      // Invoke google SignIn.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      // Check if user has selected an account on popup
      if (googleUser == null) throw Exception('Signin cancelled');
      // Retrieve tokens.
      final googleAuth = await googleUser.authentication;
      // Assign tokens.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in user with credentials.
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if the user is new.
      if (userCredential.additionalUserInfo!.isNewUser) {
        _createNewUser(
            credential: userCredential, provider: Constants.providerGoogle);
      }

      return await getUserData(userId: userCredential.user!.uid).first;
    } on FirebaseAuthException catch (e) {
      final exception = getAuthException(e);
      throw Exception(exception.message);
    }
  }

  /// Signs in a user with Facebook.
  Future<UserModel> signInWithFacebook() async {
    try {
      // Invoke facebook login.
      final LoginResult loginResult = await _facebookSignIn.login();
      // Retrieve accessToken.
      final accessToken = loginResult.accessToken!.token;
      // Assign tokens.
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken);

      // Sign in user with credentials.
      UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      // Check if the user is new.
      if (userCredential.additionalUserInfo!.isNewUser) {
        _createNewUser(
            credential: userCredential, provider: Constants.providerFacebook);
      }

      return await getUserData(userId: userCredential.user!.uid).first;
    } on FirebaseAuthException catch (e) {
      final exception = getAuthException(e);
      throw Exception(exception.message);
    }
  }

  /// Signs user out of the application.
  Future<void> signOut({required UserModel user}) async {
    try {
      await _firebaseAuth.signOut();

      _ref.read(previousMessagesStateProvider.notifier).state = [];
      _ref.read(emmieAiPremiumOffers.notifier).state = [];
      _ref.read(emmieAiEntitlements.notifier).state = [];
      _ref.read(userModelStateProvider.notifier).state = null;

      SharedPreference(key: Constants.appUser).clearSharedPreferenceData();

      if (user.signInProvider == 'Google') {
        await _googleSignIn.disconnect();
      }
    } on FirebaseAuthException catch (e) {
      final exception = getAuthException(e);
      throw Exception(exception.message);
    }
  }

  /// Updates user fcm token.
  Future<void> updateDeviceToken({required String token}) async {
    try {
      final user = _ref.read(userModelStateProvider);
      if (user != null) {
        _users.doc(user.id).update({Constants.userdeviceToken: token});
      }
    } catch (e) {
      throw Exception("Could not update device token");
    }
  }

  /// Maps a new Firebase user to userModel user if the user is new.
  UserModel _constructUser(
      {required User? user, required String signInProvider}) {
    final token = _ref.read(fcmTokenStateProvider);
    final appControl = _ref.read(appControlStateProvider);

    return UserModel(
      id: user?.uid ?? '',
      username: user?.displayName ?? '',
      email: user?.email ?? '',
      photoURL: user?.photoURL ?? Constants.userDefaultIcon,
      subscribed: false,
      explorationEndDate: DateTime.now().add(const Duration(days: 1)),
      freeMessages: appControl.freeMessages,
      signInProvider: signInProvider,
      deviceToken: token,
      active: true,
    );
  }

  /// Creates new user.
  /// This is when the user is new and does not exist yet.
  void _createNewUser(
      {required UserCredential credential, required String provider}) async {
    final user = credential.user;
    // Create userModel.
    final userModel = _constructUser(user: user, signInProvider: provider);
    final settingsModel = _ref.read(settingsModelStateProvider);

    // Save the user in the database.
    await _users.doc(user?.uid).set(userModel.toMap());
    // Shared preferences
    String json = jsonEncode(settingsModel.toMap());
    SharedPreference(
            key: Constants.appSettings,
            valueType: ValueType.string,
            value: json)
        .setSharedPreferenceData();
  }

  /// Gets existing user.
  /// Uses a Stream to get real-time data e.g., when the user document state changes.
  Stream<UserModel> getUserData({required String userId}) {
    try {
      return _users.doc(userId).snapshots().map(
          (event) => UserModel.fromMap(event.data() as Map<String, dynamic>));
    } catch (e) {
      throw Exception(
          "Oh! Looks like something went wrong. Let's give it another try");
    }
  }
}

// Custom firebase exception.
@immutable
class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException({required this.message});

  @override
  String toString() {
    return message;
  }
}
