import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/user/data/user_repository.dart';
import 'package:jalsetu/shared/models/user_model.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';

final allUsersProvider = FutureProvider<List<AppUser>>((ref) async {
  return await UserRepository().getAllUsers();
});

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Manage Users'),
      body: users.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.people_outline,
              title: 'No Users',
              subtitle: 'Registered users will appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allUsersProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final user = list[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: user.isAdmin
                          ? AppTheme.warningOrange.withAlpha(20)
                          : AppTheme.primaryBlue.withAlpha(20),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: user.isAdmin
                              ? AppTheme.warningOrange
                              : AppTheme.primaryBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    title: Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(user.email,
                        style:
                            TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    trailing: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isAdmin
                            ? AppTheme.warningOrange.withAlpha(20)
                            : AppTheme.primaryBlue.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: user.isAdmin
                              ? AppTheme.warningOrange
                              : AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (50 * index).ms);
              },
            ),
          );
        },
        loading: () => const LoadingWidget(message: 'Loading users...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(allUsersProvider),
        ),
      ),
    );
  }
}
