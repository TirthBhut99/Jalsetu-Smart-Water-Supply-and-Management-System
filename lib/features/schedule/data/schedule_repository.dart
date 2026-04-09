import 'package:jalsetu/core/constants/app_constants.dart';
import 'package:jalsetu/core/services/firestore_service.dart';
import 'package:jalsetu/shared/models/schedule_model.dart';

class ScheduleRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createSchedule(WaterSchedule schedule) async {
    await _firestoreService.setDocument(
      collection: AppConstants.schedulesCollection,
      docId: schedule.scheduleId,
      data: schedule.toMap(),
    );
  }

  Future<List<WaterSchedule>> getSchedulesByArea(String? areaId) async {
    if (areaId == null || areaId.isEmpty) return [];
    final snapshot = await _firestoreService.getCollectionWhere(
      collection: AppConstants.schedulesCollection,
      field: 'areaId',
      value: areaId,
    );
    return snapshot.docs
        .map(
            (doc) => WaterSchedule.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<List<WaterSchedule>> getAllSchedules() async {
    final snapshot = await _firestoreService.getCollection(
      collection: AppConstants.schedulesCollection,
    );
    return snapshot.docs
        .map(
            (doc) => WaterSchedule.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> updateSchedule(
      String scheduleId, Map<String, dynamic> data) async {
    await _firestoreService.updateDocument(
      collection: AppConstants.schedulesCollection,
      docId: scheduleId,
      data: data,
    );
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _firestoreService.deleteDocument(
      collection: AppConstants.schedulesCollection,
      docId: scheduleId,
    );
  }

  Stream<List<WaterSchedule>> streamSchedulesByArea(String? areaId) {
    if (areaId == null || areaId.isEmpty) return Stream.value([]);
    return _firestoreService
        .streamCollectionWhere(
          collection: AppConstants.schedulesCollection,
          field: 'areaId',
          value: areaId,
        )
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                WaterSchedule.fromMap(doc.data() as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date)));
  }
}
