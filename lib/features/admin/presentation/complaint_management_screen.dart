import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/complaints/data/complaint_repository.dart';
import 'package:jalsetu/features/complaints/data/complaint_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class ComplaintManagementScreen extends ConsumerWidget {
  const ComplaintManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(allComplaintsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Complaints'),
      body: complaints.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'No Complaints',
              subtitle: 'All complaints will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allComplaintsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final complaint = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                complaint.category,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusChip.fromPriority(complaint.priority),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.person_outline,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'User: ${complaint.userId.substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(complaint.createdAt),
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          children: [
                            StatusChip.fromStatus(complaint.status),
                            const Spacer(),
                            _StatusDropdown(
                              currentStatus: complaint.status,
                              onChanged: (newStatus) async {
                                await ComplaintRepository().updateComplaint(
                                  complaint.complaintId,
                                  {'status': newStatus},
                                );
                                ref.invalidate(allComplaintsProvider);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading complaints...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allComplaintsProvider),
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String currentStatus;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({
    required this.currentStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withAlpha(10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.primaryBlue.withAlpha(40)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Status',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down,
                size: 18, color: AppTheme.primaryBlue),
          ],
        ),
      ),
      itemBuilder: (context) => [
        'pending',
        'in_progress',
        'resolved',
        'rejected',
      ]
          .map((status) => PopupMenuItem(
                value: status,
                child: Row(
                  children: [
                    if (status == currentStatus)
                      const Icon(Icons.check, size: 16, color: AppTheme.primaryBlue),
                    if (status != currentStatus) const SizedBox(width: 16),
                    const SizedBox(width: 8),
                    Text(status.replaceAll('_', ' ').toUpperCase()),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
