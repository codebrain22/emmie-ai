import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Firebase providers
final authenticationProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);
final firebaseMessagingProvider = Provider((ref) => FirebaseMessaging.instance);
// This is a use-once provider wehn the user is created.
// Event though it will always be up-to-date with new token changes,
// You can either use userModel device token (will also be always up-to-date) or use this fcmTokenStateProvider.
final fcmTokenStateProvider = StateProvider<String>((ref) => '');
