import 'package:jalsetu/core/constants/app_constants.dart';
import 'package:jalsetu/core/services/firestore_service.dart';
import 'package:jalsetu/shared/models/complaint_model.dart';

class ComplaintRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createComplaint(Complaint complaint) async {
    await _firestoreService.setDocument(
      collection: AppConstants.complaintsCollection,
      docId: complaint.complaintId,
      data: complaint.toMap(),
    );
  }

  Future<List<Complaint>> getComplaintsByUser(String userId) async {
    final snapshot = await _firestoreService.getCollectionWhere(
      collection: AppConstants.complaintsCollection,
      field: 'userId',
      value: userId,
    );
    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Stream<List<Complaint>> streamComplaintsByUser(String userId) {
    return _firestoreService
        .streamCollectionWhere(
          collection: AppConstants.complaintsCollection,
          field: 'userId',
          value: userId,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => Complaint.fromMap(doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<List<Complaint>> getComplaintsByArea(String? areaId) async {
    if (areaId == null || areaId.isEmpty) return [];
    final snapshot = await _firestoreService.getCollectionWhere(
      collection: AppConstants.complaintsCollection,
      field: 'areaId',
      value: areaId,
    );
    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<Complaint>> getAllComplaints() async {
    final snapshot = await _firestoreService.getCollection(
      collection: AppConstants.complaintsCollection,
    );
    return snapshot.docs
        .map((doc) => Complaint.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Stream<List<Complaint>> streamAllComplaints() {
    return _firestoreService
        .streamCollection(
          collection: AppConstants.complaintsCollection,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) => Complaint.fromMap(doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)));
  }

  Future<void> updateComplaint(
      String complaintId, Map<String, dynamic> data) async {
    await _firestoreService.updateDocument(
      collection: AppConstants.complaintsCollection,
      docId: complaintId,
      data: data,
    );
  }

  Future<void> deleteComplaint(String complaintId) async {
    await _firestoreService.deleteDocument(
      collection: AppConstants.complaintsCollection,
      docId: complaintId,
    );
  }
}
