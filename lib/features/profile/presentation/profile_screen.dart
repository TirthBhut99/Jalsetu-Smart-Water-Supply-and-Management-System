import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/core/providers/theme_provider.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Profile', showBack: true),
      body: currentUser.when(
        data: (user) {
          if (user == null) return const LoadingWidget();
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ),
                ).animate().fadeIn().scale(delay: 200.ms),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isAdmin
                        ? AppTheme.warningOrange.withAlpha(20)
                        : AppTheme.primaryBlue.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: TextStyle(
                      color:
                          user.isAdmin ? AppTheme.warningOrange : AppTheme.primaryBlue,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 32),

                // Info Cards
                _ProfileCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user.email,
                ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                _ProfileCard(
                  icon: Icons.location_on_outlined,
                  label: 'Area ID',
                  value: user.areaId ?? 'N/A (Admin)',
                ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                _ProfileCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Member Since',
                  value:
                      '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.1),
                const SizedBox(height: 16),

                // Theme Toggle
                Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: SwitchListTile(
                    title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    secondary: Icon(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: AppTheme.primaryBlue,
                    ),
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (val) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                  ),
                ).animate().fadeIn(delay: 750.ms).slideX(begin: -0.1),

                // Sign Out
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Sign Out'),
                          content: const Text(
                              'Are you sure you want to sign out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Sign Out'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        ref.read(authNotifierProvider.notifier).signOut();
                      }
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: const BorderSide(color: AppTheme.errorRed),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withAlpha(15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
