import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalsetu/features/alerts/data/alert_repository.dart';
import 'package:jalsetu/shared/models/alert_model.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';

final alertRepositoryProvider = Provider<AlertRepository>((ref) {
  return AlertRepository();
});

// Alerts for current user's area (includes global alerts)
final userAlertsProvider = FutureProvider<List<WaterAlert>>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];
  final repo = ref.read(alertRepositoryProvider);
  return await repo.getAlertsByArea(currentUser.areaId);
});

// All alerts (admin)
final allAlertsProvider = FutureProvider<List<WaterAlert>>((ref) async {
  final repo = ref.read(alertRepositoryProvider);
  return await repo.getAllAlerts();
});

// Real-time alerts stream for notifications
final alertsStreamProvider = StreamProvider<List<WaterAlert>>((ref) {
  final repo = ref.read(alertRepositoryProvider);
  return repo.streamAllAlerts();
});
