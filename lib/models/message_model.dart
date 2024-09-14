import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class MessageModel {
  final String message;
  final String senderId;
  final DateTime createdAt;

  const MessageModel({
    required this.message,
    required this.senderId,
    required this.createdAt,
  });

  MessageModel copyWith({
    String? id,
    String? message,
    String? senderId,
    String? recipeintId,
    DateTime? createdAt,
  }) {
    return MessageModel(
      message: message ?? this.message,
      senderId: senderId ?? this.senderId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'message': message,
      'senderId': senderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      message: map['message'] as String,
      senderId: map['senderId'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory MessageModel.fromJson(String source) => MessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MessageModel(message: $message, senderId: $senderId, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant MessageModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.message == message &&
      other.senderId == senderId &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return message.hashCode ^
      senderId.hashCode ^
      createdAt.hashCode;
  }
}
