import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Chat exceptions.
@immutable
class ChatsException implements Exception {
  final String message;

  const ChatsException({required this.message});

  @override
  String toString() {
    return message;
  }
}

/// Throws Firebase firestore exceptions.
ChatsException getFirestoreException(FirebaseException e) {
  final ChatsException exception;

  if (e.code == 'not-found') {
    exception = const ChatsException(message: 'Seems like we can\'t find the requested resource.');
  } else if (e.code == 'permission-denied') {
    exception = const ChatsException(message: 'Permission denied to perform the requested operation');
  } else if (e.code == 'unauthenticated') {
    exception = const ChatsException(message: 'Seems like you have been signed out. Please sign in again');
  } else if (e.code == 'unavailable') {
    exception = const ChatsException(message: 'Service unavailable. Please try again later');
  } else {
    exception = const ChatsException(message: 'Ohh! Looks like we are having issues signing you in.');
  }

  return exception;
}


// Authentication Exception.
@immutable
class AuthException implements Exception {
  final String message;

  const AuthException({required this.message});

  @override
  String toString() {
    return message;
  }
}

/// Throws Firebase authentication exceptions.
AuthException getAuthException(FirebaseAuthException e) {
  final AuthException exception;

  if (e.code == 'user-disabled') {
    exception = const AuthException(message: 'This account has been disabled. Please enable your account to continue');
  } else {
    exception = AuthException(message: '${e.message}');
  }

  return exception;
}
