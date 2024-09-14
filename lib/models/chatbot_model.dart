import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

@immutable
class ChatbotModel {
  final String id;
  final String name;
  final String description;
  final String photoURL;
  final bool active;
  final DateTime createdAt;

  const ChatbotModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photoURL,
    required this.active,
    required this.createdAt,
  });

  ChatbotModel copyWith({
    String? id,
    String? name,
    String? description,
    String? photoURL,
    bool? active,
    DateTime? createdAt,
  }) {
    return ChatbotModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      photoURL: photoURL ?? this.photoURL,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'photoURL': description,
      'active': active,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory ChatbotModel.fromMap(Map<String, dynamic> map) {
    return ChatbotModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      photoURL: map['photoURL'] as String,
      active: map['active'] as bool,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  // String toJson() => json.encode(toMap());

  factory ChatbotModel.fromJson(String source) => ChatbotModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ChatbotModel(id: $id, name: $name, description: $description, photoURL: $photoURL, active: $active, createdAt: $createdAt)';
  }
}
