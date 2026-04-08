import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String userId;
  final String name;
  final String email;
  final String role; // 'admin' or 'resident'
  final String? areaId;
  final DateTime createdAt;

  AppUser({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    this.areaId,
    required this.createdAt,
  });

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'resident',
      areaId: map['areaId'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      'role': role,
      'areaId': areaId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AppUser copyWith({
    String? userId,
    String? name,
    String? email,
    String? role,
    String? areaId,
    DateTime? createdAt,
  }) {
    return AppUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      areaId: areaId ?? this.areaId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
