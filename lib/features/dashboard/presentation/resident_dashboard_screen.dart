import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/features/schedule/data/schedule_provider.dart';
import 'package:jalsetu/features/complaints/data/complaint_provider.dart';
import 'package:jalsetu/features/alerts/data/alert_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ResidentDashboardScreen extends ConsumerWidget {
  const ResidentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final schedules = ref.watch(userSchedulesProvider);
    final complaints = ref.watch(userComplaintsProvider);
    final alerts = ref.watch(userAlertsProvider);

    return Scaffold(
      body: currentUser.when(
        data: (user) {
          if (user == null) return const LoadingWidget();
          return CustomScrollView(
            slivers: [
              // Gradient Header
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration:
                        const BoxDecoration(gradient: AppTheme.headerGradient),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.white.withAlpha(50),
                                  child: Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(200),
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => context.push('/profile'),
                                  icon: const Icon(Icons.settings,
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

              // Stats Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _StatCard(
                        icon: Icons.schedule,
                        label: 'Schedules',
                        value: schedules.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.primaryBlue,
                      ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.report_problem,
                        label: 'Complaints',
                        value:
                            complaints.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.warningOrange,
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: Icons.notifications_active,
                        label: 'Alerts',
                        value: alerts.valueOrNull?.length.toString() ?? '—',
                        color: AppTheme.errorRed,
                      ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                    ],
                  ),
                ),
              ),

              // Upcoming Schedule
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _SectionHeader(
                    title: 'Upcoming Schedule',
                    onSeeAll: () => context.go('/resident/schedule'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 120,
                  child: schedules.when(
                    data: (list) {
                      if (list.isEmpty) {
                        return const Center(
                            child: Text('No upcoming schedules'));
                      }
                      return ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: list.length > 3 ? 3 : list.length,
                        itemBuilder: (context, index) {
                          final s = list[index];
                          return Container(
                            width: 200,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMedium),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.water_drop,
                                        color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    StatusChip.fromStatus(s.status),
                                  ],
                                ),
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(s.date),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${s.startTime} - ${s.endTime}',
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(200),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: (100 * index).ms);
                        },
                      );
                    },
                    loading: () => const LoadingWidget(),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ),

              // Recent Alerts
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _SectionHeader(
                    title: 'Recent Alerts',
                    onSeeAll: () => context.go('/resident/alerts'),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: alerts.when(
                  data: (list) {
                    if (list.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No alerts'),
                      );
                    }
                    return Column(
                      children: list.take(3).map((alert) {
                        IconData icon;
                        Color color;
                        switch (alert.type) {
                          case 'emergency':
                            icon = Icons.warning_amber_rounded;
                            color = AppTheme.errorRed;
                            break;
                          case 'warning':
                            icon = Icons.info_outline;
                            color = AppTheme.warningOrange;
                            break;
                          default:
                            icon = Icons.notifications_outlined;
                            color = AppTheme.primaryBlue;
                        }
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withAlpha(25),
                              child: Icon(icon, color: color),
                            ),
                            title: Text(alert.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            subtitle: Text(
                              alert.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Text(
                              DateFormat('MMM dd').format(alert.createdAt),
                              style: TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12),
                            ),
                          ),
                        ).animate().fadeIn(delay: 100.ms);
                      }).toList(),
                    );
                  },
                  loading: () => const LoadingWidget(),
                  error: (e, _) => Center(child: Text('Error: $e')),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('See All'),
        ),
      ],
    );
  }
}
