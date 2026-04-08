import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/area/data/area_repository.dart';
import 'package:jalsetu/features/area/data/area_provider.dart';
import 'package:jalsetu/shared/models/area_model.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AreaManagementScreen extends ConsumerWidget {
  const AreaManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areas = ref.watch(areasStreamProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Areas'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAreaDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Area'),
      ),
      body: areas.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.location_off_outlined,
              title: 'No Areas',
              subtitle: 'Add water supply areas to get started.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final area = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha(15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child:
                        const Icon(Icons.location_on, color: AppTheme.primaryBlue),
                  ),
                  title: Text(area.name,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    'Created: ${DateFormat('MMM dd, yyyy').format(area.createdAt)}',
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppTheme.errorRed),
                    onPressed: () => _confirmDelete(context, ref, area),
                  ),
                ),
              ).animate().fadeIn(delay: (50 * index).ms);
            },
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(areasStreamProvider),
        ),
      ),
    );
  }

  void _showAddAreaDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Area'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Area Name',
            hintText: 'e.g., Sector 12, Gandhinagar',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final areaId =
                  FirebaseFirestore.instance.collection('areas').doc().id;
              final area = Area(
                areaId: areaId,
                name: controller.text.trim(),
                createdAt: DateTime.now(),
              );
              await AreaRepository().createArea(area);
              ref.invalidate(areasProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Area area) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Area'),
        content: Text('Are you sure you want to delete "${area.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorRed),
            onPressed: () async {
              await AreaRepository().deleteArea(area.areaId);
              ref.invalidate(areasProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
