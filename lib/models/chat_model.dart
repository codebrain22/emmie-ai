import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class ChatModel {
  final String userId;
  final String chatBotId;
  final String chatBotName;
  final DateTime? changedAt;
  final String? lastMessage;

  const ChatModel({
    required this.userId,
    required this.chatBotId,
    required this.chatBotName,
    required this.changedAt,
    required this.lastMessage,
  });

  ChatModel copyWith({
    String? userId,
    String? chatBotId,
    String? chatBotName,
    DateTime? changedAt,
    String? lastMessage,
  }) {
    return ChatModel(
      userId: userId ?? this.userId,
      chatBotId: chatBotId ?? this.chatBotId,
      chatBotName: chatBotName ?? this.chatBotName,
      changedAt: changedAt ?? this.changedAt,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userId': userId,
      'chatBotId': chatBotId,
      'chatBotName': chatBotName,
      'changedAt': changedAt?.millisecondsSinceEpoch,
      'lastMessage': lastMessage,
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      userId: map['userId'] as String,
      chatBotId: map['chatBotId'] as String,
      chatBotName: map['chatBotName'] as String,
      changedAt: map['changedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['changedAt'] as int) : null,
      lastMessage: map['lastMessage'] != null ? map['lastMessage'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ChatModel.fromJson(String source) => ChatModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatModel(userId: $userId, chatBotId: $chatBotId, chatBotName: $chatBotName, changedAt: $changedAt, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(covariant ChatModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.userId == userId &&
      other.chatBotId == chatBotId &&
      other.chatBotName == chatBotName &&
      other.changedAt == changedAt &&
      other.lastMessage == lastMessage;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
      chatBotId.hashCode ^
      chatBotName.hashCode ^
      changedAt.hashCode ^
      lastMessage.hashCode;
  }
}
