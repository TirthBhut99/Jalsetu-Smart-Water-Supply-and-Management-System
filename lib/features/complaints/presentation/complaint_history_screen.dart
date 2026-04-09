import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/complaints/data/complaint_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ComplaintHistoryScreen extends ConsumerWidget {
  const ComplaintHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complaints = ref.watch(userComplaintsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'My Complaints'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/resident/complaint-form'),
        icon: const Icon(Icons.add),
        label: const Text('New Complaint'),
      ),
      body: complaints.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.check_circle_outline,
              title: 'No Complaints',
              subtitle: 'You have not filed any complaints yet.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userComplaintsProvider),
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            StatusChip.fromStatus(complaint.status),
                            const Spacer(),
                            Icon(Icons.access_time,
                                size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('MMM dd, yyyy')
                                  .format(complaint.createdAt),
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideX(begin: 0.05);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading complaints...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(userComplaintsProvider),
        ),
      ),
    );
  }
}
