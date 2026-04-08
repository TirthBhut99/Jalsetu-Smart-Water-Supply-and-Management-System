import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalsetu/features/alerts/data/alert_provider.dart';
import 'package:jalsetu/core/services/notification_service.dart';

class ResidentShellScreen extends ConsumerWidget {
  final Widget child;
  const ResidentShellScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for incoming alerts
    ref.listen(alertsStreamProvider, (previous, next) {
      if (next.hasValue && previous != null && previous.hasValue) {
        final newAlerts = next.value!.where(
          (a) => !previous.value!.any((p) => p.alertId == a.alertId)
        ).toList();
        
        for (var alert in newAlerts) {
          ref.read(notificationServiceProvider).showNotification(
            id: alert.hashCode.abs() % 100000,
            title: alert.title,
            body: alert.message,
          );
        }
      }
    });

    return Scaffold(
      body: child,
      bottomNavigationBar: _ResidentBottomNav(),
    );
  }
}

class _ResidentBottomNav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;
    if (location.contains('/schedule')) currentIndex = 1;
    if (location.contains('/complaints')) currentIndex = 2;
    if (location.contains('/alerts')) currentIndex = 3;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/resident');
              break;
            case 1:
              context.go('/resident/schedule');
              break;
            case 2:
              context.go('/resident/complaints');
              break;
            case 3:
              context.go('/resident/alerts');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined),
            activeIcon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_outlined),
            activeIcon: Icon(Icons.report_problem),
            label: 'Complaints',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }
}
