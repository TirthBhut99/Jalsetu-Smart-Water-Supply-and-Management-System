import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalsetu/features/area/data/area_repository.dart';
import 'package:jalsetu/shared/models/area_model.dart';

final areaRepositoryProvider = Provider<AreaRepository>((ref) {
  return AreaRepository();
});

final areasProvider = FutureProvider<List<Area>>((ref) async {
  final repo = ref.read(areaRepositoryProvider);
  return await repo.getAllAreas();
});

final areasStreamProvider = StreamProvider<List<Area>>((ref) {
  final repo = ref.read(areaRepositoryProvider);
  return repo.streamAreas();
});
