import 'dart:convert';
import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String id;
  final String username;
  final String email;
  final String photoURL;
  final bool subscribed;
  final DateTime explorationEndDate;
  final int freeMessages;
  final String signInProvider;
  final String deviceToken;
  final bool active;

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.photoURL,
    required this.subscribed,
    required this.explorationEndDate,
    required this.freeMessages,
    required this.signInProvider,
    required this.deviceToken,
    required this.active,
  });

  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    bool? emailVerified,
    String? photoURL,
    bool? subscribed,
    DateTime? explorationEndDate,
    int? freeMessages,
    String? signInProvider,
    String? deviceToken,
    bool? active,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      photoURL: photoURL ?? this.photoURL,
      subscribed: subscribed ?? this.subscribed,
      explorationEndDate: explorationEndDate ?? this.explorationEndDate,
      freeMessages: freeMessages ?? this.freeMessages,
      signInProvider: signInProvider ?? this.signInProvider,
      deviceToken: deviceToken ?? this.deviceToken,
      active: active ?? this.active,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'username': username,
      'email': email,
      'photoURL': photoURL,
      'subscribed': subscribed,
      'explorationEndDate' : explorationEndDate.millisecondsSinceEpoch,
      'freeMessages': freeMessages,
      'signInProvider': signInProvider,
      'deviceToken': deviceToken,
      'active': active,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      username: map['username'] as String,
      email: map['email'] as String,
      photoURL: map['photoURL'] as String,
      subscribed: map['subscribed'] as bool,
      explorationEndDate: DateTime.fromMillisecondsSinceEpoch(map['explorationEndDate'] as int),
      freeMessages: map['freeMessages'] as int,
      signInProvider: map['signInProvider'] as String,
      deviceToken: map['deviceToken'] as String,
      active: map['active'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) => UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, photoURL: $photoURL, subscribed: $subscribed, explorationEndDate: $explorationEndDate, freeMessages: $freeMessages, signInProvider: $signInProvider, deviceToken: $deviceToken, active: $active)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.username == username &&
        other.email == email &&
        other.photoURL == photoURL &&
        other.subscribed == subscribed &&
        other.explorationEndDate == explorationEndDate &&
        other.freeMessages == freeMessages &&
        other.signInProvider == signInProvider &&
        other.deviceToken == deviceToken &&
        other.active == active;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        photoURL.hashCode ^
        subscribed.hashCode ^
        explorationEndDate.hashCode ^
        freeMessages.hashCode ^
        signInProvider.hashCode ^
        deviceToken.hashCode ^
        active.hashCode;
  }
}
