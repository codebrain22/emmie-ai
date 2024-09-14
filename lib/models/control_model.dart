import 'package:flutter/material.dart';

@immutable
class ControlModel {
  final int freeMessages;
  final bool stopService;

  const ControlModel({
    required this.freeMessages,
    required this.stopService,
  });

  ControlModel copyWith({
    int? freeMessages,
    bool? stopService,
  }) {
    return ControlModel(
      freeMessages: freeMessages ?? this.freeMessages,
      stopService: stopService ?? this.stopService,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'freeMessages': freeMessages,
      'stopService': stopService,
    };
  }

  factory ControlModel.fromMap(Map<String, dynamic> map) {
    return ControlModel(
      freeMessages: map['freeMessages'] as int,
      stopService: map['stopService'] as bool,
    );
  }

  @override
  String toString() => 'AppControlModel(freeMessages: $freeMessages, stopService: $stopService)';

  @override
  bool operator ==(covariant ControlModel other) {
    if (identical(this, other)) return true;
  
    return 
      other.freeMessages == freeMessages &&
      other.stopService == stopService;
  }

  @override
  int get hashCode => freeMessages.hashCode ^ stopService.hashCode;
}
