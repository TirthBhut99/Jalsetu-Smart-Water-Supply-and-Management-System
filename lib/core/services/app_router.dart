import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jalsetu/features/auth/data/auth_provider.dart';
import 'package:jalsetu/features/auth/presentation/login_screen.dart';
import 'package:jalsetu/features/auth/presentation/signup_screen.dart';
import 'package:jalsetu/features/auth/presentation/forgot_password_screen.dart';
import 'package:jalsetu/features/dashboard/presentation/resident_dashboard_screen.dart';
import 'package:jalsetu/features/dashboard/presentation/resident_shell_screen.dart';
import 'package:jalsetu/features/schedule/presentation/schedule_list_screen.dart';
import 'package:jalsetu/features/complaints/presentation/complaint_history_screen.dart';
import 'package:jalsetu/features/complaints/presentation/complaint_form_screen.dart';
import 'package:jalsetu/features/alerts/presentation/alerts_screen.dart';
import 'package:jalsetu/features/profile/presentation/profile_screen.dart';
import 'package:jalsetu/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:jalsetu/features/admin/presentation/admin_shell_screen.dart';
import 'package:jalsetu/features/admin/presentation/area_management_screen.dart';
import 'package:jalsetu/features/admin/presentation/user_management_screen.dart';
import 'package:jalsetu/features/admin/presentation/schedule_management_screen.dart';
import 'package:jalsetu/features/admin/presentation/complaint_management_screen.dart';
import 'package:jalsetu/features/admin/presentation/alert_management_screen.dart';
import 'package:jalsetu/features/auth/presentation/splash_screen.dart';

final splashDelayProvider = FutureProvider<bool>((ref) async {
  await Future.delayed(const Duration(seconds: 3));
  return true;
});

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final currentUser = ref.watch(currentUserProvider);
  final splashDelay = ref.watch(splashDelayProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading || authState is AsyncLoading;
      final firebaseUser = authState.valueOrNull;
      final isLoggedIn = firebaseUser != null;
      final path = state.uri.path;
      final isSplash = path == '/';
      final isSplashDelaying = splashDelay.isLoading;
      final isAuthRoute = path == '/login' ||
          path == '/signup' ||
          path == '/forgot-password';

      // 1. Force splash screen while loading or delaying
      if (isLoading || isSplashDelaying) {
        if (!isSplash) return '/'; // Force splash screen if not already there
        return null; // Stay on splash screen
      }

      // 2. Auth resolved: not logged in
      if (!isLoggedIn) {
        // Already on an auth page? Stay there
        if (isAuthRoute) return null;
        // Otherwise send to login
        return '/login';
      }

      // 3. Logged in — redirect away from splash/auth pages
      if (isSplash || isAuthRoute) {
        final user = currentUser.valueOrNull;
        if (user == null) return null; // Still loading user profile
        return user.isAdmin ? '/admin' : '/resident';
      }

      return null;
    },
    routes: [
      // Splash
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Profile (shared)
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // Resident routes with shell
      ShellRoute(
        builder: (context, state, child) => ResidentShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/resident',
            builder: (context, state) => const ResidentDashboardScreen(),
          ),
          GoRoute(
            path: '/resident/schedule',
            builder: (context, state) => const ScheduleListScreen(),
          ),
          GoRoute(
            path: '/resident/complaints',
            builder: (context, state) => const ComplaintHistoryScreen(),
          ),
          GoRoute(
            path: '/resident/alerts',
            builder: (context, state) => const AlertsScreen(),
          ),
        ],
      ),

      // Complaint form (without shell)
      GoRoute(
        path: '/resident/complaint-form',
        builder: (context, state) => const ComplaintFormScreen(),
      ),

      // Admin routes with shell
      ShellRoute(
        builder: (context, state, child) => AdminShellScreen(child: child),
        routes: [
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminDashboardScreen(),
          ),
          GoRoute(
            path: '/admin/areas',
            builder: (context, state) => const AreaManagementScreen(),
          ),
          GoRoute(
            path: '/admin/users',
            builder: (context, state) => const UserManagementScreen(),
          ),
          GoRoute(
            path: '/admin/schedules',
            builder: (context, state) => const ScheduleManagementScreen(),
          ),
          GoRoute(
            path: '/admin/complaints',
            builder: (context, state) => const ComplaintManagementScreen(),
          ),
          GoRoute(
            path: '/admin/alerts',
            builder: (context, state) => const AlertManagementScreen(),
          ),
        ],
      ),
    ],
  );
});
