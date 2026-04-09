import 'package:cloud_firestore/cloud_firestore.dart';

class WaterAlert {
  final String alertId;
  final String title;
  final String message;
  final String type; // 'info', 'warning', 'emergency'
  final String? areaId; // nullable for global alerts
  final DateTime createdAt;

  WaterAlert({
    required this.alertId,
    required this.title,
    required this.message,
    required this.type,
    this.areaId,
    required this.createdAt,
  });

  factory WaterAlert.fromMap(Map<String, dynamic> map) {
    return WaterAlert(
      alertId: map['alertId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      type: map['type'] ?? 'info',
      areaId: map['areaId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'title': title,
      'message': message,
      'type': type,
      'areaId': areaId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  WaterAlert copyWith({
    String? alertId,
    String? title,
    String? message,
    String? type,
    String? areaId,
    DateTime? createdAt,
  }) {
    return WaterAlert(
      alertId: alertId ?? this.alertId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      areaId: areaId ?? this.areaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
