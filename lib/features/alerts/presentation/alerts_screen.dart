import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:jalsetu/core/theme/app_theme.dart';
import 'package:jalsetu/features/alerts/data/alert_provider.dart';
import 'package:jalsetu/shared/widgets/common_widgets.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(userAlertsProvider);

    return Scaffold(
      appBar: const GradientAppBar(title: 'Alerts'),
      body: alerts.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_off_outlined,
              title: 'No Alerts',
              subtitle: 'You will be notified about water supply updates here.',
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(userAlertsProvider),
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
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMedium),
                    side: alert.type == 'emergency'
                        ? BorderSide(color: AppTheme.errorRed.withAlpha(80))
                        : BorderSide.none,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withAlpha(20),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, color: color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      alert.title,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd')
                                        .format(alert.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                alert.message,
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
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
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
        loading: () => const LoadingWidget(message: 'Loading alerts...'),
        error: (e, _) => ErrorRetryWidget(
          message: e.toString(),
          onRetry: () => ref.invalidate(userAlertsProvider),
        ),
      ),
    );
  }
}
