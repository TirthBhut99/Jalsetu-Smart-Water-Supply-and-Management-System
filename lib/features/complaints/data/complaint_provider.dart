import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jalsetu/features/complaints/data/complaint_repository.dart';
import 'package:jalsetu/shared/models/complaint_model.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';

final complaintRepositoryProvider = Provider<ComplaintRepository>((ref) {
  return ComplaintRepository();
});

// Complaints for current user
final userComplaintsProvider = StreamProvider<List<Complaint>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) return Stream.value([]);
  final repo = ref.read(complaintRepositoryProvider);
  return repo.streamComplaintsByUser(user.uid);
});

// All complaints (admin)
final allComplaintsProvider = StreamProvider<List<Complaint>>((ref) {
  final repo = ref.read(complaintRepositoryProvider);
  return repo.streamAllComplaints();
});
