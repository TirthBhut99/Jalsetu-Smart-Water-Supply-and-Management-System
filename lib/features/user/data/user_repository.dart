import 'package:jalsetu/core/constants/app_constants.dart';
import 'package:jalsetu/core/services/firestore_service.dart';
import 'package:jalsetu/shared/models/user_model.dart';

class UserRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createUser(AppUser user) async {
    await _firestoreService.setDocument(
      collection: AppConstants.usersCollection,
      docId: user.userId,
      data: user.toMap(),
    );
  }

  Future<AppUser?> getUser(String userId) async {
    final doc = await _firestoreService.getDocument(
      collection: AppConstants.usersCollection,
      docId: userId,
    );
    if (doc.exists) {
      return AppUser.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _firestoreService.getCollection(
      collection: AppConstants.usersCollection,
    );
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppUser>> getUsersByArea(String areaId) async {
    final snapshot = await _firestoreService.getCollectionWhere(
      collection: AppConstants.usersCollection,
      field: 'areaId',
      value: areaId,
    );
    return snapshot.docs
        .map((doc) => AppUser.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestoreService.updateDocument(
      collection: AppConstants.usersCollection,
      docId: userId,
      data: data,
    );
  }

  Future<void> deleteUser(String userId) async {
    await _firestoreService.deleteDocument(
      collection: AppConstants.usersCollection,
      docId: userId,
    );
  }

  String determineRole(String email) {
    return AppConstants.adminEmails.contains(email.toLowerCase())
        ? 'admin'
        : 'resident';
  }
}
