import 'package:cloud_firestore/cloud_firestore.dart';

class Area {
  final String areaId;
  final String name;
  final DateTime createdAt;

  Area({
    required this.areaId,
    required this.name,
    required this.createdAt,
  });

  factory Area.fromMap(Map<String, dynamic> map) {
    return Area(
      areaId: map['areaId'] ?? '',
      name: map['name'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'areaId': areaId,
      'name': name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
