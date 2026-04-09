import 'package:jalsetu/core/constants/app_constants.dart';
import 'package:jalsetu/core/services/firestore_service.dart';
import 'package:jalsetu/shared/models/area_model.dart';

class AreaRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createArea(Area area) async {
    await _firestoreService.setDocument(
      collection: AppConstants.areasCollection,
      docId: area.areaId,
      data: area.toMap(),
    );
  }

  Future<Area?> getArea(String areaId) async {
    final doc = await _firestoreService.getDocument(
      collection: AppConstants.areasCollection,
      docId: areaId,
    );
    if (doc.exists) {
      return Area.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<List<Area>> getAllAreas() async {
    final snapshot = await _firestoreService.getCollection(
      collection: AppConstants.areasCollection,
    );
    return snapshot.docs
        .map((doc) => Area.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteArea(String areaId) async {
    await _firestoreService.deleteDocument(
      collection: AppConstants.areasCollection,
      docId: areaId,
    );
  }

  Stream<List<Area>> streamAreas() {
    return _firestoreService
        .streamCollection(collection: AppConstants.areasCollection)
        .map((snapshot) => snapshot.docs
            .map((doc) => Area.fromMap(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
