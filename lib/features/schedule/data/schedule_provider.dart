import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalsetu/features/schedule/data/schedule_repository.dart';
import 'package:jalsetu/shared/models/schedule_model.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  return ScheduleRepository();
});

// Schedules for the current user's area
final userSchedulesProvider = FutureProvider<List<WaterSchedule>>((ref) async {
  final currentUser = await ref.watch(currentUserProvider.future);
  if (currentUser == null) return [];
  final repo = ref.read(scheduleRepositoryProvider);
  return await repo.getSchedulesByArea(currentUser.areaId);
});

// All schedules (admin)
final allSchedulesProvider = FutureProvider<List<WaterSchedule>>((ref) async {
  final repo = ref.read(scheduleRepositoryProvider);
  return await repo.getAllSchedules();
});
