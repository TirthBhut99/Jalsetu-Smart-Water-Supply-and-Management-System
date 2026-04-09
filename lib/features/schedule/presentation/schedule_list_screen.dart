import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/schedule/data/schedule_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class ScheduleListScreen extends ConsumerWidget {
  const ScheduleListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(userSchedulesProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Water Schedule'),
      body: schedules.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.schedule,
              title: 'No Schedules',
              subtitle: 'Water supply schedules for your area will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userSchedulesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final schedule = list[index];
                final isToday = DateFormat('yyyy-MM-dd').format(schedule.date) ==
                    DateFormat('yyyy-MM-dd').format(DateTime.now());
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    side: isToday
                        ? const BorderSide(
                            color: AppTheme.primaryBlue, width: 2)
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppTheme.primaryBlue
                                : AppTheme.primaryBlue.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat('dd').format(schedule.date),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color:
                                      isToday ? Colors.white : AppTheme.primaryBlue,
                                ),
                              ),
                              Text(
                                DateFormat('MMM').format(schedule.date),
                                style: TextStyle(
                                  fontSize: 11,
                                  color:
                                      isToday ? Colors.white : AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  if (isToday)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      margin: const EdgeInsets.only(right: 8),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBlue,
                                        borderRadius:
                                            BorderRadius.circular(4),
                                      ),
                                      child: const Text('TODAY',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700)),
                                    ),
                                  StatusChip.fromStatus(schedule.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 16,
                                      color: AppTheme.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${schedule.startTime} — ${schedule.endTime}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.water_drop,
                            color: AppTheme.accentCyan, size: 28),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading schedules...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(userSchedulesProvider),
        ),
      ),
    );
  }
}
