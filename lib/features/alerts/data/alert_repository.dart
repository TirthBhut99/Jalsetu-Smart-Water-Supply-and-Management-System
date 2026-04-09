import 'package:jalsetu/core/constants/app_constants.dart';
import 'package:jalsetu/core/services/firestore_service.dart';
import 'package:jalsetu/shared/models/alert_model.dart';

class AlertRepository {
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> createAlert(WaterAlert alert) async {
    await _firestoreService.setDocument(
      collection: AppConstants.alertsCollection,
      docId: alert.alertId,
      data: alert.toMap(),
    );
  }

  Future<List<WaterAlert>> getAlertsByArea(String? areaId) async {
    // Get area-specific alerts and global alerts (areaId is null)
    List<WaterAlert> alerts = [];
    
    if (areaId != null && areaId.isNotEmpty) {
      final areaAlerts = await _firestoreService.getCollectionWhere(
        collection: AppConstants.alertsCollection,
        field: 'areaId',
        value: areaId,
      );
      alerts.addAll(areaAlerts.docs
          .map((doc) => WaterAlert.fromMap(doc.data() as Map<String, dynamic>)));
    }

    final globalAlerts = await _firestoreService.instance
        .collection(AppConstants.alertsCollection)
        .where('areaId', isNull: true)
        .get();

    alerts.addAll(globalAlerts.docs
        .map((doc) => WaterAlert.fromMap(doc.data() as Map<String, dynamic>)));

    return alerts..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<List<WaterAlert>> getAllAlerts() async {
    final snapshot = await _firestoreService.getCollection(
      collection: AppConstants.alertsCollection,
    );
    return snapshot.docs
        .map((doc) => WaterAlert.fromMap(doc.data() as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Stream<List<WaterAlert>> streamAllAlerts() {
    return _firestoreService.instance
        .collection(AppConstants.alertsCollection)
        .snapshots()
        .map((snapshot) {
      final alerts = snapshot.docs
          .map((doc) => WaterAlert.fromMap(doc.data()))
          .toList();
      alerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return alerts;
    });
  }

  Future<void> updateAlert(
      String alertId, Map<String, dynamic> data) async {
    await _firestoreService.updateDocument(
      collection: AppConstants.alertsCollection,
      docId: alertId,
      data: data,
    );
  }

  Future<void> deleteAlert(String alertId) async {
    await _firestoreService.deleteDocument(
      collection: AppConstants.alertsCollection,
      docId: alertId,
    );
  }
}
