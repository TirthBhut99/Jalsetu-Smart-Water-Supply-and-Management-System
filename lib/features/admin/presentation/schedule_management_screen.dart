import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/schedule/data/schedule_repository.dart';
import 'package:jalsetu/features/schedule/data/schedule_provider.dart';
import 'package:jalsetu/features/area/data/area_provider.dart';
import 'package:jalsetu/shared/models/schedule_model.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScheduleManagementScreen extends ConsumerWidget {
  const ScheduleManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedules = ref.watch(allSchedulesProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Schedules'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddScheduleDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),
      body: schedules.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.schedule,
              title: 'No Schedules',
              subtitle: 'Create water supply schedules for areas.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allSchedulesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final schedule = list[index];
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
                                DateFormat('EEE, MMM dd, yyyy')
                                    .format(schedule.date),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            StatusChip.fromStatus(schedule.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time,
                                size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              '${schedule.startTime} - ${schedule.endTime}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const Spacer(),
                            const Icon(Icons.location_on,
                                size: 16, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              'Area: ${schedule.areaId.substring(0, 8)}...',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            _StatusButton(
                              label: 'Active',
                              isSelected: schedule.status == 'active',
                              onTap: () => _updateStatus(
                                  ref, schedule.scheduleId, 'active'),
                            ),
                            const SizedBox(width: 8),
                            _StatusButton(
                              label: 'Complete',
                              isSelected: schedule.status == 'completed',
                              onTap: () => _updateStatus(
                                  ref, schedule.scheduleId, 'completed'),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: AppTheme.errorRed, size: 20),
                              onPressed: () =>
                                  _deleteSchedule(context, ref, schedule),
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
        loading: () => const LoadingWidget(message: 'Loading schedules...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allSchedulesProvider),
        ),
      ),
    );
  }

  void _updateStatus(WidgetRef ref, String scheduleId, String status) async {
    await ScheduleRepository().updateSchedule(scheduleId, {'status': status});
    ref.invalidate(allSchedulesProvider);
  }

  void _deleteSchedule(
      BuildContext context, WidgetRef ref, WaterSchedule schedule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              await ScheduleRepository().deleteSchedule(schedule.scheduleId);
              ref.invalidate(allSchedulesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddScheduleDialog(BuildContext context, WidgetRef ref) {
    final areas = ref.read(areasProvider);
    String? selectedAreaId;
    DateTime selectedDate = DateTime.now();
    final startTimeController = TextEditingController(text: '06:00');
    final endTimeController = TextEditingController(text: '08:00');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Schedule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Area dropdown
                areas.when(
                  data: (list) => DropdownButtonFormField<String>(
                    initialValue: selectedAreaId,
                    decoration: const InputDecoration(labelText: 'Select Area'),
                    items: list
                        .map((a) => DropdownMenuItem(
                            value: a.areaId, child: Text(a.name)))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedAreaId = v),
                  ),
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => const Text('Error loading areas'),
                ),
                const SizedBox(height: 16),
                // Date picker
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() => selectedDate = date);
                    }
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: startTimeController,
                  decoration: const InputDecoration(labelText: 'Start Time'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: endTimeController,
                  decoration: const InputDecoration(labelText: 'End Time'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedAreaId == null) return;
                final scheduleId = FirebaseFirestore.instance
                    .collection('schedules')
                    .doc()
                    .id;
                final schedule = WaterSchedule(
                  scheduleId: scheduleId,
                  areaId: selectedAreaId!,
                  date: selectedDate,
                  startTime: startTimeController.text,
                  endTime: endTimeController.text,
                  status: 'scheduled',
                );
                await ScheduleRepository().createSchedule(schedule);
                ref.invalidate(allSchedulesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue
              : AppTheme.primaryBlue.withAlpha(10),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue
                : AppTheme.primaryBlue.withAlpha(40),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.primaryBlue,
          ),
        ),
      ),
    );
  }
}
