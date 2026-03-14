import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/activity/screens/activity_screen.dart';
import '../../features/activity/screens/activity_detail_screen.dart';
import '../../features/stats/screens/comprehensive_stats_screen.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/help_support_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/journal/screens/journal_list_screen.dart';
import '../widgets/main_navigation.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      redirect: (context, state) {
        final isLoggedIn = authProvider.isAuthenticated;
        final isLoggingIn = state.uri.path == '/login';
        final isSigningUp = state.uri.path == '/signup';
        final isSplash = state.uri.path == '/splash';
        
        if (isSplash) {
          return null;
        }
        
        if (!isLoggedIn && !isLoggingIn && !isSigningUp) {
          return '/login';
        }
        
        if (isLoggedIn && (isLoggingIn || isSigningUp)) {
          return '/home';
        }
        
        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/chat',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const ChatScreen(),
        ),
        GoRoute(
          path: '/settings',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
          path: '/help-support',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const HelpSupportScreen(),
        ),
        GoRoute(
          path: '/privacy-policy',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: '/journal',
          parentNavigatorKey: _rootNavigatorKey,
          builder: (context, state) => const JournalListScreen(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => MainNavigation(child: child),
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/activity',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ActivityScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return ActivityDetailScreen(activityId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/stats',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ComprehensiveStatsScreen(),
              ),
            ),
            GoRoute(
              path: '/notifications',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NotificationsScreen(),
              ),
            ),
            GoRoute(
              path: '/profile',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProfileScreen(),
              ),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => const EditProfileScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
