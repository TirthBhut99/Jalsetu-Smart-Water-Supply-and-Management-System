import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/features/area/data/area_provider.dart';
import 'package:jalsetu/features/complaints/data/complaint_provider.dart';
import 'package:jalsetu/features/alerts/data/alert_provider.dart';
import 'package:jalsetu/features/schedule/data/schedule_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final areas = ref.watch(areasProvider);
    final complaints = ref.watch(allComplaintsProvider);
    final schedules = ref.watch(allSchedulesProvider);
    final alerts = ref.watch(allAlertsProvider);

    return Scaffold(
      body: currentUser.when(
        data: (user) {
          if (user == null) return const LoadingWidget();
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3F51B5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings,
                                      color: Colors.white, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Admin Dashboard',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        'Manage water supply system',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(180),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context.push('/profile'),
                                  icon: const Icon(Icons.person_outline,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Stats Grid
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      _AdminStatCard(
                        icon: Icons.location_on,
                        label: 'Areas',
                        value: areas.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.primaryBlue,
                        onTap: () => context.go('/admin/areas'),
                      ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95)),
                      _AdminStatCard(
                        icon: Icons.schedule,
                        label: 'Schedules',
                        value: schedules.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.accentCyan,
                        onTap: () => context.go('/admin/schedules'),
                      ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95)),
                      _AdminStatCard(
                        icon: Icons.report_problem,
                        label: 'Complaints',
                        value: complaints.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.warningOrange,
                        onTap: () => context.go('/admin/complaints'),
                      ).animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95)),
                      _AdminStatCard(
                        icon: Icons.notifications_active,
                        label: 'Alerts',
                        value: alerts.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.errorRed,
                        onTap: () => context.go('/admin/alerts'),
                      ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95)),
                    ],
                  ),
                ),
              ),

              // Quick Actions
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Quick Actions',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _QuickActionTile(
                        icon: Icons.add_location_alt,
                        title: 'Add New Area',
                        subtitle: 'Create a new water supply area',
                        onTap: () => context.go('/admin/areas'),
                      ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.05),
                      _QuickActionTile(
                        icon: Icons.add_alarm,
                        title: 'Create Schedule',
                        subtitle: 'Set water supply schedule',
                        onTap: () => context.go('/admin/schedules'),
                      ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.05),
                      _QuickActionTile(
                        icon: Icons.campaign,
                        title: 'Send Alert',
                        subtitle: 'Broadcast alert to residents',
                        onTap: () => context.go('/admin/alerts'),
                      ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.05),
                      _QuickActionTile(
                        icon: Icons.people_outline,
                        title: 'Manage Users',
                        subtitle: 'View and manage registered users',
                        onTap: () => context.go('/admin/users'),
                      ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.05),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
        loading: () => const LoadingWidget(message: 'Loading dashboard...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(currentUserProvider),
        ),
      ),
    );
  }
}

class _AdminStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _AdminStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 14, color: AppTheme.textSecondary),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withAlpha(15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        trailing:
            Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        onTap: onTap,
      ),
    );
  }
}
