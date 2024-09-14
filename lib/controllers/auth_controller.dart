import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../models/user_model.dart';
import '../providers/user_providers.dart';
import '../repository/auth_repository.dart';
import '../utils/helpers.dart';
import '../utils/theme.dart';

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  final Ref _ref;

  AuthController({required AuthRepository authRepo, required Ref ref})
      : _authRepo = authRepo,
        _ref = ref,
        super(const AuthStateInitial());

  /// Get user authentication state change.
  Stream<User?> get authStateChange {
    return _authRepo.authStateChange;
  }

  /// Checks if the device token is the same as the previously saved one.
  void deviceTokenDifferent(
      String savedDevicedToken, String currentDeviceToken) async {
    if (savedDevicedToken != currentDeviceToken) {
      await _authRepo.updateDeviceToken(token: currentDeviceToken);
    }
  }

  /// Signs in a user with Google.
  void signInWithGoogle({required BuildContext context}) async {
    try {
      state = const AuthStateLoading();
      final user = await _authRepo.signInWithGoogle();
      _ref.read(userModelStateProvider.notifier).update((state) => user);
      state = const AuthStateSuccess('Sign in successful');
    } catch (e) {
      state = AuthStateError(e.toString());
      print("#ERROR:");
      print(e);
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Signs in a user with Facebook.
  Future<void> signInWithFacebook({required BuildContext context}) async {
    try {
      state = const AuthStateLoading();
      final user = await _authRepo.signInWithFacebook();
      _ref.read(userModelStateProvider.notifier).update((state) => user);
      state = const AuthStateSuccess('Sign in successful');
    } catch (e) {
      state = AuthStateError(e.toString());
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  // Signs out the user.
  Future<void> signOut({required BuildContext context}) async {
    try {
      final user = _ref.read(userModelStateProvider);
      await _authRepo.signOut(user: user!);
    } on FirebaseAuthException catch (e) {
      // ignore: use_build_context_synchronously
      NotificationHandler(
        context: context,
        icon: CupertinoIcons.exclamationmark_circle,
        color: AppColors.errorRed,
        message: CommonHelpers(exception: '$e').getExceptionMessage(),
      ).showSnackBar();
    }
  }

  /// Updates user fcm token.
  void updateDeviceToken({required String token}) async {
    try {
      await _authRepo.updateDeviceToken(token: token);
    } on FirebaseAuthException catch (_) {}
  }

  /// Gets existing user.
  Stream<UserModel> getUserData({required String userId}) {
    return _authRepo.getUserData(userId: userId);
  }
}

/// Authentication state.
class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// States
class AuthStateInitial extends AuthState {
  const AuthStateInitial();

  @override
  List<Object> get props => [];
}

class AuthStateLoading extends AuthState {
  const AuthStateLoading();

  @override
  List<Object> get props => [];
}

class AuthStateSuccess extends AuthState {
  final String message;

  const AuthStateSuccess(this.message);

  @override
  List<Object> get props => [];
}

class AuthStateError extends AuthState {
  final String error;

  const AuthStateError(this.error);

  @override
  List<Object> get props => [error];
}
