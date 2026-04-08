import 'package:cloud_firestore/cloud_firestore.dart';

class Complaint {
  final String complaintId;
  final String userId;
  final String areaId;
  final String category;
  final String description;
  final String status; // 'pending', 'in_progress', 'resolved', 'rejected'
  final String priority; // 'high', 'normal'
  final DateTime createdAt;

  Complaint({
    required this.complaintId,
    required this.userId,
    required this.areaId,
    required this.category,
    required this.description,
    required this.status,
    required this.priority,
    required this.createdAt,
  });

  factory Complaint.fromMap(Map<String, dynamic> map) {
    return Complaint(
      complaintId: map['complaintId'] ?? '',
      userId: map['userId'] ?? '',
      areaId: map['areaId'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'pending',
      priority: map['priority'] ?? 'normal',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'complaintId': complaintId,
      'userId': userId,
      'areaId': areaId,
      'category': category,
      'description': description,
      'status': status,
      'priority': priority,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Complaint copyWith({
    String? complaintId,
    String? userId,
    String? areaId,
    String? category,
    String? description,
    String? status,
    String? priority,
    DateTime? createdAt,
  }) {
    return Complaint(
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      areaId: areaId ?? this.areaId,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
