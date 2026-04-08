import 'package:cloud_firestore/cloud_firestore.dart';

class WaterSchedule {
  final String scheduleId;
  final String areaId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String status; // 'scheduled', 'active', 'completed', 'cancelled'

  WaterSchedule({
    required this.scheduleId,
    required this.areaId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory WaterSchedule.fromMap(Map<String, dynamic> map) {
    return WaterSchedule(
      scheduleId: map['scheduleId'] ?? '',
      areaId: map['areaId'] ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      status: map['status'] ?? 'scheduled',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'scheduleId': scheduleId,
      'areaId': areaId,
      'date': Timestamp.fromDate(date),
      'startTime': startTime,
      'endTime': endTime,
      'status': status,
    };
  }

  WaterSchedule copyWith({
    String? scheduleId,
    String? areaId,
    DateTime? date,
    String? startTime,
    String? endTime,
    String? status,
  }) {
    return WaterSchedule(
      scheduleId: scheduleId ?? this.scheduleId,
      areaId: areaId ?? this.areaId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
    );
  }
}
