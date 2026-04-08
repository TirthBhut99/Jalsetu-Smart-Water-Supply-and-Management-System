import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/alerts/data/alert_repository.dart';
import 'package:jalsetu/features/alerts/data/alert_provider.dart';
import 'package:jalsetu/features/area/data/area_provider.dart';
import 'package:jalsetu/shared/models/alert_model.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlertManagementScreen extends ConsumerWidget {
  const AlertManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(allAlertsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Alerts'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAlertDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New Alert'),
      ),
      body: alerts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'No Alerts',
              subtitle: 'Create alerts to notify residents.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allAlertsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final alert = list[index];
                IconData icon;
                Color color;
                switch (alert.type) {
                  case 'emergency':
                    icon = Icons.warning_amber_rounded;
                    color = AppTheme.errorRed;
                    break;
                  case 'warning':
                    icon = Icons.error_outline;
                    color = AppTheme.warningOrange;
                    break;
                  default:
                    icon = Icons.info_outline;
                    color = AppTheme.primaryBlue;
                }
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(icon, color: color),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(alert.title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(alert.message,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      alert.type.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    alert.areaId != null
                                        ? 'Area-specific'
                                        : 'Global',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    DateFormat('MMM dd').format(alert.createdAt),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppTheme.errorRed, size: 20),
                          onPressed: () =>
                              _confirmDelete(context, ref, alert),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading alerts...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allAlertsProvider),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, WaterAlert alert) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Alert'),
        content: Text('Delete alert "${alert.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              await AlertRepository().deleteAlert(alert.alertId);
              ref.invalidate(allAlertsProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddAlertDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'info';
    String? selectedAreaId;
    bool isGlobal = true;
    final areas = ref.read(areasProvider);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Create Alert'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Message'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['info', 'warning', 'emergency']
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t.toUpperCase())))
                      .toList(),
                  onChanged: (v) =>
                      setDialogState(() => selectedType = v!),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Global Alert'),
                  subtitle: const Text('Send to all areas'),
                  value: isGlobal,
                  onChanged: (v) => setDialogState(() => isGlobal = v),
                ),
                if (!isGlobal)
                  areas.when(
                    data: (list) => DropdownButtonFormField<String>(
                      initialValue: selectedAreaId,
                      decoration:
                          const InputDecoration(labelText: 'Select Area'),
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
                if (titleController.text.trim().isEmpty ||
                    messageController.text.trim().isEmpty) {
                  return;
                }
                final alertId = FirebaseFirestore.instance
                    .collection('alerts')
                    .doc()
                    .id;
                final alert = WaterAlert(
                  alertId: alertId,
                  title: titleController.text.trim(),
                  message: messageController.text.trim(),
                  type: selectedType,
                  areaId: isGlobal ? null : selectedAreaId,
                  createdAt: DateTime.now(),
                );
                await AlertRepository().createAlert(alert);
                ref.invalidate(allAlertsProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Send Alert'),
            ),
          ],
        ),
      ),
    );
  }
}
