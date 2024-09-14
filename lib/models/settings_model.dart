import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class SettingsModel {
  final bool darkModeEnabled;
  final bool voiceAssistanceEnabled;
  final bool notifictionsMuted;
  final bool notificationsPaused;
  final String language;

  const SettingsModel(
      {required this.darkModeEnabled,
      required this.voiceAssistanceEnabled,
      required this.notifictionsMuted,
      required this.notificationsPaused,
      required this.language});

  SettingsModel copyWith({bool? darkModeEnabled, bool? voiceAssistanceEnabled, bool? notifictionsMuted, bool? notificationsPaused, String? language}) {
    return SettingsModel(
        darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
        voiceAssistanceEnabled: voiceAssistanceEnabled ?? this.voiceAssistanceEnabled,
        notifictionsMuted: notifictionsMuted ?? this.notifictionsMuted,
        notificationsPaused: notificationsPaused ?? this.notificationsPaused,
        language: language ?? this.language);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'darkModeEnabled': darkModeEnabled,
      'voiceAssistanceEnabled': voiceAssistanceEnabled,
      'notifictionsMuted': notifictionsMuted,
      'notificationsPaused': notificationsPaused,
      "language": language,
    };
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      darkModeEnabled: map['darkModeEnabled'] as bool,
      voiceAssistanceEnabled: map['voiceAssistanceEnabled'] as bool,
      notifictionsMuted: map['notifictionsMuted'] as bool,
      notificationsPaused: map['notificationsPaused'] as bool,
      language: map['language'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SettingsModel.fromJson(String source) => SettingsModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SettingsModel(darkModeEnabled: $darkModeEnabled, voiceAssistanceEnabled: $voiceAssistanceEnabled, notifictionsMuted: $notifictionsMuted, notificationsPaused: $notificationsPaused, language: $language)';
  }

  @override
  bool operator ==(covariant SettingsModel other) {
    if (identical(this, other)) return true;

    return other.darkModeEnabled == darkModeEnabled &&
        other.voiceAssistanceEnabled == voiceAssistanceEnabled &&
        other.notifictionsMuted == notifictionsMuted &&
        other.notificationsPaused == notificationsPaused &&
        other.language == language;
  }

  @override
  int get hashCode {
    return darkModeEnabled.hashCode ^ voiceAssistanceEnabled.hashCode ^ notifictionsMuted.hashCode ^ notificationsPaused.hashCode ^ language.hashCode;
  }
}
